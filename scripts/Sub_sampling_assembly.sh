#!/bin/bash
# Shell to be used for job execution
#$ -S /bin/bash
# Run the command from the working directory
#$ -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/
# job name
#$ -N sub_sampling
# q name
#$ -q short.q
# Export of environmental variables 
#$ -V
# Standard output
#$ -o log/sub_sampling.out
# Error output
#$ -e log/sub_sampling.err
# Use 32 CPUs
#$ -pe thread 32

conda activate seqtk-1.3
mkdir results/Trimmomatic/sub_100k

for file in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/Trimmomatic/*_R1_P.fq;
do sample=$(echo $(basename $file|sed 's/R1_P.fq//g')); 
seqtk sample -s100 results/Trimmomatic/${sample}R1_P.fq 25000 > results/Trimmomatic/sub_100k/${sample}_sub_100k_R1_P.fq;
seqtk sample -s100 results/Trimmomatic/${sample}R1_U.fq 25000 > results/Trimmomatic/sub_100k/${sample}_sub_100k_R1_U.fq;
seqtk sample -s100 results/Trimmomatic/${sample}R2_P.fq 25000 > results/Trimmomatic/sub_100k/${sample}_sub_100k_R2_P.fq;
seqtk sample -s100 results/Trimmomatic/${sample}R2_U.fq 25000 > results/Trimmomatic/sub_100k/${sample}_sub_100k_R2_U.fq;
done


mkdir results/Trimmomatic/sub_500k

for file in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/Trimmomatic/*_R1_P.fq;
do sample=$(echo $(basename $file|sed 's/R1_P.fq//g')); 
seqtk sample -s100 results/Trimmomatic/${sample}R1_P.fq 150000 > results/Trimmomatic/sub_500k/${sample}_sub_500k_R1_P.fq;
seqtk sample -s100 results/Trimmomatic/${sample}R1_U.fq 100000 > results/Trimmomatic/sub_500k/${sample}_sub_500k_R1_U.fq;
seqtk sample -s100 results/Trimmomatic/${sample}R2_P.fq 150000 > results/Trimmomatic/sub_500k/${sample}_sub_500k_R2_P.fq;
seqtk sample -s100 results/Trimmomatic/${sample}R2_U.fq 100000 > results/Trimmomatic/sub_500k/${sample}_sub_500k_R2_U.fq;
done

mkdir results/Trimmomatic/sub_1000k

for file in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/Trimmomatic/*_R1_P.fq;
do sample=$(echo $(basename $file|sed 's/R1_P.fq//g')); 
seqtk sample -s100 results/Trimmomatic/${sample}R1_P.fq 330000 > results/Trimmomatic/sub_1000k/${sample}_sub_1000k_R1_P.fq;
seqtk sample -s100 results/Trimmomatic/${sample}R1_U.fq 170000 > results/Trimmomatic/sub_1000k/${sample}_sub_1000k_R1_U.fq;
seqtk sample -s100 results/Trimmomatic/${sample}R2_P.fq 330000 > results/Trimmomatic/sub_1000k/${sample}_sub_1000k_R2_P.fq;
seqtk sample -s100 results/Trimmomatic/${sample}R2_U.fq 170000 > results/Trimmomatic/sub_1000k/${sample}_sub_1000k_R2_U.fq;
done

conda deactivate
