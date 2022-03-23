# https://github.com/trinityrnaseq/trinityrnaseq/wiki

#0. preparation
cd
dir=/projectnb/talbot-lab-data/ctatsumi/Analysis/cDNA_test # Change to your directry
dir_script=/projectnb/talbot-lab-data/ctatsumi/Script # Change to your directry
dir_env=/projectnb/talbot-lab-data/ctatsumi/.conda/envs
cd $dir_script/Script
git clone https://github.com/trinityrnaseq/trinityrnaseq.git

######################################################################
#1. install packages
module load miniconda
conda deactivate
conda activate $dir_env/trinity_env
conda install -c bioconda bowtie2
conda install -c bioconda rsem
conda install -c bioconda salmon
conda install -c bioconda samtools=1.9
conda install -c bioconda jellyfish
conda install -c bioconda subread

######################################################################
#2. Trinity run
sortmerna_summary_dir=$dir/sortmerna/summary
cd $sortmerna_summary_dir

### for trinity==2.1.1
# Trinity --seqType fq \
# --left Index4_S2_L001_R1_001_val_1.fq,Index5_S1_L001_R1_001_val_1.fq,Index7_S3_L001_R1_001_val_1.fq \
# --right Index4_S2_L001_R2_001_val_2.fq,Index5_S1_L001_R2_001_val_2.fq,Index7_S3_L001_R2_001_val_2.fq \
# --CPU 24 --max_memory 60G --output $dir/trinity_out

ls *_R1_001_val_1.fq|cut -d "_" -f 1,2,3 > 1
ls *_R1_001_val_1.fq > 2
ls *_R2_001_val_2.fq > 3
paste 1 1 2 3 > file_list
cat file_list

Trinity --seqType fq --samples_file file_list --CPU 24 --max_memory 60G --output $dir/trinity_out

######################################################################
#3. evaluate the assemble result
cd $dir/trinity_out
TrinityStats.pl Trinity.fasta > trinity_assembly_stats.txt

#4. evaluate the completeness of the assembled transcripts 
    #use the package BUSCO
    #https://busco.ezlab.org/busco_userguide.html
conda deactivate
conda activate $dir_env/busco_env

busco \
-i Trinity.fasta \
-m tran -c 24 \
-o busco \
--auto-lineage

conda deactivate
conda activate $dir_env/RNASeq

######################################################################
#5. remove the Redundant Sequence
# cd-hit remove the Redundant Sequence
conda install -c bioconda cd-hit
cd-hit-est -i Trinity.fasta -o Trinity.cdhit_unigene.fa -c 0.95 -n 9 -M 1500 -T 12

######################################################################
#6. the distribution of the sequence length
conda deactivate
conda activate $dir_env/trinity_env
pip install Fasta_reader

perl $dir_script/trinityrnaseq/trinityrnaseq/util/misc/fasta_seq_length.pl \
$dir/trinity_out/Trinity.fasta > $dir/trinity_out/length.txt
