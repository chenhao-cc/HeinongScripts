#!/bin/bash

#( vg + SURVIVOR + bcftools)

REF="path/to/reference.fa"
SAMPLES33=("sample1" "sample2" ...)   # genome
SAMPLESall=("sampleA" "sampleB" ...)  # sample
FASTQ_DIR="/path/to/fastq"            # fa
THREADS=50
MEM_GB=128

# 
for sample in ${SAMPLESall[@]}; do
    python scripts/filter_sv.py 02.syri.output/${sample}/${sample}_syri.vcf 03.SV_ge20/${sample}_SV.vcf
done

#  SURVIVOR
ls 03.SV_ge20/*_SV.vcf > vcf.list
SURVIVOR merge vcf.list 1000 0 1 1 0 20 04.merged/merged.SV.vcf

# 
bcftools norm -f ${REF} -c w 04.merged/merged.SV.vcf -Oz -o 04.merged/merged.SV.filter.vcf.gz
gunzip -c 04.merged/merged.SV.filter.vcf.gz > 04.merged/merged.SV.filter.vcf
bcftools sort 04.merged/merged.SV.filter.vcf -Oz -o 04.merged/merged.SV.filter.sorted.vcf.gz
tabix 04.merged/merged.SV.filter.sorted.vcf.gz

#vg giraffe
vg autoindex --workflow giraffe \
    -r ${REF} \
    -v 04.merged/merged.SV.filter.sorted.vcf.gz \
    -p soybean_pangenome \
    -t ${THREADS} \
    -T /dev/shm/soybean_tmp

#
for sample in ${SAMPLESall[@]}; do
    R1=${FASTQ_DIR}/${sample}_R1.fastp.fq.gz
    R2=${FASTQ_DIR}/${sample}_R2.fastp.fq.gz
    
    # 5a. giraffe 
    vg giraffe -p -t ${THREADS} \
        -Z soybean_pangenome.giraffe.gbz \
        -d soybean_pangenome.dist \
        -m soybean_pangenome.shortread.withzip.min \
        -f ${R1} -f ${R2} > 05.population/${sample}.gam

    # 5b. pack
    vg pack -t ${THREADS} \
        -x soybean_pangenome.giraffe.gbz \
        -g 05.population/${sample}.gam \
        -Q 5 -s 5 \
        -o 05.population/${sample}.pack

    # 5c. call
    vg call -t ${THREADS} -a -s ${sample} \
        -k 05.population/${sample}.pack \
        soybean_pangenome.giraffe.gbz > 05.population/${sample}.vcf

    # 5d.
    bgzip 05.population/${sample}.vcf
    bcftools index 05.population/${sample}.vcf.gz
done
