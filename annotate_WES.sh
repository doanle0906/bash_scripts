#!/bin/bash

#script to annotate diferent types and create differen subset for WES data
INF=$1 #input/output folder
TYPE=$2 #type of variant (SNP / INDEL)

# All variants called, no filter:
bcftools annotate -a /nfs/users/xe/ggirotto/annotations/All_20150102.vcf.gz -c CHROM,POS,ID,REF,ALT ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.vcf.gz -O z -o ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.ann.vcf.gz
tabix -p vcf ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.ann.vcf.gz
bcftools stats -s - ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.ann.vcf.gz > ${INF}/WES_${TYPE}_stats_ALL.txt

# All variants called, filtered By QUAL >= 30 :
bcftools view -i "QUAL>=30" ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.ann.vcf.gz -O z -o ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.Q30.vcf.gz
tabix -p vcf ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.Q30.vcf.gz
bcftools stats -s - ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.Q30.vcf.gz > ${INF}/WES_${TYPE}_stats_ALL_Q30.txt

# All variants called, filtered By QUAL >= 30 AND VQSLOD 99%:
bcftools annotate -a /nfs/users/xe/ggirotto/annotations/All_20150102.vcf.gz -c CHROM,POS,ID,REF,ALT ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.clean.vcf.gz -O z -o ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.clean.ann.vcf.gz 
tabix -p vcf ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.clean.ann.vcf.gz
bcftools view -i "QUAL>=30" ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.clean.ann.vcf.gz -O z -o ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.clean.Q30.vcf.gz
tabix -p vcf ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.clean.Q30.vcf.gz
bcftools stats -s - ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.clean.Q30.vcf.gz > ${INF}/WES_${TYPE}_stats_VQSR99_Q30.txt

# All variants called, filtered By QUAL >= 30 AND VQSLOD 98.2%:
bcftools view -i "QUAL>=30 && MIN(VQSLOD)>-0.0295" ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.ann.vcf.gz -O z -o ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.Q30.VQSLOD982.vcf.gz 
tabix -p vcf ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.Q30.VQSLOD982.vcf.gz 
bcftools stats -s - ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.Q30.VQSLOD982.vcf.gz > ${INF}/WES_${TYPE}_stats_VQSR98.2_Q30.txt

# All CCDS variants:
bcftools view -R /nfs/users/xe/ggirotto/multisample/REGIONS/CCDS/GENCODE_presbio_comprehensive_coding_clean.bed ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.ann.vcf.gz -O z -o ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.CCDS.vcf.gz
tabix -p vcf ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.CCDS.vcf.gz
bcftools stats -s - ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.CCDS.vcf.gz > ${INF}/WES_${TYPE}_CCDS_stats_ALL.txt
  
# All CCDS variants filtered by QUAL >= 30:
bcftools view -i "QUAL>=30" ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.CCDS.vcf.gz -O z -o ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.CCDS.Q30.vcf.gz
tabix -p vcf ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.CCDS.Q30.vcf.gz
bcftools stats -s - ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.CCDS.Q30.vcf.gz > ${INF}/WES_${TYPE}_CCDS_stats_ALL_Q30.txt
  
# All CCDS variants filtered by QUAL >= 30 AND VQSLOD 99%:
bcftools view -R /nfs/users/xe/ggirotto/multisample/REGIONS/CCDS/GENCODE_presbio_comprehensive_coding_clean.bed ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.clean.Q30.vcf.gz -O z -o ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.clean.CCDS.Q30.vcf.gz
tabix -p vcf ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.clean.CCDS.Q30.vcf.gz
bcftools stats -s - ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.clean.CCDS.Q30.vcf.gz > ${INF}/WES_${TYPE}_CCDS_stats_VQSR99_Q30.txt

# All CCDS variants filtered by QUAL >= 30 AND VQSLOD 98.2%:
bcftools view -R /nfs/users/xe/ggirotto/multisample/REGIONS/CCDS/GENCODE_presbio_comprehensive_coding_clean.bed ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.Q30.VQSLOD982.vcf.gz -O z -o ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.CCDS.Q30.VQSLOD982.vcf.gz
tabix -p vcf ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.CCDS.Q30.VQSLOD982.vcf.gz
bcftools stats -s - ${INF}/All.multisampleinitial.allregions.${TYPE}.recalibrated.filtered.CCDS.Q30.VQSLOD982.vcf.gz > ${INF}/WES_${TYPE}_CCDS_stats_VQSR98.2_Q30.txt
  