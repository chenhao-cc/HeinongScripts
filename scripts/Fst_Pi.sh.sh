#!/usr/bin/sh

#Fst
vcftools \
--gzvcf ALL.rename.new.Chr.filtered.vcf.gz \
--weir-fst-pop 1950s_1960s.txt \
--weir-fst-pop 1970s.txt \
--out A_B_100k_10k_bin \
--fst-window-size 100000 --fst-window-step 10000

#Pi
vcftools --gzvcf ALL.rename.new.Chr.filtered.vcf.gz \
         --keep 1950s_1960s.txt \
         --window-pi 100000 \
         --out pi_1950s_1960s 



