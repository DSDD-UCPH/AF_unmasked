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
AF_UNMASKED_DIR="/projects/ilfgrid/apps/AF_unmasked"
FASTAFILE="$AF_UNMASKED_DIR/examples/2VB1/2VB1.fasta"
OUTDIR="$AF_UNMASKED_DIR/examples" #could this be a folder
TEMPLATE="$OUTDIR/2VB1/template_data/2VB1_template.cif"

AF_DIR="/projects/ilfgrid/apps/alphafold-2.3.1"                   # should not be changed
AFDB_DIR="/projects/ilfgrid/data/alphafold-genetic-databases/"    # or /alphafold_db on ilfgridgpun01fl

#module load miniconda
#conda activate $AF_unmasked_dir/miniconda3/envs/AF2.3.1_cuda11.8_conda_env 
#conda activate $AF_unmasked_dir/AF2.3.1_unmasked
#packages=`conda list`&&echo $packages
conda activate $AF_UNMASKED_DIR/AF2.3.1_unmasked

cd $AF_UNMASKED_DIR
python run_alphafold.py --fasta_paths /projects/ilfgrid/apps/AF_unmasked/examples/2VB1/2VB1.fasta \
    --flagfile databases.flag --flagfile /projects/ilfgrid/apps/AF_unmasked/examples/2VB1/template_data/templates.flag \
    --output_dir $OUTDIR --cross_chain_templates --dropout --model_preset='multimer_v2' --separate_homomer_msas
conda deactivate
