# see https://github.com/NFREC-Liao-Lab/RNA_Analysis/blob/main/1_md5_check.txt

########################################################
#md5 check
#This is code for test the dataset completeness
########################################################
module load miniconda

cd
dir=/projectnb/talbot-lab-data/ctatsumi/Analysis/cDNA_test # Change to your directry

#1. load work environment and install the package
conda activate /projectnb/talbot-lab-data/ctatsumi/.conda/envs/RNASeq
conda install -c bioconda perl-digest-md5

#2. check
md5sum $dir/rawdata/*.gz > $dir/md5.txt
md5sum -c $dir/md5.txt
