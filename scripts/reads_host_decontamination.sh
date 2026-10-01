#!/bin/bash

#Host genome indexation
conda activate bwa-0.7.17; conda activate samtools-1.12 --stack 
bwa index RAW_DATA/Reference_genome/GCF_000695525.1_BOL_genomic.fna
bwa index RAW_DATA/Reference_genome/GCA_001625215.1_ASM162521v1_genomic.fna

#Cabbage reference genome : GCF_000695525.1_BOL_genomic.fna
#Carrot reference genome : GCA_001625215.1_ASM162521v1_genomic.fna




# Reads mapping  reference genome
# Code from book: The plant microbiome methods and protocols, Lilia C. Carvalhais and Paul G. Dennis, Methods in Molecular Biology,2021 ISBN 978-1-0716-1039-8
# We use the read mapping tool BWA to align metagenomic sequences to the reference genome. The alignment output is first piped to “samtools view” for formatting as a bam file, and subsequently piped to “samtools sort” for sorting entries by read coordinates. The second command below “samtools view” filters the alignment output file for read pairs (primary alignments) that were not mapped to the host genome. Reads are retained or discarded via the “-f” and “-F” options, respectively, in SAMtools. In the following command, “-f 12” tells SAMtools to retain unmapped sequence pairs, and “-F 256” to discard non-primary alignments. The filtered alignment output is then converted to fastq read files using BEDTools.

# --stack allow to activate more than 1 conda environment
# samtools view -Subh - 
	# - S		Ignored for compatibility with previous samtools versions. Previously this option was required if input was in SAM format, but now the correct format is automatically detected by examining the first few characters of input. 
	# -u		Output uncompressed data. This also changes the default output format to BAM, but this can be overridden by the explicit format options or using a filename with a known suffix. This option saves time spent on compression/decompression and is thus preferred when the output is piped to another samtools command. 
	# -b		Output in the BAM format.
	# -h		Include the header in the output. 
	# -f 		Only output alignments with all bits set in FLAG present in the FLAG field. FLAG can be specified in hex by beginning with `0x' (i.e. /^0x[0-9A-F]+/), in octal by beginning with `0' (i.e. /^0[0-7]+/), as a decimal number not beginning with '0' or as a comma-separated list of flag names.
	# -F		Do not output alignments with any bits set in FLAG present in the FLAG field. FLAG can be specified in hex by beginning with `0x' (i.e. /^0x[0-9A-F]+/), in octal by beginning with `0' (i.e. /^0[0-7]+/), as a decimal number not beginning with '0' or as a comma-separated list of flag names. For a list of flag names see samtools-flags(1). 
# samtools sort 
	# -m 		Approximately the maximum required memory per thread, specified either in bytes
	# -@		Set number of sorting and compression threads. By default, operation is single-threaded.


##Cabbage decontamination ##

conda activate bwa-0.7.17; conda activate samtools-1.12 --stack ; conda activate bedtools-2.30.0 --stack ; conda activate bwa-mem2-2.2.1 --stack ; for file in RAW_DATA/virome/Cabbage/*_1.fastq; do sample=$(echo $(basename $file|sed 's/_.\.fastq//g')); bwa mem -t 32 RAW_DATA/Reference_genome/GCF_000695525.1_BOL_genomic.fna $file RAW_DATA/virome/Cabbage/${sample}_2.fastq |samtools view -Subh - | samtools sort -m 2G -@ 4 - |samtools view -b -f 12 -F 256 - | bedtools bamtofastq -i - -fq results/Host_decontamination/${sample}_clean_R1.fastq -fq2 results/Host_decontamination/${sample}_clean_R2.fastq;done


##Carrot decontamination ##

conda activate bwa-0.7.17; conda activate samtools-1.12 --stack ; conda activate bedtools-2.30.0 --stack ; conda activate bwa-mem2-2.2.1 --stack ; for file in RAW_DATA/virome/Carrot/*_1.fastq; do sample=$(echo $(basename $file|sed 's/_.\.fastq//g')); bwa mem -t 32 RAW_DATA/Reference_genome/GCA_001625215.1_ASM162521v1_genomic.fna $file RAW_DATA/virome/Carrot/${sample}_2.fastq |samtools view -Subh - | samtools sort -m 2G -@ 4 - |samtools view -b -f 12 -F 256 - | bedtools bamtofastq -i - -fq results/Host_decontamination/${sample}_clean_R1.fastq -fq2 results/Host_decontamination/${sample}_clean_R2.fastq;done

###Complete host decontamination of control###

mkdir results/Host_decontamination/control_1
conda activate bwa-0.7.17; conda activate samtools-1.12 --stack ; conda activate bedtools-2.30.0 --stack ; conda activate bwa-mem2-2.2.1 --stack ; for file in RAW_DATA/virome/Control/*_1.fastq; do sample=$(echo $(basename $file|sed 's/_.\.fastq//g')); bwa mem -t 32 RAW_DATA/Reference_genome/GCF_000695525.1_BOL_genomic.fna $file RAW_DATA/virome/Control/${sample}_2.fastq |samtools view -Subh - | samtools sort -m 2G -@ 4 - |samtools view -b -f 12 -F 256 - | bedtools bamtofastq -i - -fq results/Host_decontamination/control_1/${sample}_1.fastq -fq2 results/Host_decontamination/control_1/${sample}_2.fastq;done

conda activate bwa-0.7.17; conda activate samtools-1.12 --stack ; conda activate bedtools-2.30.0 --stack ; conda activate bwa-mem2-2.2.1 --stack ; for file in results/Host_decontamination/control_1/*_1.fastq; do sample=$(echo $(basename $file|sed 's/_.\.fastq//g')); bwa mem -t 32 RAW_DATA/Reference_genome/GCA_001625215.1_ASM162521v1_genomic.fna $file results/Host_decontamination/control_1/${sample}_2.fastq |samtools view -Subh - | samtools sort -m 2G -@ 4 - |samtools view -b -f 12 -F 256 - | bedtools bamtofastq -i - -fq results/Host_decontamination/${sample}_1.fastq -fq2 results/Host_decontamination/${sample}_2.fastq;done


conda deactivate
