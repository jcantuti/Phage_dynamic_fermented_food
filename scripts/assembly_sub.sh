#!/bin/bash
#directory : /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/

mkdir results/Assembly

for file in results/Trimmomatic/*_R1_P.fq; do sample=$(echo $(basename $file|sed 's/_R1_P\.fq//g')); echo "qsub -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/ -N ${sample}-SPADES -q short.q -V -o log/SPAdes_${sample}.out -e log/SPAdes_${sample}.err -cwd -pe thread 32 -b y \"conda activate spades-3.15.3 && spades.py --only-assembler -t 32 -1 results/Trimmomatic/${sample}_R1_P.fq -2 results/Trimmomatic/${sample}_R2_P.fq -s results/Trimmomatic/${sample}_R1_U.fq -s results/Trimmomatic/${sample}_R2_U.fq -o results/Assembly/$sample -k 21,33,55,77,99,127 \" " >> scripts/run_SPAdes.sh;done


mkdir results/Assembly/sub_100k

for file in results/Trimmomatic/sub_100k/*_R1_P.fq; do sample=$(echo $(basename $file|sed 's/_R1_P\.fq//g')); echo "qsub -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/ -N ${sample}-SPADES_sub100k -q short.q -V -o log/SPAdes_sub100k_${sample}.out -e log/SPAdes_sub100k_${sample}.err -cwd -pe thread 32 -b y \"conda activate spades-3.15.3 && spades.py --only-assembler -t 32 -1 results/Trimmomatic/sub_100k/${sample}_R1_P.fq -2 results/Trimmomatic/sub_100k/${sample}_R2_P.fq -s results/Trimmomatic/sub_100k/${sample}_R1_U.fq -s results/Trimmomatic/sub_100k/${sample}_R2_U.fq -o results/Assembly/sub_100k/$sample -k 21,33,55,77,99,127 \" " >> scripts/run_SPAdes_sub_100k.sh;done

mkdir results/Assembly/sub_500k

for file in results/Trimmomatic/sub_500k/*_R1_P.fq; do sample=$(echo $(basename $file|sed 's/_R1_P\.fq//g')); echo "qsub -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/ -N ${sample}-SPADES_sub500k -q short.q -V -o log/SPAdes_sub500k_${sample}.out -e log/SPAdes_sub500k_${sample}.err -cwd -pe thread 32 -b y \"conda activate spades-3.15.3 && spades.py --only-assembler -t 32 -1 results/Trimmomatic/sub_500k/${sample}_R1_P.fq -2 results/Trimmomatic/sub_500k/${sample}_R2_P.fq -s results/Trimmomatic/sub_500k/${sample}_R1_U.fq -s results/Trimmomatic/sub_500k/${sample}_R2_U.fq -o results/Assembly/sub_500k/$sample -k 21,33,55,77,99,127 \" " >> scripts/run_SPAdes_sub_500k.sh;done

mkdir results/Assembly/sub_1000k

for file in results/Trimmomatic/sub_1000k/*_R1_P.fq; do sample=$(echo $(basename $file|sed 's/_R1_P\.fq//g')); echo "qsub -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/ -N ${sample}-SPADES_sub1000k -q short.q -V -o log/SPAdes_sub1000k_${sample}.out -e log/SPAdes_sub1000k_${sample}.err -cwd -pe thread 32 -b y \"conda activate spades-3.15.3 && spades.py --only-assembler -t 32 -1 results/Trimmomatic/sub_1000k/${sample}_R1_P.fq -2 results/Trimmomatic/sub_1000k/${sample}_R2_P.fq -s results/Trimmomatic/sub_1000k/${sample}_R1_U.fq -s results/Trimmomatic/sub_1000k/${sample}_R2_U.fq -o results/Assembly/sub_1000k/$sample -k 21,33,55,77,99,127 \" " >> scripts/run_SPAdes_sub_1000k.sh;done

chmod u+x scripts/run_SPAdes.sh
sh scripts/run_SPAdes.sh

chmod u+x scripts/run_SPAdes_sub_100k.sh
sh scripts/run_SPAdes_sub_100k.sh

chmod u+x scripts/run_SPAdes_sub_500k.sh
sh scripts/run_SPAdes_sub_500k.sh

chmod u+x scripts/run_SPAdes_sub_1000k.sh
sh scripts/run_SPAdes_sub_1000k.sh
