#!/usr/bin/python3.8
"""
This script takes as entry a BLAT output once filtered through a Shiraz-like script, and the lengths of all contigs expected in the output files (if needed, remove chimera at this stage).

A Shiraz-like script collects the various subjects corresponding to a given query (1st column of the BLAT output), and retains queries having a id*cov above some threshold relative to any subject.

USE THIS SCRIPT ONLY IF aligned_nucleotides IS DIVIDED BY THE SIZE OF QUERY (col1)

It chooses the longest query as "type" of the cluster, and gives two outputs similar to CD-hit: a .txt file which is list of these types, and a .cluster file explaining who belongs to which cluster

Contrary to the CD-hit ouput, note that here in  the .cluster output, different clusters can have the same fragments inside
"""
"""
usage
aggregate.py output_shiraz non_chimeric_contig_length output_prefix
"""
import sys
file_shiraz=sys.argv[1]
file_lengths=sys.argv[2]
output_prefix=sys.argv[3]



dic_by_len={}
dic_by_name={}

#recup des infos Shiraz
dic_by_cluster={}
not_singleton=[]
ifh=open(file_shiraz)
line=ifh.readline()
while line:
    elems=line.split()
    if elems[0]!=elems[1]:
        if elems[1] not in dic_by_cluster.keys():
            dic_by_cluster[elems[1]]=[elems[0]]
            not_singleton.append(elems[0])
            not_singleton.append(elems[1])
        else:
            if elems[0] not in dic_by_cluster[elems[1]]:
                dic_by_cluster[elems[1]].append(elems[0])
                not_singleton.append(elems[0])

    line=ifh.readline()

#derep not_singletons
not_singleton_uniques=[*set(not_singleton)]

#recup des contigs et de leurs tailles
ifh=open(file_lengths)
line=ifh.readline()
i=0
while line:
    i+=1
    elems=line.split()
    long=int(elems[1])
    dic_by_name[elems[0]]=elems[1]
    if long not in dic_by_len.keys():
        dic_by_len[long]=[elems[0]]
    else:
        dic_by_len[long].append(elems[0])
    line=ifh.readline()

print('input contigs', str(i))

#fusion des clusters emboites, en commencant par les plus grands contigs

all_lengths=list(dic_by_len.keys())

all_lengths.sort(reverse=True)
L=len(all_lengths)

for j in range (L):
    size=all_lengths[j]
    contigs_of_the_size=dic_by_len[size]
    for contig in contigs_of_the_size:
        if contig in dic_by_cluster:
            fixed_members=[]
            for you in dic_by_cluster[contig]:
                fixed_members.append(you)
            for member in fixed_members:
                if member in dic_by_cluster:
                    check_list=dic_by_cluster[member]
                    for check in check_list:
                        dic_by_cluster[contig].append(check)
                    del dic_by_cluster[member]


#dereplicating contig lists

for family in dic_by_cluster:
    contigs=dic_by_cluster[family]
    derep=[*set(contigs)]
    dic_by_cluster[family]=derep

#nombre de singletons
after_cluster=len(dic_by_cluster)
print('number of clusters')
print(after_cluster)
single=i-len(not_singleton_uniques)
all=single+after_cluster
print('final number of contigs after total clustering')
print(str(all))
print('number of singleton')
print(str(single))

#ecriture des deux fichiers type cdhit

out1=output_prefix+'.clusters'
out2=output_prefix+'.txt'
ofh=open(out1, 'w')
ofh2=open(out2,'w')

for j in range (L):
    size=all_lengths[j]
    contigs_of_the_size=dic_by_len[size]
    for contig in contigs_of_the_size:
        if contig in dic_by_cluster:
            ofh2.write(contig+'\n')
            ofh.write('>'+contig+'\t'+dic_by_name[contig]+'\n')
            for elem in dic_by_cluster[contig]:
                ofh.write('\t'+elem+'\t'+dic_by_name[elem]+'\n')
        elif contig in not_singleton:
            pass
        else:
            ofh.write(contig+'\t'+dic_by_name[contig]+'\n')
            ofh2.write(contig+'\n')

ofh.close()
ofh2.close()

