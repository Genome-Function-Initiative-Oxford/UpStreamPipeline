#!/bin/bash
#SBATCH --partition=long
#SBATCH --job-name=calibrated
#SBATCH --ntasks=1
#SBATCH --mail-user=simone.riva@imm.ox.ac.uk
#SBATCH --mail-type=end,fail
#SBATCH --mem 64G
#SBATCH --time=06-23:59:59
#SBATCH --output=%j_%x.out
#SBATCH --error=%j_%x.err

source /project/Wellcome_Discovery/sriva/mambaforge/bin/activate upstream_backup

snakemake --configfile=config/emily_PE.yaml all --cores 4 --unlock
snakemake --configfile=config/emily_PE.yaml all --cores 4 --rerun-incomplete