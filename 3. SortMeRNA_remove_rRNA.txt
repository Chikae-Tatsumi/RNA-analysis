#################################################
# This is the code to remove the rRNA using SortMeRNA
# https://github.com/biocore/sortmerna
##################################################

#0. preparation
cd
dir=/projectnb/talbot-lab-data/ctatsumi/Analysis/cDNA_test # Change to your directry
dir_env=/projectnb/talbot-lab-data/ctatsumi/.conda/envs
dir_database=/projectnb/talbot-lab-data/ctatsumi/Database

######################################################################
#1. download database and install packages
# https://bioinfo.lifl.fr/RNA/sortmerna/code/sortmerna-2.1-linux-64-multithread.tar.gz
# Locate rRNA_databases in your directry
module load miniconda
conda activate $dir_env/RNASeq
conda install -c bioconda sortmerna

######################################################################
#2. sortmerna
sortmerna_ref_dir=$dir_database/rRNA_databases
clean_data_dir=$dir/cleandata
mkdir $dir/sortmerna
sortmerna_out_dir=$dir/sortmerna
cd $clean_data_dir

ls *.gz|cut -d"." -f 1 |sort -u|while read id;do
mkdir $sortmerna_out_dir/${id}_workdir
sortmerna --ref $sortmerna_ref_dir/silva-bac-16s-id90.fasta --ref $sortmerna_ref_dir/silva-bac-23s-id98.fasta --ref $sortmerna_ref_dir/silva-arc-16s-id95.fasta --ref $sortmerna_ref_dir/silva-arc-23s-id98.fasta --ref $sortmerna_ref_dir/silva-euk-18s-id95.fasta --ref $sortmerna_ref_dir/silva-euk-28s-id98.fasta --ref $sortmerna_ref_dir/rfam-5s-database-id98.fasta --ref $sortmerna_ref_dir/rfam-5.8s-database-id98.fasta \
--reads $clean_data_dir/${id}.fq.gz --workdir $sortmerna_out_dir/${id}_workdir --aligned $sortmerna_out_dir/${id}_workdir/${id}_aligned --other $sortmerna_out_dir/${id}_workdir/${id}_other --fastx --sam --SQ
done

######################################################################
#3. Move the output files for the next analysis
mkdir $dir/sortmerna/summary
sortmerna_summary_dir=$dir/sortmerna/summary
ls *.gz|cut -d"." -f 1 |sort -u|while read id;do
cp $sortmerna_out_dir/${id}_workdir/*_other_0.fq.gz $sortmerna_summary_dir/${id}.fq.gz
done

gunzip $sortmerna_summary_dir/*.fq.gz
