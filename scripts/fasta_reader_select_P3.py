#! /usr/bin/python3.8

# this script selects a subsample of fasta files
#usage ./fasta_reader_select_P3.py input_fasta_file choice_list name_output

import sys

fasta_file=sys.argv[1]
choice=sys.argv[2]
output_file=sys.argv[3]

 
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
                    clean_line = line.strip()
                    items= clean_line.split()
                    name=items[0][1:]
                    #comm = items[1]
                    flag = 'seq'
                else:
                # stockage de la ligne lue
                    self.line= line
                    if name == '':
                        name = 'anonymous'
                    #print name
                    return Gene(name=name,sequence=seq.upper(),comm=comm)

            else:
                seq = seq +line

            line = ifh.readline()
            #line=line.strip()

        #recup dernier objet
        self.line=line
        return Gene(name=name, sequence=seq.upper(), comm=comm)
    
class Gene:
    def __init__(self, name=None, comm=None, sequence=None):
        self.name=name
        self.comm=comm
        self.seq=sequence

ofh=open(output_file, 'w')
headers={}
#file containing the nodes to get
ifh=open(choice)
line=ifh.readline()
while line:
    line_ok=line.strip()    
    headers[line_ok]=1
    line=ifh.readline()
ifh.close()
#print headers.keys()


ifh=open(fasta_file)
iter=FastaIterator(ifh)
a=iter.next()
while a:
    print(a.name)
    if a.name in headers.keys():
        new_header='>'+a.name+'\n'
        ofh.write(new_header)
        ofh.write(a.seq)
    a=iter.next()
ifh.close()
ofh.close()




