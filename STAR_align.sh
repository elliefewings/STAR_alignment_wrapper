#!/bin/bash

# Submission script accepting arguments for STAR alignment function
# Ellie Fewings, 22Jul2020

# Running:
# ./STAR_align.sh -i <input file or directory> -r <reference trancriptome> -o <output location>[optional] -h <help>

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
  echo "Program: STAR align"
  echo ""
  echo "Version: 2.7.5"
  echo ""
  echo "Usage: ./STAR_align.sh -i <input file or directory> -r <reference trancriptome> -o <output location>[optional] -c <conda environment>[optional] -h <help>"
  echo ""
  echo "Options:"
      echo -e "\t-i\tInput: Path to directory containing all fastqs or file containing list of directories with fastqs, one directory per line [required]"
      echo -e "\t-r\tReference transcriptome: Path to directory containing reference transcriptome [required]"
      echo -e "\t-o\tOutput directory: Path to location where output will be generated [default=HOME]"
      echo -e "\t-c\tConda environment: Name of conda environment with STAR installed (unless it is available on path) [default=PATH]"
      echo -e "\t-h\tHelp: Does what it says on the tin"
  echo ""
}

# Accept arguments specified by user
while getopts "i:r:o:c:h" opt; do
  case $opt in
    i ) input="$OPTARG"
    ;;
    r ) ref="$OPTARG"
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

# Check minimum number of arguments
if [ $# -lt 2 ]; then
  echo "Not enough arguments"
  helpFunction
  abort
fi

# If bam or ref are missing report help function
if [[ "${input}" == "" || "${ref}" == "" ]]; then
  echo "Incorrect arguments."
  echo "Input and reference are required."
  helpFunction
  abort
else
  input=$(realpath "${input}")
  ref=$(realpath "${ref}")
fi

# Load conda environment if requested
if [[ ! -z ${conda} ]]; then
  conda activate ${conda}
fi

# Create directory for log and output
if [[ -z ${output} ]]; then
    outdir=$(realpath "${PBS_O_HOME}/STAR_align_output_$(date +%Y%m%d)")
else
    outdir=$(realpath "${output}/STAR_align_output_$(date +%Y%m%d)")
fi

mkdir -p ${outdir}

log="${outdir}/STAR_align_$(date +%Y%m%d).log"

# Find submission location
loc="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Create temporary directory
tmp_dir=$(mktemp -d -t tmp-XXXX-$(date +%Y%m%d) --tmpdir=${outdir})

# Find STAR
set +e
star=$(which STAR)
set -e

if [[ ${star} == "" ]] ; then
  echo "STAR not found on PATH. Please install or supply a conda environment"
  helpFunction
  abort
fi

echo "Running ./STAR_align.sh" > ${log}
echo "" >> ${log}
echo "------------" >> ${log}
echo " Submission " >> ${log}
echo "------------" >> ${log}
echo "" >> ${log}
echo "Job name: STAR_align" >> ${log}
echo "Time allocated: 15:00:00" >> ${log}
echo "Time of submission: $(date +"%T %D")" >> ${log}
echo "Resources allocated: nodes=1:ppn=8" >> ${log}
echo "User: ${PBS_O_LOGNAME}" >> ${log}
echo "Log: ${log}" >> ${log}
echo "Input: ${input}" >> ${log}
echo "Reference trancriptome: ${ref}" >> ${log}
echo "Output: ${outdir}" >> ${log}
echo "STAR: ${star}" >> ${log}
echo "------------" >> ${log}


# Create list of unique samples on which to run analysis
echo "" >> ${log}
echo "Creating list of samples on which to run analysis" >> ${log}
tfile="${tmp_dir}/samples.tmp.txt"
sfile="${tmp_dir}/samples.txt"

# Check if input is file or directory
if [[ -d ${input} ]] ; then
    nfq=$(ls -1 ${input}/*fastq.gz | wc -l)
    # Check if directory contains fastqs
    if [ ${nfq} -gt 0 ] ; then 
      echo "" >> ${log}
      echo "Input directory contains ${nfq} fastq files" >> ${log}
      echo "" >> ${log}
      intype="directory"
      for fq in $(ls -1 ${input}/*fastq.gz) ; do
        sample=$(basename ${fq} | sed 's/_L.*/_/g' | sed 's/_S[1-9]*_//g' | sed 's/_[1-9].fastq.gz//g')
        echo -e "${sample}\t${fq}" >> ${tfile}
      done
    else 
      echo "ERROR: Input directory contains no fastq files" >> ${log}
      echo "Exiting" >> ${log}
      exit 1
    fi

# Check if input is file
elif [[ -f ${input} ]] ; then
  intype="file"
  while read dir ; do
    nfq=$(ls -1 ${dir}/*fastq.gz | wc -l)
    if [ ${nfq} -gt 0 ] ; then
      sample=$(basename ${dir})
      for fq in $(ls -1 ${dir}/*fastq.gz) ; do
        echo -e "${sample}\t${fq}" >> ${tfile}
      done
    else 
      echo "ERROR: Input directory ${dir} contains no fastq files" >> ${log}
      echo "Exiting" >> ${log}
      exit 1
    fi
  done < ${input}
fi

# Remove duplicates from samples file
cut ${tfile} -f1 | sort -u > ${sfile}

#Submit to cluster
while read sample ; do
  echo "Submitting to cluster: ${sample}" >> ${log}
  qsub "${loc}/qsub/qsub_star_align.sh" -v sample=${sample},ref=${ref},output=${output},tmp_dir=${tmp_dir},log=${log},star=${star},conda=${conda}
done < ${sfile}
