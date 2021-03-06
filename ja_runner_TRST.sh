#!/usr/bin/env bash

# This is the runner file run by SGE
# Arguments: runner.sh filelist
# Environment variables: SGE_TASK_ID
# a_size=`wc -l chr${chr}_command.list| cut -f 1 -d " "`;echo "~/scripts/bash_scripts/ja_runner_par_TRST.sh -l $imputedir/chr${chr}_command.list"|qsub -t 1-${a_size} -o ${imputedir}/chr${chr}_\$JOB_ID_\$TASK_ID.log -e ${imputedir}/chr${chr}_\$JOB_ID_\$TASK_ID.e -V -N ${pop}_chr${chr} -l h_vmem=${m}
set -e

# file=`sed -n "${SGE_TASK_ID}p" $1`

#add options capabilities to the normal ja runner
echo "${@}"
while getopts ":dstql" opt; do
  case $opt in
    d)
      echo $opt
      echo "Double column list mode triggered!" >&2
      file=`sed -n "${SGE_TASK_ID}p" $2 | awk '{print $1}'`
      file2=`sed -n "${SGE_TASK_ID}p" $2 | awk '{print $2}'`
      echo ${file}
      echo ${file2}
      ;;
    t)
      echo $opt
      echo "Triple column list mode triggered!" >&2
      file1=`sed -n "${SGE_TASK_ID}p" $2 | awk '{print $1}'`
      file2=`sed -n "${SGE_TASK_ID}p" $2 | awk '{print $2}'`
      file3=`sed -n "${SGE_TASK_ID}p" $2 | awk '{print $3}'`
      echo ${file1}
      echo ${file2}
      echo ${file3}
      file=${file1}\:${file2}\:${file3}
      ;;
    q)
      echo $opt
      echo "Quadruple column list mode triggered!" >&2
      file1=`sed -n "${SGE_TASK_ID}p" $2 | awk '{print $1}'`
      file2=`sed -n "${SGE_TASK_ID}p" $2 | awk '{print $2}'`
      file3=`sed -n "${SGE_TASK_ID}p" $2 | awk '{print $3}'`
      file4=`sed -n "${SGE_TASK_ID}p" $2 | awk '{print $4}'`
      echo ${file1}
      echo ${file2}
      echo ${file3}
      echo ${file4}
      file=${file1}\:${file2}\:${file3}\:${file4}
      ;;
    s)
      echo $opt
      echo "Single list mode triggered!!" >&2
      file=`sed -n "${SGE_TASK_ID}p" $2`
      echo ${file}
      # $script ${file} $4 $5 $6 $7 $8
      ;;
    l)
      echo $opt
      echo "Script list mode triggered!!" >&2
      file=`sed -n "${SGE_TASK_ID}p" $2`
      # echo ${file}
      script=${file}
      # $script ${file} $4 $5 $6 $7 $8
      # $script ${file} "${@:3}"
      $script "${@:3}"
      ;;
    *)
      echo $opt
    ;;
  esac
  #bit to generate a report....
  # PID=$!
  # wait $!
  # status=$?
  # wdir=`pwd -P`
  # cmd=`history | tail -n2| head -1| cut -f 2- -d " "`
  # email=mc14@sanger.ac.uk
  # /nfs/users/nfs_m/mc14/Work/bash_scripts/send_report.sh ${status} ${email} ${wdir} ${cmd}

done

#11/09/2016
#remove duplicate lines from vcf files
# base_dir=`dirname ${file}`
# file_name=`basename ${file}`
# mkdir -p ${base_dir}/11092016_ANN
# mkdir -p ${base_dir}/11092016_ANN/TAB_SNP
# mkdir -p ${base_dir}/11092016_ANN/TAB_INDEL

# echo "Cleaning possible duplicate rows in annotated vcfs...."

# (bcftools view -h ${file};bcftools view -H ${file}| uniq)|bgzip -c > ${base_dir}/11092016_ANN/${file_name}
# tabix -f -p vcf ${base_dir}/11092016_ANN/${file_name}

# #remove also eventually duplicate lines from CADD annotation files
# echo "Cleaning possible duplicate rows in annotation files...."
# zcat ${base_dir}/TAB/${file_name}.scores.tsv.gz| uniq | gzip -c > ${base_dir}/11092016_ANN/TAB_SNP/${file_name}.scores.tsv.gz
# zcat ${base_dir}/TAB_INDEL/${file_name}.scores.tsv.gz| uniq | gzip -c > ${base_dir}/11092016_ANN/TAB_INDEL/${file_name}.scores.tsv.gz

#Preparing CADD tables to annotate vcf files
#SNP section

#we need a table to correctly sort multiple alleles
#need to have CHR POS REF ALT, but only for multiallelic sites
# chr=`echo ${file_name%%.*}`

# #here we work for indels and snp
# for type in snp indel
# do

# U_TYPE=`echo ${type^^}`

# echo "working on ${U_TYPE}..."

# bcftools query -f "%CHROM\t%POS\t%REF\t%ALT\n" -i"TYPE='${type}'" ${base_dir}/11092016_ANN/${file_name} | awk '{if($4~",") print $0}' > ${base_dir}/11092016_ANN/TAB_${U_TYPE}/${chr}.MULTI_${U_TYPE}.list

# echo "chr ${chr} .."
# echo "Preparing annotation file...."
# case ${type} in
# 	snp )
# 		zcat ${base_dir}/11092016_ANN/TAB_${U_TYPE}/${file_name}.scores.tsv.gz| tail -n+2 | awk '{print $1,$2,$3,$5,$(NF-1),$NF}' | prepare_annots.py ${base_dir}/11092016_ANN/TAB_${U_TYPE}/${chr}.MULTI_${U_TYPE}.list | sort -g -k2,2 | bgzip -c > ${base_dir}/11092016_ANN/TAB_${U_TYPE}/${chr}.formatted.CADD.tab.gz
# 	;;
# 	indel)
# 		zcat ${base_dir}/11092016_ANN/TAB_${U_TYPE}/${file_name}.scores.tsv.gz| tail -n+2 | awk '{print $1,$2,$3,$4,$(NF-1),$NF}' | prepare_annots.py ${base_dir}/11092016_ANN/TAB_${U_TYPE}/${chr}.MULTI_${U_TYPE}.list | sort -g -k2,2 | bgzip -c > ${base_dir}/11092016_ANN/TAB_${U_TYPE}/${chr}.formatted.CADD.tab.gz
# 	;;	
# esac

# tabix -f -s 1 -b 2 -e 2 ${base_dir}/11092016_ANN/TAB_${U_TYPE}/${chr}.formatted.CADD.tab.gz

# mkdir -p ${base_dir}/11092016_ANN/11092016_CADD_ANNOT
# echo "Annotate ${U_TYPE} in vcf...."
# bcftools view -v ${type}s  ${base_dir}/11092016_ANN/${file_name} | bcftools annotate -a ${base_dir}/11092016_ANN/TAB_${U_TYPE}/${chr}.formatted.CADD.tab.gz -c CHROM,POS,REF,ALT,CADD_RAW,CADD_PHRED -h /netapp/dati/INGI_WGS/18112015/CADD_header.txt -O z -o ${base_dir}/11092016_ANN/11092016_CADD_ANNOT/${chr}.${U_TYPE}.vcf.gz
# tabix -f -p vcf ${base_dir}/11092016_ANN/11092016_CADD_ANNOT/${chr}.${U_TYPE}.vcf.gz
# echo "Chromosome ${chr} done."

# done

# #now we join indels and snps back together
# echo "Join INDEL and SNP file for chr${chr} ..."
# bcftools concat ${base_dir}/11092016_ANN/11092016_CADD_ANNOT/${chr}.SNP.vcf.gz ${base_dir}/11092016_ANN/11092016_CADD_ANNOT/${chr}.INDEL.vcf.gz -O z -o ${base_dir}/11092016_ANN/11092016_CADD_ANNOT/${chr}.JOINT.vcf.gz

# echo "Sort by position the JOINT file for chr${chr} ..."
# (bcftools view -h ${base_dir}/11092016_ANN/11092016_CADD_ANNOT/${chr}.JOINT.vcf.gz;bcftools view -H ${base_dir}/11092016_ANN/11092016_CADD_ANNOT/${chr}.JOINT.vcf.gz | sort -g -k2,2 -T ${base_dir}/11092016_ANN/11092016_CADD_ANNOT/) | bgzip -c > ${base_dir}/11092016_ANN/11092016_CADD_ANNOT/${chr}.vcf.gz
# tabix -p vcf ${base_dir}/11092016_ANN/11092016_CADD_ANNOT/${chr}.vcf.gz

###################################
#30/09/2016

# # Convert IDs in CADD annotated files and generate UNRELATED data set from them
# base_dir=`dirname ${file}`
# file_name=`basename ${file}`

# mkdir -p ${base_dir}/30092016_CONV_ID
# mkdir -p ${base_dir}/30092016_UNRELATED

# bcftools reheader -s ${pop}_SC2CLIN.samples ${file} -o ${base_dir}/30092016_CONV_ID/${file_name}
# tabix -f -p vcf ${base_dir}/30092016_CONV_ID/${file_name}
# # bcftools view -h 1.vcf.gz| tail -n 1| cut -f 10-| tr "\t" "\n" > ${pop}_wgs_clin.samples
# #create the unrelated dataset
# bcftools view -S ^${unrel_file} ${base_dir}/30092016_CONV_ID/${file_name} -O z -o ${base_dir}/30092016_UNRELATED/${file_name}
# tabix -f -p vcf ${base_dir}/30092016_UNRELATED/${file_name}

###################################
#20/10/2016
# Extract chr pos and pval for a list of traits and different chromosomes from UK10K analyses results
# base_dir=`dirname ${file}`
# file_name=`basename ${file}`
# trait=`echo ${file_name%%.*}`

# mkdir -p ${base_dir}/20102016_SUBSET

# for chr in {1..22}
# do
# 	zcat ${file} | awk -v chr=${chr} '{if($1==chr) print $1,$3,$7}' > ${base_dir}/20102016_SUBSET/${trait}.chr${chr}.pval.txt
# 	# zcat ${file} | awk '{print $1,$3,$7}' > ${base_dir}/20102016_SUBSET/${trait}.chr${chr}.pval.txt
# done
# for pop in FVG
# do
# while read line
# do
# mkdir -p /home/cocca/analyses/INGI-TGP3/${pop}/UK10K_INGI_pvals_comp/
# file_name=`basename ${line}`
# echo ${file_name}
# #we want to get stuff in UK10K reolica and look at pvals in INGI imputed data
# awk 'FNR==NR{a[$2]=$0;next}{if($2 in a) print a[$2],$3}' /netapp/nfs/UK10K/analyses/INGI_${pop}/by_jie/20102016_SUBSET/${file_name} /home/cocca/analyses/INGI-TGP3/${pop}/GEMMA/output/20102016_SUBSET/${file_name} > /home/cocca/analyses/INGI-TGP3/${pop}/UK10K_INGI_pvals_comp/${file_name}

# done < <(cat /netapp/nfs/UK10K/analyses/INGI_FVG/by_jie/20102016_SUBSET/files.list)
# done

#27/10/2016
# count DAC for each samples
# pop=$2
# sample=${file}
# GWAS_DAC=`cat /netapp/dati/INGI_WGS/18112015/${pop}/12112015_FILTERED_REL/30092016_CONV_ID/27102016_DAC_COUNT/by_sample/*.${sample}.tab | fgrep -v "#CHROM"| awk '$10!="NA"'| awk '{sum+=$10}END{print sum}'`
# echo "${sample} ${GWAS_DAC}" >> /netapp/dati/INGI_WGS/18112015/${pop}/12112015_FILTERED_REL/30092016_CONV_ID/27102016_DAC_COUNT/by_sample/${pop}_all_samples_DAC.tab

#21/11/2016
# extract stats for Italian Genome

# bcftools stats -s - ${file} > ${base_dir}/${file_name}.vcfchk

#match info files between different imputations to compare frequencies and info scores
base_dir=`dirname ${file}`
file_name=`basename ${file}`

