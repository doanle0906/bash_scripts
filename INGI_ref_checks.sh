#!/usr/bin/env bash

#Script to prepare data for plotting after imputation
    # for pan in uk10k1kg.ref
# for pan in INGI.shapeit CARL.shapeit FVG.shapeit VBI.shapeit 1000Gph1.shapeit 1000GP_Phase3.shapeit INGI_1000GPh3.shapeit uk10k1kg.ref
    # for pan in 1000GP_Phase3.shapeit

# pop=CARL
    # for pan in INGI.shapeit CARL.shapeit FVG.shapeit VBI.shapeit 1000Gph1.shapeit INGI_1000GPh3.shapeit uk10k1kg.ref
    # pan=1000Gph1.shapeit
    # pan=uk10k1kg.ref
    # do
# basefolder2="/lustre/scratch113/projects/esgi-vbseq/31032016_IMPUTATION"
# basefolder="/lustre/scratch113/teams/soranzo/users/jh21/imputed"
# basefolder2="/netapp/dati/WGS_REF_PANEL/08062016/IMPUTED"
# basefolder="/netapp/dati/WGS_REF_PANEL/08062016/IMPUTED"


basefolder2=$4
basefolder=$5

# for pop in CARL FVG INCIPE2 VBI
# for pop in fvg vbi
# for pop in carl fvg incipe2 vbi
# for pop in INCIPE2
# pop=CARL
# pop=FVG
# pop=VBI
# pop=INCIPE2
# for pan in TGP3_ALL.shapeit EUR.shapeit
# for pan in CARL_FVG_VBI_UK10K_TGP3_ALL.shapeit
# for pop in carl fv vbi incipe2
# do
# for pan in CARL_FVG_VBI.shapeit CARL_FVG_VBI_TSI.shapeit CARL_FVG_VBI_TGP3_ALL.shapeit uk10k1kg.ref TGP3_ALL.shapeit EUR.shapeit CARL.shapeit FVG.shapeit VBI.shapeit
# # pan=TGP3_ALL.shapeit
# # pan=CARL_FVG_VBI_UK10K_TGP3_ALL.shapeit
# do
#         for chr in 2
#         # chr=21
#         do
            # read variables from command line
pop=$1
pan=$2
chr=$3

echo $pop $pan $chr
mkdir -p ${basefolder2}/${pop^^}/${pan}/${chr}
maf_bins="0,0.005,0.01,0.02,0.05,0.10,0.15,0.20,0.25,0.30,0.40,0.50"
# chr=21
case $pan in
    uk10k1kg.ref )
        if [[ $pop == "vbi" ]]; then
            pop2="vb"
        else
            pop2=$pop
        fi
        if [[ $pop == "fvg" ]]; then
        (zgrep -h -v chromosome ${basefolder}/${pop2}/${pan}/master_stats/chr${chr}.gen.gz.stats.gz) | awk '{print $1,$2,$4,(($12*2)+$11)/(($10+$11+$12)*2),$9,$8,"-1","-1","-1","-1"}' | gzip -c > ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info.gz
        else
        (fgrep -h -v position ${basefolder}/${pop2}/${pan}/chr${chr}.*.gen_info) | sed 's/\/lustre\/scratch113\/projects\/esgi-vbseq\/02032016_INGI_REF_PANEL\/IMPUTE\/CARL_FVG_VBI_TGP3_ALL\/'"${chr}"'\/'"${chr}"'.INGI_REF.CARL_FVG_VBI_TGP3_ALL.*.legend.gz://g'|gzip -c > ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info.gz
            
        fi
        
        (echo "CHROM RS_ID POS EXP_FREQ_A1 INFO TYPE INFO_TYPE0 CONCORD_TYPE0 r2_TYPE0 COHORT PANEL MAF BIN";(zgrep -v position ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info.gz | cut -f 2,3,4,5,7- -d " "| awk -v chrom=$chr -v cohort=$pop -v panel=$pan '{if($3 <= 0.5 ) print chrom,$0,toupper(cohort),panel,$3; else print chrom,$0,toupper(cohort),panel,1-$3}'|awk -v bins=$maf_bins '
        {n=split(bins,mafs,",");}{
        for (i=1;i<=n;i++){
        if (mafs[i]==0){
        if($(NF) <= mafs[i]){
        print $0,mafs[i]
        }
        }else{
        if($(NF) <= mafs[i] && $(NF) > mafs[i-1]){
        print $0,mafs[i]
        }

        }
        }
        }'))| gzip -c > ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info_partial_t2.gz

    ;;
    * )
    # (fgrep -h -v position ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.*.gen_info) | sed 's/\/lustre\/scratch113\/projects\/esgi-vbseq\/02032016_INGI_REF_PANEL\/IMPUTE\/CARL_FVG_VBI_TGP3_ALL\/'"${chr}"'\/'"${chr}"'.INGI_REF.CARL_FVG_VBI_TGP3_ALL.*.legend.gz://g'|gzip -c > ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info.gz
    (fgrep -h -v position ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.*.gen_info) | gzip -c > ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info.gz
    # (fgrep -h -v position ${basefolder}/${pop}/${pan}/chr${chr}.*.gen_info)| cut -f 1,2,4,5,6,15,19 | tr "\t" " " | gzip -c > ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info.gz
    # gzip ${pop}/${pan}/chr${chr}.gen_info
    # (echo "CHROM RS_ID POS EXP_FREQ_A1 INFO TYPE INFO_TYPE0 CONCORD_TYPE0 r2_TYPE0 COHORT PANEL MAF BIN";(zgrep -v position ${basefolder2}/${pop^^}/${pan}/chr${chr}.gen_info.gz | cut -f 2,3,4,5,7- -d " "| awk -v chrom=$chr -v cohort=$pop -v panel=$pan '{if($3 <= 0.5 ) print chrom,$0,toupper(cohort),panel,$3; else print chrom,$0,toupper(cohort),panel,1-$3}'|awk -v bins=$maf_bins '
    (echo "CHROM RS_ID POS EXP_FREQ_A1 INFO TYPE INFO_TYPE0 CONCORD_TYPE0 r2_TYPE0 COHORT PANEL MAF BIN";(zgrep -v position ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info.gz | cut -f 2,3,6,7,9- -d " "| awk -v chrom=$chr -v cohort=$pop -v panel=$pan '{if($3 <= 0.5 ) print chrom,$0,toupper(cohort),panel,$3; else print chrom,$0,toupper(cohort),panel,1-$3}'|awk -v bins=$maf_bins '
    {n=split(bins,mafs,",");}{
    for (i=1;i<=n;i++){
    if (mafs[i]==0){
    if($(NF) <= mafs[i]){
    print $0,mafs[i]
    }
    }else{
    if($(NF) <= mafs[i] && $(NF) > mafs[i-1]){
    print $0,mafs[i]
    }

    }
    }
    }'))| gzip -c > ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info_partial_t2.gz
    #need to format everything in bed format
    (header=`zcat ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info_partial_t2.gz | head -1`;echo "chrom chromStart chromEnd ${header}" ;zcat ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info_partial_t2.gz|tail -n+2| awk '{print $1,$3-1,$3,$0}') > ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info_partial_t2.bed
    ;;
esac

#section to creade INFO scores bins
info_bins="0,0.2,0.4,0.6,0.8,1"
# chr=21
(echo "CHROM RS_ID POS EXP_FREQ_A1 INFO TYPE INFO_TYPE0 CONCORD_TYPE0 r2_TYPE0 COHORT PANEL MAF BIN INFO_BIN";(zgrep -v CHROM ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info_partial_t2.gz|awk -v ibins=$info_bins '
{n=split(ibins,info,",");}{
for (i=1;i<=n;i++){
    if (info[i]==0){
        if($5 < info[i]){
            print $0,info[i]
        }
    }else{
        if(info[i]==1){
            if($5 <= info[i] && $5 > info[i-1]){
                print $0,info[i]
            }
        }else{
            if($5 < info[i] && $5 >= info[i-1]){
                print $0,info[i]
            }
        }
    }
}
}'))| gzip -c > ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info_partial_INFOBIN_t2.gz
#need to format everything in bed format
(header=`zcat ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info_partial_INFOBIN_t2.gz | head -1`;echo "chrom chromStart chromEnd ${header}" ;zcat ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info_partial_INFOBIN_t2.gz|tail -n+2| awk '{print $1,$3-1,$3,$0}') > ${basefolder2}/${pop^^}/${pan}/${chr}/chr${chr}.gen_info_partial_INFOBIN_t2.bed

