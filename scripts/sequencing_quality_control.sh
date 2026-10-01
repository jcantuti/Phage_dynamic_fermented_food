#!/bin/bash

## Quality control with fastqc-0.11.9

mkdir results/FastQC_report

for file in /RAW_DATA/virome/*.fastq ; do sample1=$(echo $(basename $file)); sample=${sample1%.*}; echo "qsub  -N ${sample}-fastQC -q short.q -V -o log/fastQC_${sample}.out -e log/fastQC_${sample}.err -cwd -pe thread 32 -b y \"conda activate fastqc-0.11.9 && fastqc ${file} -o results/FastQC_report && conda deactivate\" " >> scripts/run_fastQC_2.sh; done

chmod u+x scripts/run_fastQC_2.sh

sh scripts/run_fastQC_2.sh

## Summary of quality control with multiQC

mkdir results/FastQC_report/MultiQC

qsub -N multiQC -q short.q -V -o log/multiQC1.out -e log/multiQC1.err -cwd -pe thread 32 -b y "conda activate multiqc-1.11 && multiqc results/FastQC_report/ -o results/FastQC_report/MultiQC && conda deactivate"
