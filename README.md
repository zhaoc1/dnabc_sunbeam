# dnabc_sunbeam
Tranfer and Demultiplex Undetermined Fastq files using snakemake, generate the data_fp folder for sunbeam. 
can be treated as the subworkflow of sunbeam.

### Snakemake setup
Do this once:
```
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
sh Miniconda3-latest-Linux-x86_64.sh

conda create --name dnabc --file requirements.txt

source activate dnabc

# conda only keep track of the packages it installed. 
pip install git+git://github.com/zhaoc1/dnabc.git

snakemake
```

### Development

To updated the requirements file (after installing some new package):
```
conda list --name dnabc --explicit > requirements.txt
```

To update your conda environment with a new requirements file:
```
conda install --name dnabc --file requirements.txt
```

### Run on respublica

May need to unset PYTHONHOME for first time users.

```
unset PYTHONHOME
unset PYTHONPATH
source activate dnabc

snakemake -j 4 --configfile /path/to/ur/config/file --cluster-config cluster.json -p -c "qsub -cwd -r n -V -l h_vmem={cluster.h_vmem} -l mem_free={cluster.mem_free} -pe smp {threads}" all_dnabc

snakemake -j 40  --configfile /path/to/ur/config/file --cluster-config cluster.json -p -c "qsub -cwd -r n -V -l h_vmem={cluster.h_vmem} -l mem_free={cluster.mem_free} -pe smp {threads}" 


```
