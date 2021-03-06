##################################################################################
#1. load work envrionment and install packages
module load miniconda
conda activate RNASeq

##################################################################################
# 2. Run
# see https://github.com/trinityrnaseq/trinityrnaseq/wiki/Trinity-Transcript-Quantification

cd $dir/mapping/1_aligned_fastq
gunzip *fastq.gz
ls *_aligned_R1.fastq|cut -d "_" -f 1,2,3 > 1
ls *_aligned_R1.fastq > 2
ls *_aligned_R2.fastq > 3
paste 1 1 2 3 > file_list
cat file_list

$dir_script/trinityrnaseq/trinityrnaseq/util/align_and_estimate_abundance.pl \
--transcripts $dir/trinity_out/Trinity.cdhit_unigene.fa \
--seqType fq \
--est_method kallisto \
--samples_file file_list \
--output_dir $dir/mapping \
--aln_method bowtie2 --prep_reference

$dir_script/trinityrnaseq/trinityrnaseq/util/abundance_estimates_to_matrix.pl --est_method kallisto \
--gene_trans_map $dir/trinotate_out/fasta.gene_trans_map \
--out_prefix kallisto \
--name_sample_by_basedir \
Index4_S2_L001/abundance.tsv Index5_S1_L001/abundance.tsv Index7_S3_L001/abundance.tsv

cp kallisto.isoform.counts.matrix kallisto.isoform.counts.txt
cp kallisto.isoform.TMM.EXPR.matrix kallisto.isoform.TMM.EXPR.txt
cp kallisto.isoform.counts.matrix kallisto.isoform.counts.txt
