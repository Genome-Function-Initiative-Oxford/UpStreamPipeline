#!/bin/bash
#SBATCH --partition=long
#SBATCH --job-name=bulkRNA
#SBATCH --ntasks=4
#SBATCH --mem=64G
#SBATCH --mail-user=simone.riva@imm.ox.ac.uk
#SBATCH --time=06-23:59:59
#SBATCH --output=%j_%x.out
#SBATCH --error=%j_%x.err

source /project/Wellcome_Discovery/sriva/mambaforge/bin/activate upstream_backup

# select and edit the config file accordingly
# Done
snakemake --configfile=config/analysis.yaml all --cores 8 --unlock
snakemake --configfile=config/analysis.yaml all --cores 8 --rerun-incomplete
