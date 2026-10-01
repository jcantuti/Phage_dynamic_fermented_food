#!/bin/bash
# Shell Ã  utiliser pour l'exÃ©cution du job
#$ -S /bin/bash
# Nom du job
#$ -N dereplication
# Nom de la queue
#$ -q short.q
# Export de toutes les variables d'environnement
#$ -V
# Sortie standard
#$ -o log/dereplication_sub.out
# Sortie dâ€™erreur
#$ -e log/dereplication_sub.err
# Utiliser 16 CPUs
#$ -pe thread 16


#Master_contigs_sub.fasta


# Step 1: pairwise alignment of contigs by blat
mkdir results/Dereplication/
conda activate blat-36
blat results/Assembly/Master_contigs_sub.fasta results/Assembly/Master_contigs_sub.fasta results/Dereplication/contigs.all.blat -out=blast8
conda deactivate

# Step 2: create filelength file (one-liner using BioPython, first argument  is your fasta input file, and the second argument is your output)
conda activate biopython-1.79
chmod u+x scripts/contig_file_length.py
python3 scripts/contig_file_length.py results/Assembly/Master_contigs_sub.fasta results/Dereplication/contig_lengths.tab
conda deactivate

# Step 3: create the list of chimeras
chmod u+x scripts/hashsums
chmod u+x scripts/joincol

cut -f1,2,4 results/Dereplication/contigs.all.blat | ./scripts/hashsums | awk '$1 == $2' | ./scripts/joincol results/Dereplication/contig_lengths.tab | awk '{if ($3/$4 >= 1.1) print $1}' > results/Dereplication/List_chimeras.tab

# cut -f1,2,4 = only keeps query, subject and the alignment lenght columns
# hashsums = sums all the alignment lengths for the same query/subject pair = gives us the length for the full contig
# awk '$1 == $2' = only keeps the cases which query and subject are the same contig = only looking at potential chimeras
# joincol = join the current table with the table of [contig name | contig length], the key is the first column (= query name) = the file is now [query name | target name | alignment length | query length]
# awk '{if ($3/$4 >= 1.1) print $1}' = only print first column (= query name) if the alignment length / query length > 1.1 (> 10% of genome repeated), so this ouput the chimeric contig names


# Step 4: generate a new lengths file without chimeras (necessary for clustering step, to avoid keeping the chimeras)
grep -v -w -f results/Dereplication/List_chimeras.tab results/Dereplication/contig_lengths.tab > results/Dereplication/contig_lengths_no_chimeras.tab

# -v = invert the search, only keep the lines that do not have this pattern
# -w = only search for exact pattern
# -f = search for all the strings in the file (next argument)


#Step 5: remove the chimeras & clustering at ~90% coverage * identity
grep -v -w -f results/Dereplication/List_chimeras.tab results/Dereplication/contigs.all.blat | cut -f1,2,4 | ./scripts/hashsums | ./scripts/joincol results/Dereplication/contig_lengths.tab | sort -k4,4nr -k1,1 | head -n -1 | awk '{if ($3/$NF >= .90) print $1, $2}' > results/Dereplication/contig_pairs.tab


# grep -v = invert the search, only keep the lines that do not have this pattern
# grep -w = only search for exact pattern
# grep -f = search for all the strings in the file (next argument)
# the result is a blat table without any chimeras
# cut -f1,2,4 = only keeps query, subject and the alignment lenght columns
# hashsums = sums all the alignment lengths for the same query/subject pair = gives us the length for the full contig
# joincol = join the current table with the table of [contig name | contig length], the key is the second column (= subject name) = the file is now [query name | target name | alignment length | subject length]
# sort -k4,4nr -k1,1 = sort the data in reverse (-r) numerical (-n) order according to the key (-k) which is defined as the 4th column (-k4,4 because we start and end at the 4th field). If there are any equal values, the data are then sorted according to the 1st column (-k1,1).
# awk '{if ($3/$NF >= .90) print $1, $2}' = only if the alignment length / last column (subject length) > 0.9, print the 1st (query name) and 2nd column (subject name). So the output is a list of pairs of contigs that cluster together
# Warning: this command will generate an error message "division by zero attempted". This is NORMAL. This comes from hashsums which generates a 0 at first line. At the sort step, this "0" line is placed at the end of the file, so it doesn't create a problem
## ===> Warning l head -n -1 removes zeros at the end of the file. Check that no line is lost with this command



#Step 6: go from the pair of similar contigs to a CD-HIT-like cluster file (".clusters" file), and a file with the name of the contigs to keep (".txt" file), python code orignally made by Marie-AgnÃ¨s
chmod u+x scripts/aggregate.py

python3 scripts/aggregate.py results/Dereplication/contig_pairs.tab results/Dereplication/contig_lengths_no_chimeras.tab results/Dereplication/clust_out

#Step 7: go from the the CD-HT-like cluster file, python code orignally made by Marie-AgnÃ¨s
chmod u+x scripts/fasta_reader_select_P3.py

python3 scripts/fasta_reader_select_P3.py results/Assembly/Master_contigs_sub.fasta results/Dereplication/clust_out.txt results/Dereplication/contigs_derep.fasta
