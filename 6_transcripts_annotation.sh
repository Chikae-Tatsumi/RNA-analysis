################################
#for transcript annotation in RNASeq analysis with standard pipeline
##################################

# 0. preparation
cd
dir=/projectnb/talbot-lab-data/ctatsumi/Analysis/cDNA_test # Change to your directry
dir_script=/projectnb/talbot-lab-data/ctatsumi/Script # Change to your directry
dir_env=/projectnb/talbot-lab-data/ctatsumi/.conda/envs # Change to your directry
dir_database=/projectnb/talbot-lab-data/ctatsumi/Database # Change to your directry

######################################################################
# 1. database download
module load miniconda
conda deactivate
conda activate $dir_env/RNASeq
conda install -c bioconda trinotate

cd $dir_script
git clone https://github.com/Trinotate/Trinotate.git
mkdir $dir/trinotate_out

Trinotate/admin/Build_Trinotate_Boilerplate_SQLite_db.pl Trinotate

mv Pfam-A.hmm.gz $dir/trinotate_out/Pfam-A.hmm.gz
mv Trinotate.sqlite $dir/trinotate_out/Trinotate.sqlite
mv uniprot_sprot.dat.gz $dir/trinotate_out/uniprot_sprot.dat.gz
mv uniprot_sprot.pep $dir/trinotate_out/uniprot_sprot.pep
cd $dir/trinotate_out/

gunzip Pfam-A.hmm.gz
makeblastdb -in uniprot_sprot.pep -dbtype prot
hmmpress Pfam-A.hmm

######################################################################
# 2. get longest ORF
# https://github.com/TransDecoder/TransDecoder/wiki

conda install -c bioconda TransDecoder
TransDecoder.LongOrfs -t $dir/trinity_out/Trinity.cdhit_unigene.fa

# predict the likely coding regions
TransDecoder.Predict -t $dir/trinity_out/Trinity.cdhit_unigene.fa

######################################################################
# 3. Running sequence analysis
blastx -query $dir/trinity_out/Trinity.fasta \
  -db $dir/trinotate_out/uniprot_sprot.pep \
  -num_threads 1 \
  -max_target_seqs 1 \
  -outfmt 6 \
  -evalue 1e-3 > $dir/trinotate_out/blastx.outfmt6 
  
blastp -query $dir/trinity_out/Trinity.cdhit_unigene.fa.transdecoder_dir/longest_orfs.pep \
  -db $dir_database/Trinotate_databases/uniprot_sprot.pep \
  -num_threads 1 \
  -max_target_seqs 1 \
  -outfmt 6  \
  -evalue 1e-3 > $dir/trinotate_out/blastp.outfmt6 
  
hmmscan --cpu 1 \
  --domtblout $dir/trinotate_out/TrinotatePFAM.out \
  $dir/trinotate_out/Pfam-A.hmm $dir/trinity_out/Trinity.cdhit_unigene.fa.transdecoder_dir/longest_orfs.pep > $dir/trinotate_out/pfam.log 
  
# Download below and place them at $dir_script and unzip
# https://services.healthtech.dtu.dk/service.php?TMHMM-2.0
# https://services.healthtech.dtu.dk/service.php?SignalP-5.0 (you may have to locate signalp-5.0b within $dir_script/signalp-5.0b)
# https://services.healthtech.dtu.dk/service.php?RNAmmer-1.2

cd
$dir_script/signalp-5.0b/bin/signalp -format short -prefix $dir/trinotate_out/ -fasta $dir/trinity_out/Trinity.cdhit_unigene.fa.transdecoder_dir/longest_orfs.pep
$dir_script/tmhmm-2.0c/bin/tmhmm --short < $dir/trinity_out/Trinity.cdhit_unigene.fa.transdecoder_dir/longest_orfs.pep > $dir/trinotate_out/tmhmm.out
mkdir $dir/trinotate_out/rnammer_out
cd $dir/trinotate_out/rnammer_out
$dir_script/Trinotate/util/rnammer_support/RnammerTranscriptome.pl --transcriptome $dir/trinity_out/Trinity.fasta --path_to_rnammer $dir_script/rnammer-1.2/rnammer

######################################################################
# 4. Loading results

# $dir_script/trinityrnaseq/trinityrnaseq/util/support_scripts/get_Trinity_gene_to_trans_map.pl \
#       TrPtA_269336_P_taeda_mRNAdatabase_328662_2.fasta >  TrPtA.fasta.gene_trans_map

# Trinotate $dir/trinotate_out/Trinotate.sqlite init \
#   --gene_trans_map TrPtA.fasta.gene_trans_map \
#   --transcript_fasta TrPtA_269336_P_taeda_mRNAdatabase_328662.fasta \
#   --transdecoder_pep $dir/trinity_out/Trinity.cdhit_unigene.fa.transdecoder_dir/longest_orfs.pep
  
Trinotate $dir/trinotate_out/Trinotate.sqlite LOAD_swissprot_blastp $dir/trinotate_out/blastp.outfmt6
Trinotate $dir/trinotate_out/Trinotate.sqlite LOAD_swissprot_blastx $dir/trinotate_out/blastx.outfmt6
Trinotate $dir/trinotate_out/Trinotate.sqlite LOAD_pfam $dir/trinotate_out/TrinotatePFAM.out
Trinotate $dir/trinotate_out/Trinotate.sqlite LOAD_tmhmm $dir/trinotate_out/tmhmm.out
Trinotate $dir/trinotate_out/Trinotate.sqlite LOAD_signalp $dir/trinotate_out/_summary.signalp5

######################################################################
# 5. finally, report was generated as follows:
cd $dir_script
Trinotate $dir/trinotate_out/Trinotate.sqlite report > $dir/trinotate_out/trinotate_annotation_report.xls