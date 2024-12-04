#!/bin/bash -l
#SBATCH --partition=standard                                                      # the queue you submit to 
#SBATCH --qos=normal                                                              # Quality of Service needs to match the partition
#SBATCH --mem=20G                                                                 # the amount of memory to reserve
#SBATCH --ntasks=12                                                               # combined with --cpus-per-task it determines
#SBATCH --cpus-per-task=1                                                         # the number of cpus to use (here: 12)
#SBATCH --nodes=1                                                                 # no. of nodes to use
#SBATCH --output=%x.%j.out                                                        # File to redirect the standard output (jobname.jobID.out)

NAME="1MKF"
AF_UNMASKED_DIR="/projects/ilfgrid/apps/AF_unmasked"
WORKING_DIR=$AF_UNMASKED_DIR/examples
FASTAFILE="$WORKING_DIR/$NAME/$NAME.fasta"
OUTDIR="$WORKING_DIR/$NAME/output" #OUTDIR for prepare templates

#Unmasked Run Options
FLAGFILE="$WORKING_DIR/$NAME/template_data/templates.flag"
DROPOUT=true
SEPARATE_HOMOMER_MSAS=true
CROSS_CHAIN_TEMPLATES=true

module load miniconda
conda activate $AF_UNMASKED_DIR/AF2.3.1_unmasked 
echo $WORKING_DIR

cd $AF_UNMASKED_DIR
source $AF_UNMASKED_DIR/run_alphafold.sh \
    --model-preset multimer_v2 \
    --output-dir $OUTDIR \
    --fasta-path $FASTAFILE \
    --max-template-date 2023-01-01 \
    --separate-homomer-msas $SEPARATE_HOMOMER_MSAS\
    --flag-file $FLAGFILE \
    --cross-chain-templates $CROSS_CHAIN_TEMPLATES\
    --dropout $DROPOUT