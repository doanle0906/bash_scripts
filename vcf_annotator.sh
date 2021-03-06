#!/usr/local/bin/bash

#Comprehensive script used to add annotation of population overlap
vcf_file=$1
outdir=$2
MODE=$3
filename=`basename ${vcf_file}`

# #TGP annotation
# zcat ${vcf_file} | vcf-annotate -a /lustre/scratch113/projects/fvg_seq/variant_refinemet/annotations/1TGP/ALL.wgs.phase1_release_v3.20101123.snps_indels_sv.sites.overlap_flag.tab.gz -d key=INFO,ID=TGP,Number=0,Type=Flag,Description='Variant present in 1000Genome populations' -c CHROM,POS,-,-,-,INFO/TGP | bgzip -c > ${vcf_file}.TGP.gz
# tabix -p vcf ${vcf_file}.TGP.gz

# #UK10K and SINGLETON annotation
# zcat ${vcf_file}.TGP.gz | vcf-annotate -a /lustre/scratch113/projects/fvg_seq/variant_refinemet/annotations/UK10K/ALL.wgs.UK10K.filtered.sites.overlap_flag.tab.gz -d key=INFO,ID=UK10K,Number=0,Type=Flag,Description='Variant present in UK10K populations' -f /lustre/scratch113/projects/fvg_seq/REL-2014-01-09/v2/filter.txt -c CHROM,POS,-,-,-,INFO/UK10K | bgzip -c > ${vcf_file}.TGP.UK10K.gz
# tabix -p vcf ${vcf_file}.TGP.UK10K.gz

#readd vqslod field
# zcat ${vcf_file} | bcftools2 annotate -a /lustre/scratch113/projects/fvg_seq/REL-2014-01-09/v1/all_chr_vqslod.txt.gz -h /lustre/scratch113/projects/fvg_seq/REL-2014-01-09/v1/ann_header.txt -c CHROM,POS,-,REF,ALT,-,INFO/VQSLOD | bgzip -c > /lustre/scratch113/projects/fvg_seq/REL-2014-01-09/v1/fvg.vqsr.beagle.impute2.anno.20140109.csq.pop.vqslod.fixed_2.vcf.gz
# tabix -h ${vcf_file} X:562410-562410 | bcftools2 annotate -a /lustre/scratch113/projects/fvg_seq/REL-2014-01-09/v1/all_chr_vqslod.txt.gz -h key=INFO,ID=VQSLOD,Number=1,Type=Float,Description='Log odds ratio of being a true variant versus being false under the trained gaussian mixture model' -c CHROM,POS,-,REF,ALT,-,INFO/VQSLOD | bgzip -c > /lustre/scratch113/projects/fvg_seq/REL-2014-01-09/v1/fvg.vqsr.beagle.impute2.anno.20140109.csq.pop.vqslod.fixed_2.vcf.gz
# tabix -f -p vcf /lustre/scratch113/projects/fvg_seq/REL-2014-01-09/v1/fvg.vqsr.beagle.impute2.anno.20140109.csq.pop.vqslod.fixed_2.vcf.gz

case $MODE in
  outbred )
    zcat ${vcf_file} | vcf-annotate -a /lustre/scratch113/projects/fvg_seq/variant_refinemet/annotations/1TGP/ALL.wgs.phase1_release_v3.20101123.snps_indels_sv.sites.flag.tab.gz -d key=INFO,ID=TGP,Number=0,Type=Flag,Description="Variant present in TGP populations" -c CHROM,POS,-,-,-,INFO/TGP | vcf-annotate -a /lustre/scratch113/projects/fvg_seq/variant_refinemet/annotations/UK10K/ALL.wgs.UK10K.filtered.sites.tab.gz -d key=INFO,ID=UK10K,Number=0,Type=Flag,Description="Variant present in UK10K populations" -c CHROM,POS,-,-,-,INFO/UK10K  | bgzip -c > ${outdir}/${filename}
    ;;
  inbred )
    #28/05/2014 command to annotate outbred population with info from isolate population
    zcat ${vcf_file} | vcf-annotate -a /lustre/scratch113/teams/soranzo/users/mc14/INGI/annotations/FVG/FVG_20140517.all.sites.tab.gz -d key=INFO,ID=FVG,Number=0,Type=Flag,Description="Variant present in FVG populations" -c CHROM,POS,-,-,-,INFO/FVG | vcf-annotate -a /lustre/scratch113/teams/soranzo/users/mc14/INGI/annotations/VBI/VBI_20140517.all.sites.tab.gz -d key=INFO,ID=VBI,Number=0,Type=Flag,Description="Variant present in VBI populations" -c CHROM,POS,-,-,-,INFO/VBI  | bgzip -c > ${outdir}/${filename}
    ;;
esac

tabix -p vcf ${outdir}/${filename}

