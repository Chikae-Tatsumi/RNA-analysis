# see https://github.com/NFREC-Liao-Lab/RNA_Analysis/blob/main/1_md5_check.txt

########################################################
#md5 check
#This is code for test the dataset completeness
########################################################

#1. load work environment and install the package
module load miniconda
conda activate RNASeq
conda install -c bioconda perl-digest-md5

#2. check
md5sum $dir/rawdata/*.gz > $dir/md5.txt
md5sum -c $dir/md5.txt
