#!/bin/bash
## Run STAR alignment for RNAseq data. Takes one directory containing all fastqs or file containing list of directories with fastqs, one directory per line. Output location is optional. If not supplied, output will be stored in home directory.
## Caveat: If list of directories is supplied, it is assumed that each directory is a sample
## For easy usage, submit job with ./star_align.sh script
## Usage: qsub ./qsub_star_align.sh -v sample=${sample},ref=${ref},output=${output},tmp_dir=${tmp_dir},log=${log},star=${star},conda=${conda}

# Job Name
#PBS -N STAR_align
# Resources, e.g. a total time of 15 hours...
#PBS -l walltime=15:00:00
# Resources, ... and one node with 4 processors:
#PBS -l nodes=1:ppn=8
#PBS -l mem=100gb
# stderr redirection
#PBS -e STAR_align.err
# stdout redirection
#PBS -o STAR_align.log

# Source bashrc
source ~/.bashrc

# Load conda environment if requested
if [[ ! -z ${conda}  ]]; then
  conda activate ${conda}
fi

# Create sample log
slog="${tmp_dir}/${sample}_alignment.log"

# Find fastqs
fastqs=$(cat "${tmp_dir}/samples.txt" | grep ${sample} | cut -f2 | paste -s -d,)

# Align
${star} --genomeDir ${ref} \
  --readFilesIn ${fastqs} \
  --readFilesCommand gunzip -c \
  --outFileNamePrefix ${tmp_dir}/${sample}_star_tmp \
  --outSAMtype BAM SortedByCoordinate \
  --runThreadN 8 &>> "${slog}"
  