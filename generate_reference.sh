#!/bin/bash

# Submission script accepting arguments for STAR genome generate function
# Ellie Fewings, 17Sep2020

# Running:
# ./generate_reference.sh -i <input fasta> -o <output location>[optional] -h <help>

# Source bashrc
source ~/.bashrc

# Set abort function
abort()
{
    echo "Uh oh. An error occurred."
    echo ""
    echo "Exiting..."
    exit 2
}

trap 'abort' SIGINT SIGTERM

set -e

# Set help function
helpFunction()
{
  echo ""
  echo "Program: STAR genomeGenerate"
  echo ""
  echo "Version: 2.7.5"
  echo ""
  echo "Usage: ./generate_reference.sh -i <input fasta> -o <output location>[optional] -c <conda environment>[optional] -h <help>"
  echo ""
  echo "Options:"
      echo -e "\t-i\tInput: Path to fasta file for reference [required]"
      echo -e "\t-o\tOutput directory: Path to location where output will be generated [default=$HOME]"
      echo -e "\t-c\tConda environment: Name of conda environment with STAR installed (unless it is available on path) [default=PATH]"
      echo -e "\t-h\tHelp: Does what it says on the tin"
  echo ""
}

# Set output location
output="$HOME"

# Accept arguments specified by user
while getopts "i:o:c:h" opt; do
  case $opt in
    i ) input="$OPTARG"
    ;;
    o ) output="$OPTARG"
    ;;
    c ) conda="$OPTARG"
    ;;
    h ) helpFunction ; exit 0
    ;;
    * ) echo "Incorrect arguments" ; helpFunction ; abort
    ;;
  esac
done

# If input is missing report help function
if [[ "${input}" == "" ]]; then
  echo "Incorrect arguments."
  echo "Input is required."
  helpFunction
  abort
fi

# Check if input is in fasta format
if [[ "${input}" != *"fa" && "${input}" != *"fa.gz" ]] ; then
    echo "Incorrect arguments."
    echo "Fasta input is required (.fa or .fa.gz)"
    helpFunction
else
  input=$(realpath "${input}")
fi

# Load conda environment if requested
if [[ ! -z ${conda} ]]; then
  conda activate ${conda}
fi

# Create directory for log and output
if [[ -z ${output} ]]; then
    outdir=$(realpath "${PBS_O_HOME}/STAR_ref")
else
    outdir=$(realpath "${output}/STAR_ref")
fi

mkdir -p ${outdir}

log="${outdir}/STAR_genomegenerate_$(date +%Y%m%d).log"



# Find submission location
loc="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Find STAR
star=$(which STAR)

echo "Running ./generate_reference.sh" > ${log}
echo "" >> ${log}
echo "------------" >> ${log}
echo " Submission " >> ${log}
echo "------------" >> ${log}
echo "" >> ${log}
echo "Job name: STAR_genomeGenerate" >> ${log}
echo "Time allocated: 15:00:00" >> ${log}
echo "Time of submission: $(date +"%T %D")" >> ${log}
echo "Resources allocated: nodes=1:ppn=8" >> ${log}
echo "User: ${PBS_O_LOGNAME}" >> ${log}
echo "Log: ${log}" >> ${log}
echo "Input: ${input}" >> ${log}
echo "Output: ${outdir}" >> ${log}
echo "STAR: ${star}" >> ${log}
echo "------------" >> ${log}

# Submit to cluster
qsub "${loc}/qsub/qsub_generate_reference.sh" -v input=${input},outdir=${outdir},log=${log},star=${star},conda=${conda}

