#!/bin/bash -l

# This is monomer example just to test both the 
#SBATCH --partition=standard                                                      # the queue you submit to 
#SBATCH --qos=normal                                                              # Quality of Service needs to match the partition
#SBATCH --mem=20G                                                                 # the amount of memory to reserve
#SBATCH --gres=gpu:1                                                              # no. of gpus (use only one) REMOVE IF ONLY RUNNING MSA
#SBATCH --ntasks=12                                                               # combined with --cpus-per-task it determines
#SBATCH --cpus-per-task=1                                                         # the number of cpus to use (here: 12)
#SBATCH --nodes=1                                                                 # no. of nodes to use
#SBATCH --output=%x.%j.out                                                        # File to redirect the standard output (jobname.jobID.out)

#Paths

NAME="1MKF"
AF_UNMASKED_DIR="/projects/ilfgrid/apps/AF_unmasked"
FASTAFILE="$AF_UNMASKED_DIR/examples/$NAME/$NAME.fasta"


OUTDIR="$AF_UNMASKED_DIR/examples" #OUTDIR for prepare templates
TEMPLATES="$OUTDIR/$NAME/template_data"


AF_DIR="/projects/ilfgrid/apps/alphafold-2.3.1"                   # should not be changed
AFDB_DIR="/projects/ilfgrid/data/alphafold-genetic-databases/"    # or /alphafold_db on ilfgridgpun01fl

module load miniconda
conda activate $AF_UNMASKED_DIR/AF2.3.1_unmasked

cd $AF_UNMASKED_DIR

python prepare_templates.py --target $OUTDIR/$NAME/$NAME.fasta \
    --template $TEMPLATES/$NAME.cif \
    --output_dir $OUTDIR

#     --superimpose

conda deactivate


