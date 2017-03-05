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

workdir: config["data_dir"]
starttime = int(time.time())

SAMPLE_IDS = build_samples_from_file(config["data_dir"] + "/" + config["barcodes"])
#SAMPLE_IDS = ["PCMP_" + s for s in SAMPLE_IDS]

DNABC_FP = config["data_dir"] + "/" + config["output"]["dnabc"]
BARCODE_FP = config["data_dir"] + "/" + config["barcodes"]
TARGET_FPS = expand(DNABC_FP + "/{sample}_{read}.fastq", sample=SAMPLE_IDS, read=["R1","R2"])

rule all:
    input: 
        TARGET_FPS

rule demultiplex:
    input:
        read1 = config["data_dir"] + "/Undetermined_S0_L" + config["lane_num"] + "_R1_001.fastq",
        read2 = config["data_dir"] + "/Undetermined_S0_L" + config["lane_num"] + "_R2_001.fastq"
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

onsuccess:
	print("Workflow finished, no error")
	shell("mail -s 'workflow finished' " + config['admins']+" <{log}")
onerror:
	print("An error occurred")
	shell("mail -s 'an error occurred' " + config['admins']+" < {log}")
