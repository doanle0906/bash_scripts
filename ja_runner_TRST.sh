#!/usr/local/env bash

# This is the runner file run by SGE
# Arguments: runner.sh filelist
# Environment variables: SGE_TASK_ID
# a_size=`wc -l chr${chr}_command.list| cut -f 1 -d " "`;echo "~/scripts/bash_scripts/ja_runner_par_TRST.sh -l $imputedir/chr${chr}_command.list"|qsub -t 1-${a_size} -o ${imputedir}/chr${chr}_\$JOB_ID_\$TASK_ID.log -e ${imputedir}/chr${chr}_\$JOB_ID_\$TASK_ID.e -V -N ${pop}_chr${chr} -l h_vmem=${m}

file=`sed -n "${SGE_TASK_ID}p" $1`

#11/09/2016
#remove duplicate lines from vcf files
base_dir=`dirname ${file}`
file_name=`basename ${file}`
mkdir -p ${base_dir}/1109206_ANN
(bcftools view -h ${file};bcftools view -H ${file}| uniq)|bgzip -c > ${base_dir}/1109206_ANN/${file_name}
tabix -f -p vcf ${base_dir}/1109206_ANN/${file_name}
