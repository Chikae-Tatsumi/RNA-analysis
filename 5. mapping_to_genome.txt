####################################################
#This is for metatranscriptomic mapping analysis:bowtie2
####################################################

#0. preparation
cd
dir=/projectnb/talbot-lab-data/ctatsumi/Analysis/cDNA_test # Change to your directry
dir_env=/projectnb/talbot-lab-data/ctatsumi/.conda/envs

##################################################################################
#1. load work envrionment and install packages
module load miniconda
conda activate $dir_env/RNASeq

##################################################################################
#2. reference preparation
mkdir $dir/bowtie2
bowtie2-build $dir/trinity_out/Trinity.fasta $dir/bowtie2/bowtie2_index

####################################################################################
#3. mapping
bowtie2_index="$dir/bowtie2/bowtie2_index"

mkdir $dir/mapping
mapping_out_dir=$dir/mapping
sortmerna_summary_dir=$dir/sortmerna/summary
cd $sortmerna_summary_dir

mkdir $mapping_out_dir/1_aligned_fastq
mkdir $mapping_out_dir/1_unaligned_fastq
mkdir $mapping_out_dir/1_bowtie2_met_file
mkdir $mapping_out_dir/1_bowtie2_log_file
mkdir $mapping_out_dir/2_bam_file
mkdir $mapping_out_dir/2_bam_flagstat_file

ls *.fq|cut -d"_" -f 1,2,3 |sort -u |while read id;do
mkdir $mapping_out_dir/${id}.temp
     time bowtie2 -p 4 -x $bowtie2_index \
                 -1 ${id}_R1_001_val_1.fq \
                 -2 ${id}_R2_001_val_2.fq \
                 -S $mapping_out_dir/${id}.temp/${id}.sam \
                 --al-conc-gz $mapping_out_dir/1_aligned_fastq/${id}_aligned.fastq.gz \
                 --un-conc-gz $mapping_out_dir/1_unaligned_fastq/${id}_unaligned.fastq.gz \
                 --met-file $mapping_out_dir/1_bowtie2_met_file/${id}_met.txt \
                 2>$mapping_out_dir/1_bowtie2_log_file/${id}_bowtie2.log

     samtools sort -o bam -@ 3 -o $mapping_out_dir/2_bam_file/${id}.bam $mapping_out_dir/${id}.temp/${id}.sam
     samtools flagstat -@ 3 $mapping_out_dir/${id}.temp/${id}.sam > $mapping_out_dir/2_bam_flagstat_file/${id}.flagstat
     mv $mapping_out_dir/1_aligned_fastq/${id}_aligned.fastq.1.gz $mapping_out_dir/1_aligned_fastq/${id}_aligned_R1.fastq.gz
     mv $mapping_out_dir/1_aligned_fastq/${id}_aligned.fastq.2.gz $mapping_out_dir/1_aligned_fastq/${id}_aligned_R2.fastq.gz
done
