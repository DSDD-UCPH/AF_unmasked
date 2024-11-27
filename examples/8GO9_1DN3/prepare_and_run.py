NAME=2VB1
AF_UNMASKED_DIR="/projects/ilfgrid/apps/AF_unmasked"
OUTDIR="$AF_UNMASKED_DIR/examples"
mkdir -p $OUTDIR





FASTAFILE="$AF_UNMASKED_DIR/examples/$NAME/$NAME.fasta"
OUTDIR="$AF_UNMASKED_DIR/examples" #could this be a folder
TEMPLATE="$OUTDIR/$NAME/template_data/${NAME}_template.cif"

AF_DIR="/projects/ilfgrid/apps/alphafold-2.3.1"                   # should not be changed
AFDB_DIR="/projects/ilfgrid/data/alphafold-genetic-databases/"    # or /alphafold_db on ilfgridgpun01fl

module load miniconda
conda activate $AF_UNMASKED_DIR/AF2.3.1_unmasked

cd $AF_UNMASKED_DIR && python prepare_templates.py --target $FASTAFILE --template $TEMPLATE --output_dir $OUTDIR --align
conda deactivate 