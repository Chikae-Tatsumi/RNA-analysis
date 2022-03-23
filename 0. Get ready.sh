#1 Launch MobaXterm
#2 In the toolbar, click on “Session” button
#3 Select “SSH” as the session type
#4 Specify “scc1.bu.edu” as the remote host and click “OK”
#5 Log in with your BU ID and password

# Finding and Activating conda Environments
# see https://www.bu.edu/tech/support/research/software-and-programming/common-languages/python/anaconda/#exp1
module load miniconda
mkdir /projectnb/talbot-lab-data/ctatsumi/.conda
mkdir /projectnb/talbot-lab-data/ctatsumi/.conda/envs
export CONDA_ENVS_PATH=/projectnb/talbot-lab-data/ctatsumi/.conda/envs

# Create a new environments
conda create -n RNASeq python=3.8 numpy scipy matplotlib
conda create -n busco_env -c conda-forge -c bioconda busco=5.3.0
conda create -n trinity_env -c conda-forge -c bioconda trinity=2.13.2
