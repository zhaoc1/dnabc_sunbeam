####
# demultiplex undetermined reads
# author: Chunyu Zhao
# time: 03-03-2017
####

import glob
import pathlib
import random
import configparser
import os
import sys
import shutil
import yaml
import subprocess
import time
from functions import * 

workdir: config["project_dir"]
starttime = int(time.time())

SAMPLE_IDS = build_samples_from_file(config["project_dir"] + "/" + config["barcodes"])
DNABC_FP = config["project_dir"] + "/" + config["output"]["dnabc"]
BARCODE_FP = config["project_dir"] + "/" + config["barcodes"]
TARGET_FPS = expand(DNABC_FP + "/{sample}_{read}.fastq", sample=SAMPLE_IDS, read=["R1","R2"])
LANES = list(config["lane_num"])

rule all:
    input: 
        expand(DNABC_FP + "/{sample}_{read}.fastq.gz", sample=SAMPLE_IDS, read=["R1","R2"])

rule copy_file:
    input:
        config["incoming_dir"] + "/" + config["flowcell_id"] + "/Data/Intensities/BaseCalls/Undetermined_S0_L00{lane}_{rp}_001.fastq.gz"
    output:
        config["project_dir"] + "/" + "Undetermined_S0_L00{lane}_{rp}_001.fastq.gz"
    params:
        config["project_dir"]
    shell:
        """
        cp {input[0]} {params[0]}
        """

rule gunzip_file:
    input:
        config["project_dir"] + "/" + "Undetermined_S0_L00{lane}_{rp}_001.fastq.gz"
    output:
        config["project_dir"] + "/" + "Undetermined_S0_L00{lane}_{rp}_001.fastq"
    shell:
       "gunzip -c {input[0]} > {output[0]}"

rule cat_R1s:
    input:
        expand(config["project_dir"] + "/" + "Undetermined_S0_L00{lane}_R1_001.fastq", lane=list(config["lane_num"]))
    output:
        config["project_dir"] + "/" + "Undetermined_S0_L" + config["lane_num"] + "_R1_001.fastq"
    shell:
       "cat {input} > {output[0]}"

rule cat_R2s:
    input:
        expand(config["project_dir"] + "/" + "Undetermined_S0_L00{lane}_R2_001.fastq", lane=list(config["lane_num"]))
    output:
        config["project_dir"] + "/" + "Undetermined_S0_L" + config["lane_num"] + "_R2_001.fastq"
    shell:
       "cat {input} > {output[0]}"

rule demultiplex:
    input:
        read1 = config["project_dir"] + "/Undetermined_S0_L" + config["lane_num"] + "_R1_001.fastq",
        read2 = config["project_dir"] + "/Undetermined_S0_L" + config["lane_num"] + "_R2_001.fastq"
    output:
        TARGET_FPS
    params:
        dnabc_summary = DNABC_FP + "/summary-dnabc.json"
    log: 
        DNABC_FP + "/dnabc.log"
    threads:
        config['threads']
    shell:
        """
        dnabc.py --forward-reads {input.read1} --reverse-reads {input.read2} \
        --barcode-file {BARCODE_FP} --output-dir {DNABC_FP} \
        --summary-file {params.dnabc_summary} &> {log}
        """

rule gzip_files:
     input:
        r1 = DNABC_FP + "/{sample}_R1.fastq",
        r2 = DNABC_FP + "/{sample}_R2.fastq"
     output:
        r1 = DNABC_FP + "/{sample}_R1.fastq.gz",
        r2 = DNABC_FP + "/{sample}_R2.fastq.gz"
     shell:
        """
        gzip {input.r1}
        gzip {input.r2}
        """

onsuccess:
	print("Workflow finished, no error")
	shell("mail -s 'workflow finished' " + config['admins']+" <{log}")
onerror:
	print("An error occurred")
	shell("mail -s 'an error occurred' " + config['admins']+" < {log}")
