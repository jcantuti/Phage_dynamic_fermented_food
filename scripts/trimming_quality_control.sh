#!/bin/bash
## Quality control with fastqc-0.11.9



mkdir results/Trimmomatic/FastQC_report

for file in results/Trimmomatic/*.fq.gz ; do sample=$(echo $(basename $file|sed 's/\.fq\.gz//g')); echo "qsub -wd /work_projet/metasimfood/metavirome/Article_fermented_commercial/ -N $sample-fastQC -q short.q -V -o log/fastQC_trim_${sample}.out -e log/fastQC_trim_${sample}.err -cwd -pe thread 32 -b y \"conda activate fastqc-0.11.9 && fastqc results/Trimmomatic/${sample}.fq.gz -o results/Trimmomatic/FastQC_report && conda deactivate\" " >> scripts/run_fastQC_trim.sh; done

chmod u+x scripts/run_fastQC_trim.sh

sh scripts/run_fastQC_trim.sh

## Summary of quality control with multiQC

mkdir results/Trimmomatic/FastQC_report/MultiQC

qsub -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/ -N multiQC -q short.q -V -o log/multiQC_trim.out -e log/multiQC_trim.err -cwd -pe thread 32 -b y "conda activate multiqc-1.11 && multiqc results/Trimmomatic/FastQC_report/ -o results/Trimmomatic/FastQC_report/MultiQC && conda deactivate"

gunzip results/Trimmomatic/*.fq.gz

for file in results/Trimmomatic/*.fq ; do sample=$(echo $(basename $file)); grep -c ^@ $file | awk -v var=$sample '{print var "\t" $0}'; done > /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/stat/Nbre_reads_after_trim.txt
