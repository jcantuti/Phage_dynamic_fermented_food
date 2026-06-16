#!/bin/bash
# Shell to be used for job execution
#$ -S /bin/bash
# job name
#$ -N kaiju_RNA
# q name
#$ -q short.q
# Export of environmental variables 
#$ -V
# Standard output
#$ -o log/kaiju_RNA.out
# Error output
#$ -e log/kaiju_RNA.err
# Run the command from the working directory
#$ -cwd
# Use 32 CPUs
#$ -pe thread 32
## kaiju-1.9.2


mkdir results/Kaiju_metag

for file in /save_projet/metasimfood/metagenome_data/0_raw_fastq/Spontaneous_fermentation/Sauerkraut/*_1.fastq ; 
do 
sample=$(echo $(basename $file|sed 's/_.\.fastq//g')); 
echo "qsub -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/ -N ${sample}-Kaiju -q short.q -V -o log/Kaiju_${sample}.out -e log/Kaiju_${sample}.err -pe thread 16 -b y \"conda activate kaiju-1.9.2 && kaiju -t /db/outils/kaiju-2023-05/nr_euk/nodes.dmp -f /db/outils/kaiju-2023-05/nr_euk/kaiju_db_nr_euk.fmi -i ${file} -j /save_projet/metasimfood/metagenome_data/0_raw_fastq/Spontaneous_fermentation/Sauerkraut/${sample}_2.fastq -o results/Kaiju_metag/kaiju_${sample}.out -z 16 && conda deactivate\"" >> scripts/run_kaiju_metag.sh; done


for file in results/Kaiju_metag/*.out ; 
do
sample=$(echo $(basename $file|sed 's/.out//g')); 
echo "qsub -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/ -N ${sample}-Kaiju2table -q short.q -V -o log/Kaiju2table_${sample}.out -e log/Kaiju2table_${sample}.err -pe thread 16 -b y \" conda activate kaiju-1.9.2 && kaiju2table -t /db/outils/kaiju-2023-05/nr_euk/nodes.dmp -n /db/outils/kaiju-2023-05/nr_euk/names.dmp -r genus -l superkingdom,phylum,class,order,family,genus,species -e -o results/Kaiju_metag/${sample}_summary_viruses.tsv ${file} && conda deactivate\"" >> scripts/run_kaiju2table_sum_viruses.sh ;
done


chmod u+x run_kaiju.sh
sh run_kaiju.sh

chmod u+x scripts/run_kaiju2table_sum_viruses.sh
sh scripts/run_kaiju2table_sum_viruses.sh

