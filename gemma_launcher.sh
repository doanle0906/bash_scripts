#!/usr/local/bin/bash

#script to submit a bunch of gemma jobs
# input genotype file = /lustre/scratch113/projects/uk10k/users/jh21/imputed/fvg/uk10k1kg.shapeit/chr9.bimbam
# input phenotype file = /nfs/users/nfs_m/mc14/Work/SANGER/FVG/PHENO/ANTROP/new/others/gemma_pheno.txt
# input annotation file = /lustre/scratch113/projects/uk10k/users/jh21/imputed/fvg/uk10k1kg.shapeit/chr9.bimbam.pos
# input relatedness matrix file = /lustre/scratch113/projects/uk10k/users/mc14/UK10K_replica/INGI_FVG/kinship/fvg_kin_c.cXX.txt

bimbam_path=$1 #same for genotypes and pos files
pheno_path=$2 #phenotype file path
#we'll read a phenotype list file: each row containd the phenotype name and the phenotype column number in the gemma phenotype file
kinship=$3 #kinship matrix path
cov=$4 #covariate file path


if [ $# -lt 3 ]
then
	echo "MISSING ARGUMENTS!!!"
	echo -e "USAGE:\ngemma_launcher.sh <bimbam_path> <pheno_path> <kinship_file_path> [<cov file path>]"
	exit 1
fi

if [ $# -eq 4 ]
then
	echo "ADDED COVARIATE FILE!!!"
fi

echo "Checking phenotype files existence...."

if [ ! -f ${pheno_path}/gemma_pheno_list.txt ]
then
	echo -e "ATTENTION!!\nMissing ${pheno_path}/gemma_pheno_list.txt file!\nexit from script!"
	exit 1
fi

if [ ! -f ${pheno_path}/gemma_pheno.txt ]
then
	echo -e "ATTENTION!!\nMissing ${pheno_path}/gemma_pheno.txt file!\nexit from script!"
	exit 1
fi

echo "Correct names for phenotype files detected!!"
echo "Cracking!!"

while read -r line
do
	#line="7 TLM"
	trait=$(echo $line | cut -f 2 -d " ")
	trait_n=$(echo $line | cut -f 1 -d " ")

	if [[ $trait != "ID" ]]
	then
	#here goes the for loop for the chr
		echo $line
		for chr in {1..22} X
		do
			#command for farm2
			#bsub -J "gemma_${trait}_${chr}" -o "%J_gemma_${trait}_${chr}.log" -e "%J_gemma_${trait}_${chr}.err" -M7000000 -R"select[mem>=7000] rusage[mem=7000]" -q normal -- /nfs/users/nfs_y/ym3/bin/gemma -g ${bimbam_path}/chr${chr}.bimbam -p ${pheno_path}/gemma_pheno.txt -a ${bimbam_path}/chr${chr}.bimbam.pos -k ${kinship} -maf 0 -miss 0 -fa 4 -n ${trait_n} -o $trait.chr$chr.tab
			#bsub -J "gemma_${trait}_${chr}" -o "%J_gemma_${trait}_${chr}.log" -e "%J_gemma_${trait}_${chr}.err" -M5000000 -R"select[mem>=5000] rusage[mem=5000]" -q normal -- /nfs/users/nfs_y/ym3/bin/gemma -g ${bimbam_path}/chr${chr}.bimbam -p ${pheno_path}/gemma_pheno.txt -a ${bimbam_path}/chr${chr}.bimbam.pos -k ${kinship} -maf 0 -miss 0 -fa 4 -n ${trait_n} -o $trait.chr$chr.tab
			#command for farm 3
			if [ $# -eq 4 ]
			then
				#we want to provide also a covariate file for conditional analyses
				#so we check for a new argument: the covariate file path. If provided we run the analyses with this covariate
				#cova=`echo ${cov#*conditional_}| cut -f 1 -d "."`
				cova=`basename ${cov#*_}| cut -f 1 -d "."`
				echo "Covariate: ${cova}"
				echo "Covariate File: ${cov}"

				outfile=$trait.chr${chr}_${cova}.tab
				bsub -J "gemma_${trait}_${chr}" -o "%J_gemma_${trait}_${chr}.log" -e "%J_gemma_${trait}_${chr}.err" -M3500 -R"select[mem>=3500] rusage[mem=3500]" -q normal -- /nfs/users/nfs_y/ym3/bin/gemma -g ${bimbam_path}/chr${chr}.bimbam -p ${pheno_path}/gemma_pheno.txt -a ${bimbam_path}/chr${chr}.bimbam.pos -k ${kinship} -c ${cov} -maf 0 -miss 0 -fa 4 -n ${trait_n} -o ${outfile}
			else
				outfile=$trait.chr$chr.tab
				#with the first command we launch gemma on the whole set of snps, regardless of missing genotypes due to panel merging for fvg cohort
				bsub -J "gemma_${trait}_${chr}" -o "%J_gemma_${trait}_${chr}.log" -e "%J_gemma_${trait}_${chr}.err" -M3500 -R"select[mem>=3500] rusage[mem=3500]" -q normal -- /nfs/users/nfs_y/ym3/bin/gemma -g ${bimbam_path}/chr${chr}.bimbam -p ${pheno_path}/gemma_pheno.txt -a ${bimbam_path}/chr${chr}.bimbam.pos -k ${kinship} -maf 0 -miss 0 -fa 4 -n ${trait_n} -o ${outfile}
				#if we want to remove snps with missing data!!(but the miss option removes the sample or the snp??)
				#bsub -J "gemma_${trait}_${chr}" -o "%J_gemma_${trait}_${chr}.log" -e "%J_gemma_${trait}_${chr}.err" -M7000 -R"select[mem>=7000] rusage[mem=7000]" -q normal -- /nfs/users/nfs_y/ym3/bin/gemma -g ${bimbam_path}/chr${chr}.bimbam -p ${pheno_path}/gemma_pheno.txt -a ${bimbam_path}/chr${chr}.bimbam.pos -k ${kinship} -maf 0 -fa 4 -n ${trait_n} -o $trait.chr$chr.tab
			fi

			#now we want to compress all our outputs to save space
			# but first we want to check that the X chr is coded as X or 23 in the result files, at least
			# if not, we're going to code it as X
			if [ $chr == "X" ]
			then
				chr_code=`cut -f 1 ${outfile}.assoc.txt | tail -n+2 | sort | uniq`

				if [ $chr_code != "X" ]
				then
					echo "sed 's/^.\+	/X	/g' ${outfile}.assoc.txt | gzip -c > ${outfile}.assoc.txt.gz" | bsub -J "gemma_${trait}_${chr}_shrink" -w "ended(gemma_${trait}_${chr})" -o "%J_gemma_${trait}_${chr}_shrink.log" -e "%J_gemma_${trait}_${chr}_shrink.err" -M3500 -R"select[mem>=3500] rusage[mem=3500]" -q normal
				fi
			else
				bsub -J "gemma_${trait}_${chr}_shrink" -w "ended(gemma_${trait}_${chr})" -o "%J_gemma_${trait}_${chr}_shrink.log" -e "%J_gemma_${trait}_${chr}_shrink.err" -M3500 -R"select[mem>=3500] rusage[mem=3500]" -q normal --  gzip ${outfile}.assoc.txt
			fi

		done
	fi

done < ${pheno_path}/gemma_pheno_list.txt
