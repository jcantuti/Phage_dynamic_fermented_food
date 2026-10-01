#!/usr/bin/python3.8
from string import *
import sys

file_name=sys.argv[1]
PREFIX= sys.argv[2]
out_file=sys.argv[3]

#write here below your multifasta to rename, your output directory and your prefix
#do spades files one by one!

#out_file='rest/spades_clean/'+PREFIX+'_contigs_above2Kb.fasta'

class FastaIterator:
    #corrige le 14 juin 2012, iterator sautait i=une prot sur deux
    def __init__(self,ifh):
        self.ifh=ifh
        self.line=''

    def next(self):

        flag = 'header'
        name = ''
        comm = ''
        seq  = ''
        # recuperation de la valeur de la ligne precedement lue
        if self.line!= '':
            line = self.line
        else:
            line = ifh.readline()
            line=line.strip()
        if line=='':
            return None
        
        while line !='':
            if line[0] == '>':
                if flag == 'header':
                    name = line.strip()
                    name=name[1:]
                    name_parts=name.split('_')
                    final_name=PREFIX+'_'+name
                    comm = name_parts[3]+ ' coverage '+name_parts[5]
                    flag = 'seq'
                else:
                # stockage de la ligne lue
                    self.line= line
                    if name == '':
                        name = 'anonymous'
                    #print name
                    return Gene(name=final_name,sequence=seq.upper(),comm=comm)

            else:
                seq = seq +line

            line = ifh.readline()
            #line=line.strip()

        #recup dernier objet
        self.line= line
        return Gene(name=final_name,sequence=seq.upper(),comm=comm)

class Gene:
    def __init__(self, name=None, comm=None, sequence=None):
        self.name=name
        self.comm=comm
        self.seq=sequence




reads=[]
lengths=[]
ifh=open(file_name)
iter=FastaIterator(ifh)
a=iter.next()
while a:
#    print len(a.seq)
    lengths.append(len(a.seq))
    reads.append(a)
    a=iter.next()
ifh.close()

N_reads= len(lengths)
middle=int(N_reads/2)
median_len=lengths[middle]
print("Sample, Ncontigs,  median_len")
print(PREFIX, N_reads, median_len)

#select contigs to study and name them properly
i=0
ofh=open(out_file, 'w')
for contig in reads:
    infos=contig.comm.split()
    if int(infos[0])>= 2000:
        i+=1
        
        contig_name='>'+contig.name
        string=contig_name+'\n'
        ofh.write(string)
        ofh.write(contig.seq)
        
print("N contigs > 2 kb: "+ str(i))
ofh.close()


