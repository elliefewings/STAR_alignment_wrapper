# STAR alignment wrapper

### Wrapper for submission of STAR alignment to qsub system

This script requires a STAR generated genome directory. See `./generate_reference.sh` help function or reference instructions below to generate.


##            Usage

This wrapper was written with the intention of being used on the University of Heidelberg BioQuant cluster

```
$ ./STAR_align.sh

Program: STAR align

Version: 2.7.5

Usage: ./STAR_align.sh -i <input file or directory> -r <reference trancriptome> -o <output location>[optional] -h <help>

Options:
        -i      Input: Path to directory containing all fastqs or file containing list of directories with fastqs, one directory per line [required]
        -r      Reference transcriptome: Path to directory containing reference transcriptome [required]
        -o      Output directory: Path to location where output will be generated [default=HOME]
        -c      Conda environment: Name of conda environment with STAR installed (unless it is available on path) [default=PATH]
        -h      Help: Does what it says on the tin

```
## Install STAR

Install STAR into Conda environment (recommended) or install from source (see below)

To install [package](https://anaconda.org/bioconda/star) into Conda environment:
```
# Activate Conda environment
conda activate <env>

# Install STAR package
conda install -c bioconda star

# Then pass environment name to `./STAR_align.sh` and `./generate_reference.sh` scripts

```

To install from source, follow instructions on [STAR github](https://github.com/alexdobin/STAR) 

```
# Get latest STAR source from releases
wget https://github.com/alexdobin/STAR/archive/2.7.5c.tar.gz
tar -xzf 2.7.5c.tar.gz
cd STAR-2.7.5c

# Alternatively, get STAR source using git
git clone https://github.com/alexdobin/STAR.git

# Compile
cd source
make STAR

# Add to .bashrc
export PATH=/path/to/STAR-2.7.5c/bin/Linux_x86_64/:$PATH
```

## Input

The input `-i` can be either the path to one directory containing multiple fastqs, or the path to a text file containing a list of directories. When supplying a file containing a list of fastq-containing directories, it is assumed that the directory name is the name of the sample to be analysed. 

Example input file:
```
$head input.txt
/home/directory/sample1
/home/directory/sample2
/home/directory/sample3

$ ls /home/directory/sample1
sample1_S1_L001_R1_001.fastq.gz sample1_S1_L001_R2_001.fastq.gz
sample1_S1_L002_R1_001.fastq.gz sample1_S1_L002_R2_001.fastq.gz

```
Example input directory:
```
$ ls /home/directory/input
sample1_S1_L001_R1_001.fastq.gz sample1_S1_L001_R2_001.fastq.gz
sample1_S1_L002_R1_001.fastq.gz sample1_S1_L002_R2_001.fastq.gz
sample2_S2_L001_R1_001.fastq.gz sample2_S2_L001_R2_001.fastq.gz
sample2_S2_L002_R1_001.fastq.gz sample2_S2_L002_R2_001.fastq.gz
sample3_S3_L001_R1_001.fastq.gz sample3_S3_L001_R2_001.fastq.gz
sample3_S3_L002_R1_001.fastq.gz sample3_S3_L002_R2_001.fastq.gz
```
## Reference

A reference transcriptome is required for alignment.

This should be generated with the `./generate_reference.sh` script

```
Usage: ./generate_reference.sh -i <input fasta> -o <output location>[optional] -c <conda environment>[optional] -h <help>
   
Options:
       -i      Input: Path to fasta file for reference [required]
       -o      Output directory: Path to location where output will be generated [default=HOME]
       -c      Conda environment: Name of conda environment with STAR installed (unless it is available on path) [default=PATH]
       -h      Help: Does what it says on the tin
```
## Output

You can set an output directory with the `-o` option, by default data will be stored in your $HOME directory.

