2024_Virome_of spontaneous fermentation of cabbage and carrot at Laboratory

Mini fermentation of cabbage and carrot did at laboratory.
Sampling did à day 0, 2, 7, 21 and 28 in triplicate
Viromes were extracted for each sample.
The DNA was extracted and amplified by Qiagen Repli-G REPLI-g Single Cell Kit.
We will access anly to ds and ssDNA viruses.
Nomenclature of raw data name: SA_OA_V
SA => Sauerkraut (Cabbage)
CA => Carrot

0A => Sampling day 0 replicat A
0B => Samppling day 0 replicat B
OC => Samppling day 0 replicat C

V => Virome sample

Work directory:
/work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/

## Sequencing quality control 
The quality of the sequencing is control for all samples with fastQC report and then summary by multiQC
```
chmod u+x scripts/sequencing_quality_control.sh
sh scripts/sequencing_quality_control.sh
``` 
### Reads count
```
mkdir /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/stat/

for file in /save_projet/metasimfood/metavirome_data/0_raw_fastq/Spontaneous_fermentation/Control/*.fastq ; do sample=$(echo $(basename $file)); grep -c ^@ $file | awk -v var=$sample '{print var "\t" $0}'; done > /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/stat/Nbre_reads_raw_sequencing_control.txt

for file in /save_projet/metasimfood/metavirome_data/0_raw_fastq/Spontaneous_fermentation/Cabbage/*.fastq ; do sample=$(echo $(basename $file)); grep -c ^@ $file | awk -v var=$sample '{print var "\t" $0}'; done > /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/stat/Nbre_reads_raw_sequencing_cabbage.txt

for file in /save_projet/metasimfood/metavirome_data/0_raw_fastq/Spontaneous_fermentation/Carrot/*.fastq ; do sample=$(echo $(basename $file)); grep -c ^@ $file | awk -v var=$sample '{print var "\t" $0}'; done > /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/stat/Nbre_reads_raw_sequencing_carrot.txt

cat results/stat/Nbre_reads_raw_sequencing_control.txt results/stat/Nbre_reads_raw_sequencing_cabbage.txt results/stat/Nbre_reads_raw_sequencing_carrot.txt results/stat/Nbre_reads_raw_sequencing_turnip.txt > Nbre_reads_raw_sequencing_samples.txt
```

## Host decontamination
We remove all reads that match to cabbage and carrot genome in order to eliminate host genome for a better assembly.
For cabbage the host genome is Brassica oleracea var. oleracea genome NCBI RefSeq GCF_000695525.1, GenBak assembly GCA_000695525.1. Sequencing date May 27, 2014.
For the carrots samples the reference genome is Daucus carota subsp. sativus  NCBI RefSeq GCF_001625215.1, GenBak assembly GCA_001625215.1. Sequencing date May 6, 2016

Each reads were aligned against the reference genome by command ligne extracted from the book : The plant microbiome methods and protocols, Lilia C. Carvalhais and Paul G. Dennis, Methods in Molecular Biology,2021 ISBN 978-1-0716-1039-8

Then we control the reads number of each sample to identify the proportion of host reads discarded

Directory reference genome: 
/save_projet/metasimfood/metavirome_data/Reference_genome/

/save_projet/metasimfood/metavirome_data/0_raw_fastq/Spontaneous_fermentation/Carrot


Directory run script: 
/work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/
```
mkdir results/Host_decontamination

chmod u+x scripts/reads_host_decontamination.sh
qsub -N reads_host_decontamination -q short.q -V -o log/reads_host_decontamination.out -e log/reads_host_decontamination.err -cwd -pe thread 32 scripts/reads_host_decontamination.sh

for file in results/Host_decontamination/*.fastq ; do sample=$(echo $(basename $file)); grep -c ^@ $file | awk -v var=$sample '{print var "\t" $0}'; done > results/stat/Nbre_reads_decontaminated.txt
``` 
## Sequencing quality control 
The quality of the sequencing is control for all samples with fastQC report and then summary by multiQC
```
chmod u+x scripts/deconta_sequencing_quality_control.sh
sh scripts/deconta_sequencing_quality_control.sh
``` 
## Reads cleaning with Trimmomatic and quality control
Dowload the Illumina adaptator file (TruSeq3-PE.fa) into the directory: 
/save_projet/metasimfood/metavirome_data/

Read with bad quality and the adaptator were remove from each sample fastq file by trimmomatic, to improve the assembly quality.
```
chmod u+x scripts/Trimming.sh
sh scripts/Trimming.sh

chmod u+x scripts/trimming_quality_control.sh
sh scripts/trimming_quality_control.sh
```

##Sub-sampling
#Sub-sampling can improve assembly of some contigs, in particular those that are very abundant in the dataset. Sub-sampling was performed using seqtk version 1.3 
to 1000k, 500k and 100k trimmed reads per triplicate sample, and results were stored in Trim/sub/ directory. Here is an example for subsampling 400k reads (110,000 1P + 110,000 2P + 90,000 1U + 90,000 1U) 
```
chmod u+x scripts/Sub_sampling_assembly.sh
qsub scripts/Sub_sampling_assembly.sh
```

## Assembly with SPAdes
For each samples, reads were assembly in contigs by SPAdes tool.
```
chmod u+x scripts/assembly_sub.sh
sh scripts/assembly_sub.sh

```
## Contigs rename and select contigs > 2kb
After assembly, contigs were rename to beginning with the sample name by the script fasta_reader_rename.py, then we retains only contigs with a size higher than 2kb.
Finally all contigs were concatenated into one fasta file.
```

chmod u+x scripts/contigs_traitement_sub.sh
qsub scripts/contigs_traitement_sub.sh

cat Master_contigs_100k.fasta Master_contigs_500k.fasta Master_contigs_1000k.fasta Master_contigs.fasta > Master_contigs_sub.fasta
```
## Dereplicate
Dereplication is the reduction of a set of contigs, based on high sequence similarity between these contigs.

```
chmod u+x scripts/script_dereplication_contigs_by_blat_sub.sh
qsub scripts/script_dereplication_contigs_by_blat_sub.sh
```
## Identification of viral contigs
```

chmod u+x scripts/script_identification_of_viral_contigs_sub.sh
qsub scripts/script_identification_of_viral_contigs_sub.sh

sed -i -e "s/_fragment_*//g" List_contigs_union.txt
```
## Mapping on all contigs per sample
```
chmod u+x scripts/concatenation_contigs.sh
qsub scripts/concatenation_contigs.sh

==> Les fichiers R1, R2, U1 et U2 sont rassembler dans le même fichier pour le mapping
mkdir results/Trimmomatic/reads_mapping/
cd results/Trimmomatic; for i in $(ls | grep '\.fq$' | sed 's/NG-30762_//g'|sed 's/_lib.*//g' | sort -u); do cat *_${i}*.fq >> reads_mapping/${i}.fastq ; done 
cd results/Trimmomatic; for i in $(ls | grep '\.fq$' | sed 's/NG-32537_//g'|sed 's/_lib.*//g' | sort -u); do cat *_${i}*.fq >> reads_mapping/${i}.fastq ; done 
cd results/Trimmomatic; for i in $(ls | grep '\.fq$' | sed 's/NG-A0045_//g'|sed 's/_lib.*//g' | sort -u); do cat *_${i}*.fq >> reads_mapping/${i}.fastq ; done 
cd results/Trimmomatic; for i in $(ls | grep '\.fq$' | sed 's/NG-A1487_//g'|sed 's/_lib.*//g' | sort -u); do cat *_${i}*.fq >> reads_mapping/${i}.fastq ; done 

chmod u+x scripts/mapping_all_contigs.sh
qsub scripts/mapping_all_contigs.sh

head results/Viral_prediction/VIRAL_CONTIGS/MAPPING_BWA-MEM2/results.profile* > /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/stat/mapping_all_results.txt

```

## Mapping on Viral contigs
```
mkdir results/Trimmomatic/reads_mapping/
cd results/Trimmomatic; for i in $(ls | grep '\.fq$' | sed 's/NG-A0628_//g'|sed 's/_lib.*//g' | sort -u); do cat *_${i}*.fq >> reads_mapping/${i}.fastq ; done 
cd results/Trimmomatic; for i in $(ls | grep '\.fq$' | sed 's/NG-A1487_//g'|sed 's/_lib.*//g' | sort -u); do cat *_${i}*.fq >> reads_mapping/${i}.fastq ; done 

chmod u+x scripts/mapping_viral_contigs.sh
qsub scripts/mapping_viral_contigs.sh

head results.profile* > /work_projet/metasimfood/metavirome/2024_/results/stat/mapping_viraux_results.txt
```
## Blast of vOTUs against nt et ICTV database
```
qsub -N Blast_vOTU_viral_nt -q short.q -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation -V -o log/Blast_vOTU_nr_viral.out -e log/Blast_vOTU_nr_viral.err -pe thread 32 -b y "conda activate blast-2.15.0 && blastn -db /db/nt/current/blast/nt -taxids 10239 -query results/Viral_prediction/VIRAL_CONTIGS/viral_contigs.fasta -out results/BLAST/vOTUs_viral_nt.txt -max_target_seqs 5 -num_threads 32 -outfmt \"6 delim=, qseqid qlen sseqid slen length mismatch gapopen qstart qend sstart send evalue bitscore pident qcovs qcovus staxid stitle\" && conda deactivate"

qsub -N Blast_vOTU_ICTV -q short.q -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation -V -o log/Blast_vOTU_ICTV.out -e log/Blast_vOTU_ICTV.err -pe thread 32 -b y "conda activate blast-2.13.0 && blastn -db ~/save/VIRAL_GENOMES/gb_vmr.fna -query results/Viral_prediction/VIRAL_CONTIGS/viral_contigs.fasta -out results/BLAST/vOTU_Vs_ICTV.txt -max_target_seqs 5 -num_threads 32 -outfmt \"6 delim=, qseqid qlen sseqid slen length mismatch gapopen qstart qend sstart send evalue bitscore pident qcovs qcovus staxid stitle\" "
```

#Metagenomic
## MAGs 
```
mkdir results/SnakeMAGs
mkdir results/SnakeMAGs/cluster_logs
mkdir results/SnakeMAGs/LOGS
mkdir results/SnakeMAGs/raw_reads/

qsub -cwd -V -N SnakeMAGs -e LOGS/ -o LOGS/ -q short.q -pe thread 10 run_SnakeMAGs.sh

5582790 
```
# Boucle pour renommer par échantillon les sequences des MAGs
```
for i in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/Cabbage/SA_*/MAGs/*.fa
do
id=$(basename "$(dirname "$(dirname "$i")")")
id_fasta=$(echo $(basename $i | sed 's/\.fa//g'))
bin=$(basename "$i" | sed -n 's/^bin\.\([0-9]\+\)\.fa$/\1/p')
mkdir /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/Cabbage/$id/renamed_MAG
awk -v id=$id -v bin=$bin '/^>/{print ">" id "_" bin "_" substr($0, 2); next}{print}' $i > /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/Cabbage/$id/renamed_MAG/${id}_${id_fasta}.fa;
done

for i in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/CA_*/MAGs/*.fa
do
id=$(basename "$(dirname "$(dirname "$i")")")
id_fasta=$(echo $(basename $i | sed 's/\.fa//g'))
bin=$(basename "$i" | sed -n 's/^bin\.\([0-9]\+\)\.fa$/\1/p')
mkdir /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/$id/renamed_MAG
awk -v id=$id -v bin=$bin '/^>/{print ">" id "_" bin "_" substr($0, 2); next}{print}' $i > /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/$id/renamed_MAG/${id}_${id_fasta}.fa;
done

for i in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/Carrot/CA_*/renamed_MAG/*.fa;
do
more ${i} >> /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/Carrot/All_MAGS.fna;
done


for i in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/Cabbage/SA_*/renamed_MAG/*.fa;
do
more ${i} >> /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/Cabbage/All_MAGS.fna;
done
```
# Boucle pour renommer par échantillon les sequences des bins
```
for i in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/*/Bins/*.fa
do
id=$(basename "$(dirname "$(dirname "$i")")")
id_fasta=$(echo $(basename $i | sed 's/\.fa//g'))
bin=$(basename "$i" | sed -n 's/^bin\.\([0-9]\+\)\.fa$/\1/p')
mkdir /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/$id/renamed_Bin
awk -v id=$id -v bin=$bin '/^>/{print ">" id "_" bin "_" substr($0, 2); next}{print}' $i > /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/$id/renamed_Bin/${id}_${id_fasta}.fa;
done

for i in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/*/renamed_Bin/*.fa;
do
more ${i} >> /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/All_Bin.fna;
done
```
#Prophage identification by Genomade (genomad-1.7.4)
```
mkdir /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/GENOMAD/

qsub -N Genomad -q short.q -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/ -V -o log/Genomad.out -e log/Genomad.err -pe thread 32 -b y "conda activate genomad-1.7.4 && genomad end-to-end --cleanup --splits 8 /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/All_Bin.fna /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/GENOMAD/ /db/outils/genomad-1.7.4/genomad_db/ && conda deactivate"


qsub -N Genomad -q short.q -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/ -V -o log/Genomad.out -e log/Genomad.err -pe thread 32 -b y "conda activate genomad-1.7.4 && genomad end-to-end --cleanup --splits 8 /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/All_MAGS.fna /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/GENOMAD/All_MAGs/ /db/outils/genomad-1.7.4/genomad_db/ && conda deactivate"


### Carrot
qsub -N Genomad -q short.q -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/ -V -o log/Genomad.out -e log/Genomad.err -pe thread 32 -b y "conda activate genomad-1.7.4 && genomad end-to-end --cleanup --splits 8 /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/Carrot/All_MAGs/All_MAGs_carrot.fasta /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/GENOMAD/All_MAGs_carrot/ /db/outils/genomad-1.7.4/genomad_db/ && conda deactivate"

### Cabbage

qsub -N Genomad -q short.q -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/ -V -o log/Genomad.out -e log/Genomad.err -pe thread 32 -b y "conda activate genomad-1.7.4 && genomad end-to-end --cleanup --splits 8 /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/Cabbage/All_MAGs/All_MAGs_cabbage.fasta /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/GENOMAD/All_MAGs_cabbage/ /db/outils/genomad-1.7.4/genomad_db/ && conda deactivate"


```





### Recherche de la présence de prophage dans nos viromes
```
qsub -N Blast_prophage_virome_carrot -q short.q -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/ -V -o log/Blast.out -e log/Blast.err -pe thread 32 -b y "conda activate blast-2.13.0 && makeblastdb -in results/Viral_prediction/VIRAL_CONTIGS/viral_contigs.fasta -dbtype nucl && blastn -db results/Viral_prediction/VIRAL_CONTIGS/viral_contigs.fasta -query results/GENOMAD/results_MAGs_carrotseq_MAGs_selected_provirus.fna -out /work_projet/metasimfood/metavirome/metagenome/BLAST/Provirus_Vs_virome_carrot.txt -max_target_seqs 5 -num_threads 32 -outfmt \"6 delim=, qseqid qlen sseqid slen length mismatch gapopen qstart qend sstart send evalue bitscore pident qcovs qcovus staxid stitle\" "

results/GENOMAD/results_MAGs_carrotseq_MAGs_selected_provirus.fna

qsub -N Blast_prophage_prophage -q short.q -wd /work_projet/metasimfood/metavirome/metagenome/ -V -o LOGS/Blast_prov-prov.out -e LOGS/Blast_prov-prov.err -pe thread 32 -b y "conda activate blast-2.13.0 && blastn -db /work_projet/metasimfood/metavirome/metagenome/GENOMAD/All_provirus.fna -query /work_projet/metasimfood/metavirome/metagenome/GENOMAD/All_provirus.fna -out /work_projet/metasimfood/metavirome/metagenome/BLAST/Blast_provirus_vs_provirus.txt -max_target_seqs 5 -num_threads 32 -outfmt \"6 delim=, qseqid qlen sseqid slen length mismatch gapopen qstart qend sstart send evalue bitscore pident qcovs qcovus staxid stitle\" "

### Carrot
qsub -N Blast_prophage_virome_carrot -q short.q -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/ -V -o log/Blast_prophage_carrot_virome.out -e log/Blast_prophage_carrot_virome.err -pe thread 32 -b y "conda activate blast-2.13.0 && makeblastdb -in results/Viral_prediction/VIRAL_CONTIGS/viral_contigs.fasta -dbtype nucl && blastn -db results/Viral_prediction/VIRAL_CONTIGS/viral_contigs.fasta -query results/GENOMAD/All_MAGs_carrot/Provirus_carrot.fasta -out /work_projet/metasimfood/metavirome/metagenome/BLAST/20250207_Provirus_Vs_virome_carrot.txt -max_target_seqs 5 -num_threads 32 -outfmt \"6 delim=, qseqid qlen sseqid slen length mismatch gapopen qstart qend sstart send evalue bitscore pident qcovs qcovus staxid stitle\" "

results/GENOMAD/All_MAGs_carrot


conda activate blast-2.13.0
makeblastdb -in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/GENOMAD/All_MAGs_carrot/Provirus_carrot.fasta -dbtype nucl
makeblastdb -in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/GENOMAD/All_MAGs_cabbage/Provirus_cabbage.fasta -dbtype nucl

blastn -db /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/GENOMAD/All_MAGs_carrot/Provirus_carrot.fasta -query results/Viral_prediction/VIRAL_CONTIGS/viral_contigs.fasta -out results/BLAST/Balstn_Virome_Vs_provirus_carrot.txt -max_target_seqs 5 -num_threads 32 -outfmt "6 delim=, qseqid qlen sseqid slen length mismatch gapopen qstart qend sstart send evalue bitscore pident qcovs qcovus staxid stitle"

blastn -db /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/GENOMAD/All_MAGs_cabbage/Provirus_cabbage.fasta -query results/Viral_prediction/VIRAL_CONTIGS/viral_contigs.fasta -out results/BLAST/Balstn_Virome_Vs_provirus_cabbage.txt -max_target_seqs 5 -num_threads 32 -outfmt "6 delim=, qseqid qlen sseqid slen length mismatch gapopen qstart qend sstart send evalue bitscore pident qcovs qcovus staxid stitle"


```



## Kaiju metagenomic
```
chmod u+x scripts/kaiju_metag.sh
sh scripts/kaiju_metag.sh
```


## Virome annotation 
```
mkdir results/Pharokka/
conda activate pharokka-1.1.0
pharokka.py -i results/Viral_prediction/VIRAL_CONTIGS/CA_28A_V_100k_NODE_1.fasta -o results/Pharokka/CA_28A_V_100k_NODE_1 -d /db/outils/pharokka-1.1.0/pharokka_database_v1.0.0 -f -t 32

pharokka.py -i results/Viral_prediction/VIRAL_CONTIGS/Fasta/SA_2A_V_500k_NODE_3_length_40436_cov_7.423801.fasta -o results/Pharokka/SA_2A_V_500k_NODE_3 -d /db/outils/pharokka-1.1.0/pharokka_database_v1.0.0 -f -t 32

pharokka.py -i results/Viral_prediction/VIRAL_CONTIGS/Fasta/CA_0A_V_NODE_96_length_46809_cov_22.248661.fasta -o results/Pharokka/CA_0A_V_NODE_96 -d /db/outils/pharokka-1.1.0/pharokka_database_v1.0.0 -f -t 32

conda deactivate

````



### Calcul ANI of MAGs
fastani-1.34

=> Faire une boucle pour chaque MAGs, le comparé au multifasta

fastANI -q MAG1.fasta -r MAG2.fasta -o output.txt
fastANI -q MAG1.fasta --rl list_MAG.txt -o output.txt

Par rapport au résultats ANI, 4 MAGs sont ressortie pour les échantillons de carotte. Les MAGs les plus long ont été sélectionné comme référent pour la suite des analyses. 

```
mkdir results/fastANI

for i in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/*/renamed_MAG/*.fa
do
echo $i >> /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/List_MAGs_2.txt;
done

conda activate fastani-1.34
for i in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/*/renamed_MAG/*.fa
do
id_fasta=$(echo $(basename $i | sed 's/\.fa//g'));
fastANI -q $i --rl /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/List_MAGs_2.txt -o /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/fastANI/$id_fasta.txt;
done

cat results/fastANI/CA* > results/fastANI/fast_ANI_carrot.txt
cat results/fastANI/SA* > results/fastANI/fast_ANI_cabbage.txt

conda activate python-3.11.7
chmod +x scripts/fastani_to_matrix.py
python3 scripts/fastani_to_matrix.py results/fastANI/fast_ANI_carrot.txt results/fastANI/fast_ANI_carrot_matrix.csv

python3 scripts/fastani_to_heatmap.py results/fastANI/fast_ANI_carrot_matrix.csv results/fastANI/heatmap_carrot.png

```

qsub -N Blast_prophage_prophage -q short.q -wd /work_projet/metasimfood/metavirome/metagenome/ -V -o LOGS/Blast_prov-prov.out -e LOGS/Blast_prov-prov.err -pe thread 32 -b y "conda activate blast-2.13.0 && blastn -db /work_projet/metasimfood/metavirome/metagenome/GENOMAD/All_provirus.fna -query /work_projet/metasimfood/metavirome/metagenome/GENOMAD/All_provirus.fna -out /work_projet/metasimfood/metavirome/metagenome/BLAST/Blast_provirus_vs_provirus.txt -max_target_seqs 5 -num_threads 32 -outfmt \"6 delim=, qseqid qlen sseqid slen length mismatch gapopen qstart qend sstart send evalue bitscore pident qcovs qcovus staxid stitle\" "



### Déréplication des MAGs avec dRep
```
## Copier tous les MAGS dans un seul dossier pour les dérépliquer

mkdir results/SnakeMAGs/results/Carrot/All_MAGs
for i in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/Carrot/*/renamed_MAG/*.fa
do
cp $i /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/Carrot/All_MAGs/;
done

mkdir results/SnakeMAGs/results/Cabbage/All_MAGs
for i in /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/Cabbage/*/renamed_MAG/*.fa
do
cp $i /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/Cabbage/All_MAGs/;
done 

## Lancer l'outil dRep
mkdir results/dRep
conda activate drep-3.5.0
dRep dereplicate results/dRep/MAGs_3 -g results/SnakeMAGs/results/Carrot/All_MAGs/*.fa --completeness 50 --contamination 10

dRep dereplicate results/dRep/MAGs_cabbage -g results/SnakeMAGs/results/Cabbage/All_MAGs/*.fa --completeness 50 --contamination 10
conda deactivate

### Une fois les MAGs dérépliqué

cp results/dRep/MAGs_cabbage/dereplicated_genomes/* /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/results/Cabbage/Ref_MAGs/


```

## Mapping on read on MAGs
```
#Concatenation des fichiers R1 et R2 dans un même fichier fastq
cd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/results/SnakeMAGs/reads_mapping/
for i in $(ls | grep '\.fastq$' | sed 's/NG-A2640_//g'|sed 's/_lib.*//g' | sort -u); do cat *_${i}*.fastq >> ${i}.fastq ; done 

#commande pour zipper les fastq une fois qu'ils sont concaténé
qsub -N unzip -q short.q -wd /work_projet/metasimfood/metavirome/2024_spontaneous_fermentation/ -V -o log/unzip.out -e log/unzip.err -pe thread 10 -b y " gzip results/SnakeMAGs/reads_mapping/NG-A2640* "

#Commande de mapping contre les génomes de référence
chmod u+x scripts/mapping_metag_MAGs_carrot.sh
qsub scripts/mapping_metag_MAGs_carrot.sh

chmod u+x scripts/mapping_metag_MAGs_cabbage.sh
qsub scripts/mapping_metag_MAGs_cabbage.sh
```



