#!/bin/bash
# Shell to be used for job execution
#$ -S /bin/bash
# job name
#$ -N identify_sub
# q name
#$ -q long.q
# Export of environmental variables 
#$ -V
# Standard output
#$ -o log/identify_sub.out
# Error output
#$ -e log/identify_sub.err
# Run the command from the working directory
#$ -cwd
# Use 32 CPUs
#$ -pe thread 32

#mkdir results/Viral_prediction/

# VIBRANT
mkdir results/Viral_prediction/VIBRANT
conda activate vibrant-1.2.1
VIBRANT_run.py -i results/Dereplication/contigs_derep.fasta -folder results/Viral_prediction/VIBRANT -t 32
conda deactivate

# CheckV
mkdir results/Viral_prediction/CHECKV
conda activate checkv-0.8.1
checkv end_to_end results/Dereplication/contigs_derep.fasta results/Viral_prediction/CHECKV -d /db/outils/CHECKV-db/checkv-db-v1.1 -t 32
conda deactivate

# Virosorter2
mkdir results/Viral_prediction/VIRSORTER2
conda activate virsorter2-2.2.4
virsorter setup -d /save_projet/metasimfood/metavirome_data/db/virsorter_db
virsorter run -w results/Viral_prediction/VIRSORTER2 -i results/Dereplication/contigs_derep.fasta --db-dir /save_projet/metasimfood/metavirome_data/db/virsorter_db --include-groups dsDNAphage,NCLDV,RNA,ssDNA,lavidaviridae --exclude-lt2gene --viral-gene-required --hallmark-required --min-score 0.9 --high-confidence-only -j 32
conda deactivate

# Extract viral contigs
mkdir results/Viral_prediction/VIRAL_CONTIGS
cat results/Viral_prediction/VIBRANT/VIBRANT_contigs_derep/VIBRANT_results_contigs_derep/VIBRANT_genome_quality_contigs_derep.tsv | grep 'complete\|high\|medium' | awk '{ print $1}' > results/Viral_prediction/VIRAL_CONTIGS/List_contigs_Vibrant.txt
cat results/Viral_prediction/CHECKV/quality_summary.tsv | awk '{ print $1, $8 }' | grep 'Complete\|High\|Medium' | awk '{ print $1}' > results/Viral_prediction/VIRAL_CONTIGS/List_contigs_CheckV.txt
cat results/Viral_prediction/VIRSORTER2/final-viral-score.tsv | grep 'full' | awk '{ print $1 }' | cut -d '|' -f1 > results/Viral_prediction/VIRAL_CONTIGS/List_contigs_VirSorter.txt
cat results/Viral_prediction/VIRAL_CONTIGS/List_contigs_* | sort | uniq > results/Viral_prediction/VIRAL_CONTIGS/List_contigs_union.txt
cat results/Viral_prediction/VIRAL_CONTIGS/List_contigs_* | sed -e "s/_fragment_[0-9]*//g" | sort | uniq > results/Viral_prediction/VIRAL_CONTIGS/List_contigs_union2.txt

./scripts/fasta_reader_select_P3.py results/Dereplication/contigs_derep.fasta results/Viral_prediction/VIRAL_CONTIGS/List_contigs_union2.txt results/Viral_prediction/VIRAL_CONTIGS/viral_contigs.fasta


# Iphop
mkdir results/Iphop/
conda activate iphop-1.3.3
iphop predict --fa_file results/Viral_prediction/VIRAL_CONTIGS/viral_contigs.fasta --db_dir /db/outils/iphop-1.3.3/Aug_2023_pub_rw/ --out_dir results/Iphop/
conda deactivate

