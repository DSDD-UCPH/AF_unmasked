#!/bin/bash
# Description: AlphaFold non-docker version
# Author:Jake Jackson modified from AF2.3.1 Sanjay Kumar Srikakulam script

# Default variable values (unless updated by the user flags)
use_gpu=true
run_relax=true
enable_gpu_relax=true
num_multimer_predictions_per_model=5
model_preset=monomer
db_preset=full_dbs
use_precomputed_msas=false
benchmark=true

#AF unmasked defaults 
separate_homomer_msas=true
cross_chain_templates=false
dropout=false

# Function to display script usage
usage() {
    echo ""
    echo "Please make sure all required parameters are given"
    echo "Usage: $0 <OPTIONS>"
    echo "Required Parameters:"
    echo "  -o <output_dir>          Path to a directory that will store the results"
    echo "  -f <fasta_path>          Path to a FASTA file containing sequences"
    echo "                           If a FASTA file contains multiple sequences, it will be folded as a multimer"
    echo "  -t <max_template_date>   Maximum template release date to consider (ISO-8601 format, e.g., YYYY-MM-DD)"
    echo "                           Important when folding historical test sets"
    echo ""
    echo "Optional Parameters:"
    echo "  -g <use_gpu>             Enable NVIDIA runtime for GPU usage (default: true)"
    echo "  -r <run_relax>           Run the final relaxation step on predicted models (default: true)"
    echo "                           Turning this off may prevent stereochemical violations but may help resolve issues with relaxation"
    echo "  -e <enable_gpu_relax>    Run relax on GPU if GPU is enabled (default: true)"
    echo "  -n <openmm_threads>      Number of OpenMM threads to use (default: all available cores)"
    # echo "  -a <gpu_devices>         Comma-separated list of GPU devices for 'CUDA_VISIBLE_DEVICES' (default: 0)"
    echo "  -m <model_preset>        Preset model configuration:"
    echo "                           - monomer: Standard monomer model"
    echo "                           - monomer_casp14: Monomer model with extra ensembling"
    echo "                           - monomer_ptm: Monomer model with pTM head"
    echo "                           - multimer: Multimer model (default: 'monomer')"
    echo "  -c <db_preset>           Preset MSA database configuration:"
    echo "                           - reduced_dbs: Smaller genetic database configuration"
    echo "                           - full_dbs: Full genetic database configuration (default: 'full_dbs')"
    echo "  -p <use_precomputed_msas> Use MSAs from disk without checking sequence, database, or config changes (default: 'false')"
    echo "  -l <num_multimer_predictions_per_model> Number of predictions per model for multimer (default: 5)"
    echo "  -b <benchmark>           Run multiple JAX evaluations for timing analysis (default: 'false')"
    echo ""
    echo "AlphaFold Unmasked Parameters: ----------------------------------------------------------------" 
    echo " s | --separate-homomer-msas <separate_homomer_msas> Disable automatic pairing of MSAs from identical sequences"
    echo " x | --flag-file <flag_file> Template flag file genrated with prepare_templates.py"
    echo " y | --cross-chain-templates <cross_chain_templates>" Use cross chain templates
    echo " z | --dropout <dropout>"  Use dropout
    exit 1
}

has_argument() {
    [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*)  ]];
}

extract_argument() {
  echo "${2:-${1#*=}}"
}

# Function to handle options and arguments
handle_options() {
  while [ $# -gt 0 ]; do
    case $1 in
      -h | --help) usage && exit 0;;
      -d | --data-dir*) data_dir=$(extract_argument $@) && shift;;
      -o | --output-dir*) output_dir=$(extract_argument $@) && shift;;
      -f | --fasta-path*) fasta_path=$(extract_argument $@) && shift;;
      -t | --max-template-date*) max_template_date=$(extract_argument $@) && shift;;
      -g | --use-gpu*) use_gpu=$(extract_argument $@) && shift;;
      -r | --run-relax*) run_relax=$(extract_argument $@) && shift;;
      -e | --enable-gpu-relax*) enable_gpu_relax=$(extract_argument $@) && shift;;
      -n | --openmm-threads*) openmm_threads=$(extract_argument $@) && shift;;
      -m | --model-preset*) model_preset=$(extract_argument $@) && shift;;
      -c | --db-preset*) db_preset=$(extract_argument $@) && shift;;
      -p | --use-precomputed-msas*) use_precomputed_msas=$(extract_argument $@) && shift;;
      -l | --num-multimer-predictions-per-model*) num_multimer_predictions_per_model=$(extract_argument $@) && shift;;
      -b | --benchmark*) benchmark=$(extract_argument $@) && shift;;
      ## AlphaFold Unmasked Parameters
      -s | --separate-homomer-msas*) separate_homomer_msas=$(extract_argument $@) && shift;;
      -x | --flag-file*) flag_file=$(extract_argument $@) && shift;;
      -y | --cross-chain-templates*) cross_chain_templates=$(extract_argument $@) && shift;;
      -z | --dropout*) dropout=$(extract_argument $@) && shift;;
      *)
        echo "Invalid option: $1" >&2
        usage
        exit 1
        ;;
    esac
    shift
  done
}

# Main script execution
handle_options "$@"

# Parse input and set defaults
if [[ "$data_dir" == "" ]] ; then #Only run if no user input
   #Autoselect correct db: based on add_nvme.sh in utlities 
   data_dir="/projects/ilfgrid/data/alphafold-genetic-databases/"
   nvme_AFDB_nodes=("ilfgridgpun01fl.unicph.domain" "ilfgridgpun03fl.unicph.domain" )
   for item in "${nvme_AFDB_nodes[@]}";
      do if [ "$HOSTNAME" == "$item" ]; then
      data_dir="/alphafold_db"
      echo "Using NVME AF databases :)"
      break
      fi
   done  
fi

#echo "Data dir : $data_dir, Output DIR $output_dir "
if [[ -z "$output_dir" || -z "$fasta_path" || -z "$max_template_date" ]]; then
    echo "Detected Missing Required Parameter output_dir: $output_dir, fasta_path: $fasta_path, max_template_date: $max_template_date" 
    usage
fi

# Validate `model_preset`
if [[ "$model_preset" != "monomer" && "$model_preset" != "monomer_casp14" && 
      "$model_preset" != "monomer_ptm" && "$model_preset" != "multimer" &&
      "$model_preset" != "multimer_v2" ]]; then
    echo "Unknown model preset! Using default ('monomer')"
    model_preset="monomer"
fi

if [[ "$flag_file" == "" ]]; then
    echo "First generate the template flag file with prepare_templates.py and give path"
    exit 1
fi
# Validate `db_preset`
if [[ "$db_preset" != "full_dbs" && "$db_preset" != "reduced_dbs" ]]; then
    echo "Unknown database preset! Using default ('full_dbs')"
    db_preset="full_dbs"
fi

# Determine `use_gpu_relax`
if [[ "$enable_gpu_relax" == true && "$use_gpu" == true ]]; then
    use_gpu_relax="true"
else
    use_gpu_relax="false"
fi

# This bash script looks for the run_alphafold.py script in its current working directory, if it does not exist then exits
current_working_dir=$(pwd)
alphafold_script="$current_working_dir/run_alphafold_mod.py"

if [ ! -f "$alphafold_script" ]; then
    echo "Alphafold python script $alphafold_script does not exist."
    exit 1
fi

# OpenMM threads control
if [[ "$openmm_threads" ]] ; then
    export OPENMM_CPU_THREADS=$openmm_threads
fi

# TensorFlow control
export TF_FORCE_UNIFIED_MEMORY='1'

# JAX control
export XLA_PYTHON_CLIENT_MEM_FRACTION='4.0'

# Path and user config (change me if required)
uniref90_database_path="$data_dir/uniref90/uniref90.fasta"
uniprot_database_path="$data_dir/uniprot/uniprot.fasta"
mgnify_database_path="$data_dir/mgnify/mgy_clusters_2022_05.fa"
bfd_database_path="$data_dir/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt"
small_bfd_database_path="$data_dir/small_bfd/bfd-first_non_consensus_sequences.fasta"
uniref30_database_path="$data_dir/uniref30/UniRef30_2021_03"
pdb_seqres_database_path="$data_dir/pdb_seqres/pdb_seqres.txt"
template_mmcif_dir="$data_dir/pdb_mmcif/mmcif_files"
obsolete_pdbs_path="$data_dir/pdb_mmcif/obsolete.dat"

# Check if alternative pdb70 path is provided
if [[ ! -v pdb70_database_path ]]; then
    pdb70_database_path="$data_dir/pdb70/pdb70"
fi

# Binary path (change me if required)
hhblits_binary_path=$(which hhblits)
hhsearch_binary_path=$(which hhsearch)
jackhmmer_binary_path=$(which jackhmmer)
kalign_binary_path=$(which kalign)

## Unmasked Modifications 
# Prepare Templates (worry about later)
#dropout and cross chain are called without an argument testing them withe defaults
unmasked_args="
  --flagfile=$flag_file
  --separate_homomer_msas=$separate_homomer_msas
  --cross_chain_templates=$cross_chain_templates
  --dropout=$dropout
"

#Same as regular AF
command_args="
  --fasta_paths=$fasta_path
  --output_dir=$output_dir
  --max_template_date=$max_template_date
  --db_preset=$db_preset
  --model_preset=$model_preset
  --benchmark=$benchmark
  --use_precomputed_msas=$use_precomputed_msas
  --num_multimer_predictions_per_model=$num_multimer_predictions_per_model
  --run_relax=$run_relax
  --use_gpu_relax=$use_gpu_relax
  --logtostderr
"

# Database paths
database_paths="
  --uniref90_database_path=$uniref90_database_path
  --mgnify_database_path=$mgnify_database_path
  --data_dir=$data_dir
  --template_mmcif_dir=$template_mmcif_dir
  --obsolete_pdbs_path=$obsolete_pdbs_path
"

# Binary paths
binary_paths="
  --hhblits_binary_path=$hhblits_binary_path
  --hhsearch_binary_path=$hhsearch_binary_path
  --jackhmmer_binary_path=$jackhmmer_binary_path
  --kalign_binary_path=$kalign_binary_path
"

if [[ $model_preset == "multimer" ||$model_preset=="multimer_v2" ]]; then
	database_paths="$database_paths --uniprot_database_path=$uniprot_database_path --pdb_seqres_database_path=$pdb_seqres_database_path"
else
	database_paths="$database_paths --pdb70_database_path=$pdb70_database_path"
fi

if [[ "$db_preset" == "reduced_dbs" ]]; then
	database_paths="$database_paths --small_bfd_database_path=$small_bfd_database_path"
else
	database_paths="$database_paths --uniref30_database_path=$uniref30_database_path --bfd_database_path=$bfd_database_path"
fi


# Run AlphaFold with required parameters
$(python $alphafold_script $unmasked_args $binary_paths $database_paths $command_args)
