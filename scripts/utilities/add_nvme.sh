#!/bin/bash
#Author: Jake Jackson
#Desciption: Automatically assign the fastest Alphafold Database
#Checks if the current node, is one of the ones we know has faster nvme database automatically.
AFDB_DIR="/projects/ilfgrid/data/alphafold-genetic-databases/"
nvme_AFDB_nodes=("ilfgridgpun01fl.unicph.domain" "ilfgridgpun03fl.unicph.domain" )
for item in "${nvme_AFDB_nodes[@]}";
    do if [ "$HOSTNAME" == "$item" ]; then
        AFDB_DIR="/alphafold_db" #overwite path
        echo "Using NVME AF databases :)"
        break
        fi
done 