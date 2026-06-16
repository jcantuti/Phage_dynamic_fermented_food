#!/usr/bin/python3.8
from Bio import SeqIO
import sys

fasta_file=sys.argv[1]
length_tab=sys.argv[2]


with open(fasta_file, 'r') as handle:
    for record in SeqIO.parse(handle, 'fasta'):
        contig_name = record.id;
        contig_size = len(record.seq);
        with open(length_tab, 'a') as output_handle:
            output_handle.write(f'{contig_name}\t{contig_size}\n')

