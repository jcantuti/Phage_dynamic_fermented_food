#!/bin/bash
# Shell to be used for job execution
#$ -S /bin/bash
# job name
#$ -N contigs_traitement_sub
# q name
#$ -q short.q
# Export of environmental variables 
#$ -V
# Standard output
#$ -o log/contigs_traitement_sub.out
# Error output
#$ -e log/contigs_traitement_sub.err
# Use 32 CPUs
#$ -pe thread 32

## Rename sample of sequencing N°A0628
for file in results/Assembly/NG-A0628*; 
do
	sample=$(echo $(basename $file|sed 's/NG-A0628_//g'|sed 's/_lib.*//g'))
	python3 scripts/fasta_reader_rename.py ${file}/contigs.fasta ${sample} results/Assembly/${sample}_contigs.fasta;
	grep -c ">" ${file}/contigs.fasta | awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_assembled.txt
	grep -c ">" results/Assembly/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_sup2kb.txt
	head results/Assembly/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/First_contig_sup2kb.txt
done

for file in results/Assembly/sub_100k/NG-A0628*; 
do
	sample=$(echo $(basename $file|sed 's/NG-A0628_//g'|sed 's/_lib.*//g'))
	python3 scripts/fasta_reader_rename.py ${file}/contigs.fasta ${sample}_100k results/Assembly/sub_100k/${sample}_contigs.fasta;
	grep -c ">" ${file}/contigs.fasta | awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_assembled_sub_100k.txt
	grep -c ">" results/Assembly/sub_100k/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_sup2kb_sub100k.txt
	head results/Assembly/sub_100k/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/First_contig_sup2kb_sub100k.txt
done

for file in results/Assembly/sub_500k/NG-A0628*; 
do
	sample=$(echo $(basename $file|sed 's/NG-A0628_//g'|sed 's/_lib.*//g'))
	python3 scripts/fasta_reader_rename.py ${file}/contigs.fasta ${sample}_500k results/Assembly/sub_500k/${sample}_contigs.fasta;
	grep -c ">" ${file}/contigs.fasta | awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_assembled_sub_500k.txt
	grep -c ">" results/Assembly/sub_500k/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_sup2kb_sub500k.txt
	head results/Assembly/sub_500k/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/First_contig_sup2kb_sub500k.txt
done

for file in results/Assembly/sub_1000k/NG-A0628*; 
do
	sample=$(echo $(basename $file|sed 's/NG-A0628_//g'|sed 's/_lib.*//g'))
	python3 scripts/fasta_reader_rename.py ${file}/contigs.fasta ${sample}_1000k results/Assembly/sub_1000k/${sample}_contigs.fasta;
	grep -c ">" ${file}/contigs.fasta | awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_assembled_sub_1000k.txt
	grep -c ">" results/Assembly/sub_1000k/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_sup2kb_sub1000k.txt
	head results/Assembly/sub_1000k/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/First_contig_sup2kb_sub1000k.txt
done



## Rename sample of sequencing N°A1487
for file in results/Assembly/NG-A1487*; 
do
	sample=$(echo $(basename $file|sed 's/NG-A1487_//g'|sed 's/_lib.*//g'))
	python3 scripts/fasta_reader_rename.py ${file}/contigs.fasta ${sample} results/Assembly/${sample}_contigs.fasta;
	grep -c ">" ${file}/contigs.fasta | awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_assembled.txt
	grep -c ">" results/Assembly/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_sup2kb.txt
	head results/Assembly/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/First_contig_sup2kb.txt
done

for file in results/Assembly/sub_100k/NG-A1487*; 
do
	sample=$(echo $(basename $file|sed 's/NG-A1487_//g'|sed 's/_lib.*//g'))
	python3 scripts/fasta_reader_rename.py ${file}/contigs.fasta ${sample}_100k results/Assembly/sub_100k/${sample}_contigs.fasta;
	grep -c ">" ${file}/contigs.fasta | awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_assembled_sub_100k.txt
	grep -c ">" results/Assembly/sub_100k/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_sup2kb_sub100k.txt
	head results/Assembly/sub_100k/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/First_contig_sup2kb_sub100k.txt
done

for file in results/Assembly/sub_500k/NG-A1487*; 
do
	sample=$(echo $(basename $file|sed 's/NG-A1487_//g'|sed 's/_lib.*//g'))
	python3 scripts/fasta_reader_rename.py ${file}/contigs.fasta ${sample}_500k results/Assembly/sub_500k/${sample}_contigs.fasta;
	grep -c ">" ${file}/contigs.fasta | awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_assembled_sub_500k.txt
	grep -c ">" results/Assembly/sub_500k/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_sup2kb_sub500k.txt
	head results/Assembly/sub_500k/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/First_contig_sup2kb_sub500k.txt
done

for file in results/Assembly/sub_1000k/NG-A1487*; 
do
	sample=$(echo $(basename $file|sed 's/NG-A1487_//g'|sed 's/_lib.*//g'))
	python3 scripts/fasta_reader_rename.py ${file}/contigs.fasta ${sample}_1000k results/Assembly/sub_1000k/${sample}_contigs.fasta;
	grep -c ">" ${file}/contigs.fasta | awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_assembled_sub_1000k.txt
	grep -c ">" results/Assembly/sub_1000k/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/Nbre_contig_sup2kb_sub1000k.txt
	head results/Assembly/sub_1000k/${sample}_contigs.fasta |  awk -v var=${sample} '{print var "\t" $0}' >> results/stat/First_contig_sup2kb_sub1000k.txt
done






cat results/Assembly/*.fasta > results/Assembly/Master_contigs.fasta 
cat results/Assembly/sub_100k/*.fasta > results/Assembly/Master_contigs_100k.fasta
cat results/Assembly/sub_500k/*.fasta > results/Assembly/Master_contigs_500k.fasta
cat results/Assembly/sub_1000k/*.fasta > results/Assembly/Master_contigs_1000k.fasta

