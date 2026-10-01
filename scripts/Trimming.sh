#!/bin/bash

#Reads cleaning with trimmomatic-0.39 
# PE -phred33 uqality score
# ILLUMINACLIP: Cut adapter and other illumina-specific sequences from the read.
# SLIDINGWINDOW: Performs a sliding window trimming approach. It starts scanning at the 5‟ end and clips the read once the average quality within the window falls below a threshold.
# LEADING: Cut bases off the start of a read, if below a threshold quality
# TRAILING: Cut bases off the end of a read, if below a threshold quality
# MINLEN: Drop the read if it is below a specified length


mkdir results/Trimmomatic

for file in results/Host_decontamination/*_R1.fastq; do sample=$(echo $(basename $file|sed 's/R1.fastq//g')); echo "qsub -N ${sample}-trimmomatic -q short.q -V -o log/Trimmomatic_${sample}.out -e log/Trimmomatic_${sample}.err -cwd -pe thread 32 -b y \"conda activate trimmomatic-0.39 && trimmomatic PE -phred33 results/Host_decontamination/${sample}R1.fastq results/Host_decontamination/${sample}R2.fastq results/Trimmomatic/${sample}R1_P.fq.gz results/Trimmomatic/${sample}R1_U.fq.gz results/Trimmomatic/${sample}R2_P.fq.gz results/Trimmomatic/${sample}R2_U.fq.gz ILLUMINACLIP:/save_projet/metasimfood/metavirome_data/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:125 -threads 32 && conda deactivate \" " >> scripts/run_trimmomatic.sh;done

chmod u+x scripts/run_trimmomatic.sh

sh scripts/run_trimmomatic.sh
