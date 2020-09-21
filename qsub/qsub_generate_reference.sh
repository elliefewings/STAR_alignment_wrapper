#!/bin/bash
## Run STAR genomegenerate for RNAseq data. Takes fasta file. Output location is optional. If not supplied, output will be stored in home directory.
## For easy usage, submit job with ./generate_reference.sh script
## Usage: qsub ./qsub_generate_reference.sh" -v input=${input},outdir=${outdir},log=${log},star=${star},conda=${conda}

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

# Unzip input if necassary
if [[ "${input}" == *".fa.gz" ]] ; then
  fasta=$(echo ${input} | sed 's+.fa.gz+.fa+')
  gunzip -c ${input} > ${fasta}
elif [[ "${input}" == *".fa" ]] ; then
  fasta=${input}
fi

# Generate reference
STAR --runMode genomeGenerate \
  --genomeDir ${outdir} \
  --genomeFastaFiles ${fasta} \
  --runThreadN 8 &>> ${log}
  
# Remove unzipped file
if [[ "${input}" == *".fa.gz" ]] ; then
  rm ${fasta}
fi
