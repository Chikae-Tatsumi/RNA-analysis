################################
#for transcript annotation in RNASeq analysis with eggnog-mapper
##################################
# eggnog-mapper
# http://eggnog-mapper.embl.de/
# https://github.com/eggnogdb/eggnog-mapper/wiki/eggNOG-mapper-v2.1.2-to-v2.1.4

#1. setup the package
module load miniconda
conda activate RNASeq
conda install -c bioconda eggnog-mapper

#2. setup the database
mkdir $dir_database/eggnog_db
export EGGNOG_DATA_DIR=$dir_database/eggnog_db
download_eggnog_data.py 
cd $dir_script
git clone https://github.com/eggnogdb/eggnog-mapper.git

#3. run the annotation
mkdir $dir/eggnog_out

$dir_script/eggnog-mapper/emapper.py \
-i $dir/trinity_out/Trinity.cdhit_unigene.fa.transdecoder_dir/longest_orfs.pep  \
--output_dir $dir/eggnog_out \
--itype proteins \
--cpu 24 \
--sensmode ultra-sensitive \
--override --report_orthologs --excel

cp $dir/eggnog_out/eggnog_out.emapper.annotations $dir/eggnog_out/eggnog_out.emapper.annotations.txt
