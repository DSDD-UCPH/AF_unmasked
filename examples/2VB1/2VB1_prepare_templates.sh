#!/bin/bash -l

# This is monomer example just to test both the 
#SBATCH --partition=standard                                                      # the queue you submit to 
#SBATCH --qos=normal                                                              # Quality of Service needs to match the partition
#SBATCH --mem=20G                                                                 # the amount of memory to reserve
#SBATCH --ntasks=12                                                               # combined with --cpus-per-task it determines
#SBATCH --cpus-per-task=1                                                         # the number of cpus to use (here: 12)
#SBATCH --nodes=1                                                                 # no. of nodes to use
#SBATCH --output=%x.%j.out                                                        # File to redirect the standard output (jobname.jobID.out)

FASTAFILE="/projects/ilfgrid/apps/AF_unmasked_test/AF_unmasked/examples/2VB1/2VB1.fasta"
AF_unmasked_dir="/projects/ilfgrid/apps/AF_unmasked_test"
OUTDIR="$AF_unmasked_dir/AF_unmasked/examples" #could this be a folder
TEMPLATE="$OUTDIR/2VB1/template_data/2VB1_template.cif"

AF_DIR="/projects/ilfgrid/apps/alphafold-2.3.1"                   # should not be changed
AFDB_DIR="/projects/ilfgrid/data/alphafold-genetic-databases/"    # or /alphafold_db on ilfgridgpun01fl

module load miniconda
#conda activate $AF_unmasked_dir/miniconda3/envs/AF_unmasked 
conda activate $AF_unmasked_dir/miniconda3/envs/AF2.3.1_cuda11.8_conda_env
#packages=`conda list`
#echo $packages 

cd $AF_unmasked_dir && python AF_unmasked/prepare_templates.py --target $FASTAFILE --template $TEMPLATE --output_dir $OUTDIR --align

