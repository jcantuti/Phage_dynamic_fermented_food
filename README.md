# Evidence of active phage replication during vegetable fermentation and implications on the dynamics of bacterial communities

This workflow details the bioinformatics and statistical analysis presented in this research article: [link]

## Input files and directory

Raw sequencing data for fermented vegetables metagenomes and viromes were deposited at the Sequence Read Archive (SRA) of the NCBI as part of BioProject PRJNA1165654.

Directory containing the raw sequence data in fastq format, previously download from NCBI (BioProject PRJNA1165654): RAW_DATA/virome/ and RAW_DATA/metagenome/

Directory containing the reference genomes used for host decontamination in fna format: RAW_DATA/Reference_genome/

Directory containing all scripts: scripts/

Directory containing all results: results/

## Experimental results analysis
Experimental results were analysis using R studio of 2023_Spontaneous_fermentation.Rproj R project. Figures were saved in results/graph.

## Shotgun metagenomic analysis
### Taxonomy assignment of reads using Kaiju v.1.9.2
We did a taxonomy assignment of raw reads using Kaiju version 1.9.2 with the non-redundant prokaryotic and eukaryotic 2023-05 database. Here is an example of the command line for one sample:

```
conda activate kaiju-1.9.2
kaiju -t /db/outils/kaiju-2023-05/nr_euk/nodes.dmp -f /db/outils/kaiju-2023-05/nr_euk/kaiju_db_nr_euk.fmi -i RAW_DATA/metagenome/Sample1_R1.fastq -j RAW_DATA/metagenome/Sample1_R2.fastq -o results/Kaiju/kaiju_Sample1.out -z 16
kaiju2table -t /db/outils/kaiju-2023-05/nr_euk/nodes.dmp -n /db/outils/kaiju-2023-05/nr_euk/names.dmp -r genus -l superkingdom,phylum,class,order,family,genus,species -o results/Kaiju/kaiju_Sample1_summary.tsv results/Kaiju/kaiju_Sample1.out
conda deactivate
```
For run this commande line in all sample, we used ``` sh scripts/kaiju_metag.sh``` which creat and run ```scripts/run_kaiju_metag.sh``` et ```scripts/run_kaiju2table_sum_viruses.sh```

Kaiju results were further analyzed in R using the script Metagenome_analyses.Rmd to produced the final data presented in the article.

#### Assembly and MAGs reconstruction
Raw reads were processed using the SnakeMAGs version 1.1.1 workflow with default parameters, which enabled assembly and reconstruction of medium quality metagenome-assembled genomes (MAGs).
All samples were processed in parallel (note: temporary files can't be very heavy) using the following procedure:

Create a work directory (i.e:  ```/path/to/working/directory/```)
Copy in work directory these files:
a. SnakeMAGs.smk = tool pipeline (this file should not be modified)
b. config.yaml = configuration file. This file specifies the access paths, input files and parameters for each tools (should be edited by the user).
c. run_SnakeMAGs.sh = shell script to run the job (should be edited by the user for --configfile /path/to/working/directory/config.yaml)

We used this command line to run the script:
```sh run_SnakeMAGs.sh```
MAGs produced from each sample were renamed (to keep trace of their original sample) and merged in a single fasta file using the following procedure:
```
for i in results/SnakeMAGs/Sample1/*.fa 
do
id=$(echo $(basename $i | sed 's/\.fa//g'))
echo $id
awk -v id=$id '/^>/{print ">" "Sample1_" id "_" substr($0, 2); next}{print}' $i > results/SnakeMAGs/Sample1/Sample1_M_${id}.fa
done

for i in results/SnakeMAGs/Sample*/*.fa;
do
more ${i} >> results/SnakeMAGs/All_MAGS.fna;
done
```

## Viral metagenomic analysis
### Reads QC
For each sample, raw reads were quality checked using FastQC version 0.11.9, and the results were saved in results/FastQC_report. Here is the command line:
```
conda activate fastqc-0.11.9
fastqc /RAW_DATA/virome/Sample1_R1.fastq.gz -o results/FastQC_report/
fastqc /RAW_DATA/virome/Sample1_R2.fastq.gz -o results/FastQC_report/
conda deactivate
```
For run this commande line in all sample: ```scripts/sequencing_quality_control.sh```

#### Merging reads for samples sequenced twice
Sequence files were uncompressed and concatenated using the following command lines:
```
gunzip /RAW_DATA/virome/*.fastq.gz
mkdir results/stat/
for file in /RAW_DATA/virome/*_R1.fastq ; do sample=$(echo $(basename $file)); grep -c ^@ $sample | awk -v var=$sample '{print var "\t" $0}'; done > results/stat/Nbre_reads_raw_sequencing.txt
cat /RAW_DATA/virome/Sample1_sequencing1_R1.fastq /RAW_DATA/virome/Sample1_sequencing2_R1.fastq > /RAW_DATA/virome/Sample1_R1.fastq
cat /RAW_DATA/virome/Sample1_sequencing1_R2.fastq /RAW_DATA/virome/Sample1_sequencing2_R2.fastq > /RAW_DATA/virome/Sample1_R2.fastq
rm /RAW_DATA/virome/Sample1_sequencing1_R1.fastq
rm /RAW_DATA/virome/Sample1_sequencing2_R1.fastq
rm /RAW_DATA/virome/Sample1_sequencing1_R2.fastq
rm /RAW_DATA/virome/Sample1_sequencing2_R2.fastq
for file in /RAW_DATA/virome/*.fastq ; do sample=$(echo $(basename $file)); grep -c ^@ $sample | awk -v var=$sample '{print var "\t" $0}'; done > results/stat/Nbre_reads_after_conc.txt
```

#### Host decontamination
Host decontamination involved reads mapping against the genomes of Brassica oleracea var. oleracea (NCBI RefSeq GCF_000695525.1, GenBank assembly GCA_000695525.1) and Daucus carota subsp. sativus (NCBI RefSeq GCF_001625215.1, GenBank assembly GCA_001625215.1) using BWA version 0.7.17. The alignement was then processed using samtools version 1.12 and bedtools version 2.30.0 to discard reads aligning with the host genomes. We recorded the number of reads discarded. The procedure was embedded in the script ```scripts/reads_host_decontamination.sh```. The results were saved in ```results/Host_decontamination```.

Directory reference genome: 
```RAW_DATA/Reference_genome/```

Here is the command line used to run the script:

```
sh scripts/reads_host_decontamination.sh

for file in results/Host_decontamination/*.fastq ; do sample=$(echo $(basename $file)); grep -c ^@ $file | awk -v var=$sample '{print var "\t" $0}'; done > results/stat/
Nbre_reads_decontaminated.txt
```

#### Reads QC after decontamination

Quality control of the reads after decontamination was performed as described earlier using the following command lines (example for one sample):
```
conda activate fastqc-0.11.9
fastqc /results/Host_decontamination/Sample1_clean_R1.fastq -o fastqc_raw/
fastqc /results/Host_decontamination/Sample1_clean_R2.fastq -o fastqc_raw/
conda deactivate
```
For run this commande line in all sample: ```sh scripts/deconta_sequencing_quality_control.sh```

#### Reads quality-filtering
Decontaminated reads were quality-filtered using Trimmomatic version 0.39. The results were saved in ```results/Trimmomatic```. Illumina adapator sequences were provided as fasta file in RAW_DATA/TruSeq3-PE.fa. Here are the command lines used for one sample:
```
conda activate trimmomatic-0.39 
trimmomatic PE -phred33 results/Host_decontamination/Sample1_clean_R1.fastq results/Host_decontamination/Sample1_clean_R2.fastq results/Trimmomatic/Sample1_clean_R1_P.fq.gz results/Trimmomatic/Sample1_clean_R1_U.fq.gz results/Trimmomatic/Sample1_clean_R2_P.fq.gz results/Trimmomatic/Sample1_clean_R2_U.fq.gz RAW_DATA/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:125 -threads 32 
conda deactivate 
conda activate fastqc-0.11.9 && fastqc results/Trimmomatic/Sample1_clean_R1_P.fastq.gz -o results/Trimmomatic
```
For run this commande line in all sample: ```sh scripts/Trimming.sh```

#### Sub-sampling

Sub-sampling can improve the assembly quality of some contigs, in particular those that are very abundant in the dataset. Sub-sampling of the quality-filtered reads was performed for each sample using Seqtk version 1.3 at depths 100k (25000 1P + 25000 2P + reads 25000 1U + 25000 2U), 500k (150000 1P + 150000 2P + 100000 1U + 100000 2U) and 1000k (330000 1P + 330000 2P + 170000 1U + 170000 2U). The results were saved in the following directories : results/Trimmomatic/sub_100k results/Trimmomatic/sub_500k and results/Trimmomatic/sub_1000k. Here are the command lines used for subsampling one sample at depth 100k:
```
conda activate seqtk-1.3
seqtk sample -s100 results/Trimmomatic/Sample1_clean_R1_P.fq 25000 > results/Trimmomatic/sub_100k/Sample1_clean_sub_100k_R1_P.fq;
seqtk sample -s100 results/Trimmomatic/Sample1_clean_R1_U.fq 25000 > results/Trimmomatic/sub_100k/Sample1_clean_sub_100k_R1_U.fq;
seqtk sample -s100 results/Trimmomatic/Sample1_clean_R2_P.fq 25000 > results/Trimmomatic/sub_100k/Sample1_clean_sub_100k_R2_P.fq;
seqtk sample -s100 results/Trimmomatic/Sample1_clean_R2_U.fq 25000 > results/Trimmomatic/sub_100k/Sample1_clean_sub_100k_R2_U.fq;
conda deactivate
```

For run this commande line in all sample with all sub-sampling: ```sh scripts/Sub_sampling_assembly.sh```

#### Assembly

For each sample, quality filtered reads (without subsampling) as well as every subsampled read sets (100k, 400k and 700k) were assembled independantly using SPAdes version 3.15.3. The results were saved in ```results/Assembly/```. Here are examples of command lines used for this step:
```
#Example for Sample1 without subsampling:
conda activate spades-3.15.3
spades.py --only-assembler -t 32 -1 results/Trimmomatic/Sample1_clean_R1_P.fq -2 results/Trimmomatic/Sample1_clean_R2_P.fq -s results/Trimmomatic/Sample1_clean_R1_U.fq -s results/Trimmomatic/Sample1_clean_R2_U.fq -o results/Assembly/Sample1 -k 21,33,55,77,99,127
#Example for Sample1 subsampled at depht 100k:
conda activate spades-3.15.3
spades.py --only-assembler -t 32 -1 results/Trimmomatic/sub_100k/Sample1_clean_sub_100k_R1_P.fq -2 results/Trimmomatic/sub_100k/Sample1_clean_sub_100k_R2_P.fq -s results/Trimmomatic/sub_100k/Sample1_clean_sub_100k_R1_U.fq -s results/Trimmomatic/sub_100k/Sample1_clean_sub_100k_R2_U.fq -o results/Assembly/sub_100k/Sample1 -k 21,33,55,77,99,127
```
For run this commande line in all sample with all sub-sampling: scripts/assembly_sub.sh

After assembly, contigs were renamed to keep the information of their original sample and subsampling level, and those with a size higher than 2kb were selected. Finally, selected contigs from all samples were merged in one fasta file ```results/Assembly/Master_contigs.fasta```. This was achieved by the ```script contigs_traitement_sub.sh```, which require the python script ```fasta_reader_rename.py```. Here is the command line to run this script:
```
sh scripts/contigs_traitement_sub.sh
```
#### Clustering of contigs into species-level vOTUs

Clustering of contigs into species-level vOTUs was achieved according to the procedure developped by Shiraz Sha with some modifications. The procedure was embedded in the script ```script_dereplication_contigs_by_blat_sub.sh``` and requires BLAT version 36 and the scripts ```hashsums, joincol, aggregate.py, fasta_reader_select_P3.py``` and ```contig_file_length.py```. The outpout is a fasta file containing the representative sequences of each cluster: ```results/Dereplication/contigs_derep.fasta```. The following command line was used to run the script:
```
sh scripts/script_dereplication_contigs_by_blat_sub.sh
```

#### Selection of viral contigs and host prediction

The selection of viral contigs was performed using a combination of VIBRANT version 1.2.1, VirSorter2 version 2.2.4, and CheckV version 0.8.1. Contigs were selected if they meet at least one of the following criteria: declared “complete”, “high” or “medium” quality by either VIBRANT or CheckV, declared “full” by VirSorter2. Then Iphop version 1.3.3 was used to predict host of viral contigs. All command lines were embedded in the script script_identification_of_viral_contigs.sh. The output is a fasta file containing the sequences of the viral contigs (vOTUs): ```results/Viral_prediction/VIRAL_CONTIGS/viral_contigs.fasta```. The following command line was used to run the script:

```
sh scripts/script_identification_of_viral_contigs_sub.sh
```

#### Production of a vOTU abundance table
Quality-filtered reads were mapped against the viral contigs using bwa-mem2 version 2.2.1. Raw counts were extracted using samtools version 1.9 and msamtools version 1.1.3. All command lines were embedded in the script ```mapping_viral_contigs.sh``` and require the scripts ```presence_dico.py function.py and data_ab_QLB2.py```. The vOTU abundance table was save as a csv file: ```results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/presence_counts.csv```. The following command line was used to run the script:
```
sh scripts/mapping_viral_contigs.sh
```

Alignments were filtered to retain contigs for which there is sufficient proof of presence, using msamtools v1.1.3 (Arumugam). Firstly, msamtools filter was used toonly keep those with a minimum length of alignment of 80, minimum sequence identity of alignment of 95, and minimum percent of the query that must be aligned 80 and with --besthit option. Then, msamtools coverage estimates the coverage of each sequence, and the --summary option reports the fraction of sequence covered in percentage. Then alignments with more than 50% of horizontal coverture were kept to construct the final abundance tables using data_ab_QLB2.py from Quentin Lamy--Besnier (INRAE, Jouy-en-Josas)
This last script return csv file: ```presence_count.csv``` corresponding to abundance table of vOTUs in each samples.

We deleted the second and third raw of the abundance table which does not correspond to vOTUs:
```sed -i '2,3d' presence_counts.csv``` 

#### Statistical analysis of the vOTU abundance table and vizualisation

The vOTU abundance table was further processed in R using the scripts Metavirome_analyses.Rmd  which are mainly based on the package phyloseq version 1.48.0. The results were saved in results/Phyloseq_analysis (tables, R objects) and results/graph (figures).


