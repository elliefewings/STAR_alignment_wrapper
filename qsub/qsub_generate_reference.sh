#!/bin/bash
## Run STAR genomegenerate for RNAseq data. Takes fasta file. Output location is optional. If not supplied, output will be stored in home directory.
## For easy usage, submit job with ./generate_reference.sh script
## Usage: qsub ./qsub_generate_reference.sh" -v input=${input},outdir=${outdir},tmp_dir=${tmp_dir},log=${log},star=${star},conda=${conda}

# Job Name
#PBS -N STAR_genomeGenerate
# Resources, e.g. a total time of 15 hours...
#PBS -l walltime=15:00:00
# Resources, ... and one node with 4 processors:
#PBS -l nodes=1:ppn=8
#PBS -l mem=100gb
# stderr redirection
#PBS -e STAR_genomegenerate.err
# stdout redirection
#PBS -o STAR_genomegenerate.log

# Source bashrc
source ~/.bashrc

# Load conda environment if requested
if [[ ! -z ${conda}  ]]; then
  conda activate ${conda}
fi

# Generate reference
STAR --runMode genomeGenerate \
  --genomeDir ${outdir} \
  --genomeFastaFiles ${fastqs} \
  --runThreadN 8 &>> ${log}
