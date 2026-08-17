#!/bin/bash

~/software/hifiasm \
    -o hifiasm/test.asm \
    -t 150 \
    --dual-scaf --telo-m TTTAGGG \
    --ont test.pass.fq.gz

cd hifiasm

awk '/^S/{print ">"$2;print $3}' test.asm.bp.p_ctg.gfa > test.contig.fa
assembly-stats test.contig.fa > contig.stats.txt
seqkit fx2tab --length --name test.contig.fa |sort -k2,2nr > contig.length.tsv

# seqkit fx2tab -n -l test.contig.fa | awk '$2 < 1000000' | wc -l
# seqkit fx2tab -n -l test.contig.fa | awk '$2 >= 1000000' | wc -l
seqkit seq -g -m 1000000 test.contig.fa -o test.contig_filtered.fa

#conda activate ragtag
ragtag.py scaffold Wm82-NJAU.fasta test.contig_filtered.fa -t 200


#  busco \
#      -i test.genome.final.fasta \
#      -c 200 \
#      -o busco \
#      -m geno \
#      -l embryophyta_odb10 --offline

# python quartet.py CentroMiner -i test.genome.final.fasta -t 200 
# python quartet.py TeloExplorer -i test.genome.final.fasta -c plant -m 50
