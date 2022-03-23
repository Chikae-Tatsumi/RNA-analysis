###############################
#this is the code for sequecing quality control and trimming
###############################

#0. preparation
cd
dir=/projectnb/talbot-lab-data/ctatsumi/Analysis/cDNA_test # Change to your directry
dir_env=/projectnb/talbot-lab-data/ctatsumi/.conda/envs

######################################################################
#1. install packages
module load miniconda
conda activate $dir_env/RNASeq
conda install -c bioconda fastqc
conda install -c bioconda -c conda-forge multiqc
conda install -c bioconda -c conda-forge trim-galore

######################################################################
#2. quality conntrol
rawdata_dir=$dir/rawdata #the directory have the rawdata
mkdir $dir/rawdata_fastqc
rawdata_fastqc_out_dir=$dir/rawdata_fastqc   #setup the output directory

for i in $rawdata_dir/*.gz ; do
    basename=$(basename "$i" .gz)
    fastqc $i -t 24 -o $rawdata_fastqc_out_dir/
done
# -t ... number of CPUs
# -o ... output directory position

cd $rawdata_fastqc_out_dir
multiqc *.zip

########################################################################
#3. trimming by using trim_galore
mkdir $dir/cleandata
clean_data_dir=$dir/cleandata    #setup clean data directory

for i in $rawdata_dir/*_R2_001.fastq.gz ; do
   basename=$(basename "$i" _R2_001.fastq.gz)
   trim_galore -q 25 --phred33 --stringency 3 --length 100 \
               --paired $rawdata_dir/${basename}_R1_001.fastq.gz    $rawdata_dir/${basename}_R2_001.fastq.gz \
               --gzip \
               --cores 10 \
               -o $clean_data_dir
    
done

##########################################################################
#4. check the quality of the trimmed reads
mkdir $dir/cleandata_fastqc
cleandata_fastqc_out_dir=$dir/cleandata_fastqc   #set the output directroy 

for i in $clean_data_dir/*.gz ; do
    basename=$(basename "$i" .gz)
    fastqc $i -t 24 -o $cleandata_fastqc_out_dir 
done

cd $cleandata_fastqc_out_dir
multiqc *.zip
