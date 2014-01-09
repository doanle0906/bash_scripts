#!/bin/bash
#ARGS passed
#$1=chr ($1)
#$2=start ($2)
#$3=end ($3)
#$4=ref_path 1 ($4)
#$5=ref_path 2 ($5)
#$6=geno_path ($6)
#$7=out_path ($7)
#$8=chunk_n ($8)
 
CHR=$1
CHUNK_START=`printf "%.0f" $2`
CHUNK_END=`printf "%.0f" $3`
CHUNK_N=$8

# directories
REF1_DATA_DIR=$4/
REF2_DATA_DIR=$5/
GENO_DATA_DIR=$6/
RESULTS_DIR=$7/

mkdir -p ${RESULTS_DIR}GEN

# parameters
NE=20000
BUFFER=500
K_HAPS=10000 #bigger k_hap value seems to improve accuracy

## MODIFY THE FOLLOWING THREE LINES TO ACCOMODATE OTHER PANELS
# reference data files
#recombination map hardcoded because we only have the one from 1KGP
GENMAP_FILE=/lustre/scratch113/teams/soranzo/users/mc14/GENOTIPI/REF_PANEL/1000G/ALL_1000G_phase1integrated_v3_impute/genetic_map_chr${CHR}_combined_b37.txt

HAPS1_FILE=${REF1_DATA_DIR}chr${CHR}.haps.gz
HAPS2_FILE=${REF2_DATA_DIR}chr${CHR}.haps.gz
LEGEND1_FILE=${REF1_DATA_DIR}chr${CHR}.legend.gz
LEGEND2_FILE=${REF2_DATA_DIR}chr${CHR}.legend.gz
# STRAND_g_FILE=${GENO_DATA_DIR}CHR${CHR}/IMPUTE_INPUT/chr${CHR}.strand
# GENO_FILE=${GENO_DATA_DIR}CHR${CHR}/IMPUTE_INPUT/chr${CHR}.geno
# SAMPLE_FILE=${GENO_DATA_DIR}CHR${CHR}/IMPUTE_INPUT/chr${CHR}.sample

## THESE HAPLOTYPES WOULD BE GENERATED BY THE PREVIOUS SCRIPT
## SELECT ONE FROM METHOD-A AND METHOD-B BELOW
# METHOD-A: haplotypes from IMPUTE2 phasing run
#GWAS_HAPS_FILE=${RESULTS_DIR}gwas_data_chr${CHR}.pos${CHUNK_START}-${CHUNK_END}.phasing.impute2_haps
 
# METHOD-B: haplotypes from SHAPEIT phasing run
#GWAS_HAPS_FILE=${GENO_DATA_DIR}PREPHASED/valborbera-b37-phased/valborbera_b37_chr${CHR}.haps
 
# main output file
OUTPUT_FILE=${RESULTS_DIR}chr${CHR}.$7.geno

#check impute executable path
# /nfs/team151/software/impute_v2.3.0_x86_64_static/impute2 \
# -allow_large_regions \
# -k_hap $k_hap $k_hap \
# -m $gmap \
# -h $ref1/chr$chr.hap.gz $ref2/chr$chr.hap.gz \
# -l $ref1/chr$chr.legend.gz $ref2/chr$chr.legend.gz \
# -merge_ref_panels \
# -merge_ref_panels_output_ref chr$chr.$chunkStr \
# -int $chunk_begin $chunk_end \
# -Ne 20000 \
# -buffer 250

/nfs/team151/software/impute2.3.0.1 -k_hap $K_HAPS $K_HAPS -m $GENMAP_FILE -h $HAPS1_FILE $HAPS2_FILE -l $LEGEND1_FILE $LEGEND2_FILE -int $CHUNK_START $CHUNK_END -merge_ref_panels -merge_ref_panels_output_ref $RESULTS_DIRchr${CHR}.${CHUNK_N}.${CHUNK_START}_${CHUNK_END} -Ne $NE -o ${RESULTS_DIR}GEN/chr${CHR}.${CHUNK_N}.${CHUNK_START}_${CHUNK_END} -o_gz -buffer $BUFFER -include_buffer_in_output -allow_large_regions -seed 367946 -verbose