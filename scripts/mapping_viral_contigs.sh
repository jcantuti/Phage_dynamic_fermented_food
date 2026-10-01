#!/bin/bash
# Shell to be used for job execution
#$ -S /bin/bash
# job name
#$ -N mapping_viral
# q name
#$ -q short.q
# Export of environmental variables 
#$ -V
# Standard output
#$ -o log/mapping_viral_160524.out
# Error output
#$ -e log/mapping_viral_160524.err
# Run the command from the working directory
#$ -cwd
# Use 32 CPUs
#$ -pe thread 32


mkdir results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2

#Step 1 - Create the bwa-0.7.17 index for mapping with bwa-mem2-2.2.1
conda activate bwa-mem2-2.2.1
bwa-mem2 index -p results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/INDEX results/Viral_prediction/VIRAL_CONTIGS/viral_contigs.fasta
conda deactivate
# -p = prefix for the names of the files of the index

#Step 2 - Mapping using bwa-mem2-2.2.1 and count mapped reads on each contig with rsamtools-1.0.0
for file in results/Trimmomatic/reads_mapping/*.fastq
do
	id=$(echo $(basename $file | sed 's/\.fastq//g'))
	entries=$(grep \@ results/Trimmomatic/reads_mapping/${id}.fastq | wc -l)
	## Mapping - BWA-mem2 version 2.2.1 # mapping paired-end reads 
	conda activate bwa-mem2-2.2.1
	bwa-mem2 mem results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/INDEX -t 32 -a results/Trimmomatic/reads_mapping/${id}.fastq > results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/${id}.sam
	conda deactivate
	

	## Convert SAM -> BAM + Sort by name - samtools version 1.9
	conda activate samtools-1.9
	samtools view -bS results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/${id}.sam | samtools sort -n  > results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/${id}_sortedByName_bwa.bam 
	conda deactivate
	# view = view/convert SAM/BAM files
	## -b = output in BAM format
	## -S = input is SAM format
	# sort = sort aligments
	## -n = sort by read names (i.e., the QNAME field) rather than by chromosomal coordinates

	## Filter alignments - Msamtools version 1.1.3
	conda activate msamtools-1.1.3
	msamtools filter -b -u -l 80 -p 95 -z 80 --besthit results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/${id}_sortedByName_bwa.bam > results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/${id}.bam
	
	# filter = filters alignment to only keep those that follow chosen criteria such as %id, length of alignment, ... 
	# -b = require BAM output
	# -l = minimum length of alignment
	# -p = minimum sequence identity of alignment, in percentage (0-100)
	# -z = minimum percent of the query that must be aligned (0-100)
	# --besthit = keep all highest scoring hit(s) per read
	
	## Counts - Msamtools version 1.1.3
	msamtools profile --multi=proportional --label=${id} --unit=ab --nolen results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/${id}.bam -o results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/results.profile_${id}_proportional.txt.gz --total=$entries
	conda deactivate
	# profile = sequence abundance profiling 
	# --multi = how to deal with read that map at different locations. "proportional" = fraction proportional to its reference-sequence-length-normalized relative abundance estimated only based on uniquely mapped reads
	# --label = label of the generated profile (= sample id)
	# --unit = how to measure abundance. "ab" = number of inserts mapped to the sequence, normalized by sequence length
	# --nolen = turns off sequence length normalization, in combination with "--unit = ab" generates raw number of inserts mapped to each sequence
	# -o = name of output file
	
#done

#Step 3 - gunzip all results.profile output files
gunzip results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/*.gz


for file in results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/*.sam
do
	id=$(echo $(basename $file | sed 's/\.sam//g'))
	## Coverage - Msamtools version 1.1.3
	conda activate msamtools-1.1.3
	msamtools coverage --summary -o results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/${id}_coverage.txt.gz results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/${id}.bam
	gunzip results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/${id}_coverage.txt.gz
	conda deactivate
 
	rm -f results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/${id}.bam
	# coverage = estimates the coverage of each sequence
	# --summary = report fraction of sequence covered in % (instead of per-position coverage)
	# -o = name of output file
	
	## Presence - Custom script
	# matrix of presence/absence (1 = present, 0 = asbent)
	# input = coverage files generated through "msamtools coverage"
	# output = matrix of presence/absence : column1 = contig name, column2 = contig presence (1 = present, 0 = asbent)
	python /work_projet/metasimfood/metavirome/Article_fermented_commercial/scripts/code_test/presence_dico.py results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/${id}_coverage.txt 0.5 ./

	# 1 = coverage file from msamtools
	# 2 = coverage threshold
	# 3 = output path
	
	## Recalculating counts - Custom script
	# Recalculating the relative abundance after removing abundances for non-present contigs
	awk 'NR==FNR{a[$1]=$2; next} {print $1, (a[$1]==1) ? int($2 + 0.5) : 0}' results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/${id}_coverage_presence.csv <(tail -n +10 results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/results.profile_${id}_proportional.txt) > results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/${id}_counts_corrected.csv

	# 'NR==FNR{a[$1]=$2; next} = reading the first file ("coverage" file), store the value of the presence status (column 2) for each contig (column 1) in "a"
	# {print $1, (a[$1]==1) ? int($2 + 0.5) : 0} = print the contig name (column 1), then if the presence status is 1, the value in column 2 is value of column 2 in the second file ("counts" file) rounded, if the presence status is not 1, then the value in column 2 is 0
	# tail -n +10 = remove the first 10 first lines of the "counts" files, which are unnecessary metadata
	# note: we round to get "count"-like data without decimals, and the choice to round to nearest integer is to have a minimal difference with the real number of counts after rounding
done

########## Phyloseq integration - Custom script ##########

# Creating Phyloseq's "abundance matrix" = a dataframe with all the independant abundance files
# input = folder containing all the corrected abundance files generated by "data_ab_QLB2.py"
# output = 1 dataframe with all the samples and all the contigs and their corresponding abundance
conda activate pandas-1.5.3

cd results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/

python /work_projet/metasimfood/metavirome/Article_fermented_commercial/scripts/code_test/data_ab_QLB2.py

conda deactivate

# in case of error, check if the file names correspond to those used in the script (lines 12 and 25)


	



