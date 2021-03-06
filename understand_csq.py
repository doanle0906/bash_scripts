#!/usr/bin/env python2.7

#script used to extract consequence annotation from vcf files. From Enza Colonna and moddified by Max Cocca.
import gzip 
import re 
import sys 

#this version works on a single chromosome, so we can submit a job array
in_path=sys.argv[1]
# prefix=sys.argv[2]
out_path=sys.argv[2]
chr=sys.argv[3]

listaconseq=[]

# for chr in range (1, 23):
# # chr=22
# 	if chr == 23:
# 		chr='X'

print chr 

# for line in gzip.open('/nfs/users/nfs_m/mc14/lustre110_home/GENOTIPI/COMPARISON/NOT_OVERLAPPING/PUTATIVE_NOVEL/NEW_RUN/former_rsID_filtered/UK10K_FILTERED/gte2_indivs/esgi-vbseq.vqsr.beagle.impute2.anno.20120607.csq.SNPS.chr%s.re_ann.NOT_OVERLAP.NO_RSID.no_UK10K.gte2_indivs.vcf.gz' %(chr) , 'r'): 
for line in gzip.open('%s/%s.vcf.gz' %(in_path,chr) , 'r'): 
	if re.match('\d+\t', line):
		x=line.split('\t')
		y=x[7].split(';')
		for item in y:
			if re.match('CSQ', item):
				#print item  
				z=item.split('+')
				for conseq in z:
					if not re.search('GERP', conseq):  
						w=conseq.split(':')
						if re.search(',', w[2]) : 
							a=w[2].split(',')
							for tipi in a: 
								if not tipi in listaconseq: listaconseq.append(tipi) 
						else: 
							if not w[2] in listaconseq: listaconseq.append(w[2])

out=open('%s/%s_consequences.list' %(out_path,chr), 'w')
sys.stdout=out
for csq in listaconseq: print csq
						 
				
