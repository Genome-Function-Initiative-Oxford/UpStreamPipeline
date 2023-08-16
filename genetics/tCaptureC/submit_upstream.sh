#!/bin/bash
#SBATCH --partition=batch
#SBATCH --job-name=Oudelaar-AL-Tiled
#SBATCH --ntasks=4
#SBATCH --mem=64G
#SBATCH --mail-user=simone.riva@imm.ox.ac.uk
#SBATCH --time=14-12:00:00
#SBATCH --output=%j_%x.out
#SBATCH --error=%j_%x.err

# source /path/to/baseenv/bin/activate upstream
source /project/Wellcome_Discovery/sriva/mambaforge/bin/activate upstream

snakemake --configfile=config/Oudelaar-AL-Tiled.yaml all --cores 8 --unlock
snakemake --configfile=config/Oudelaar-AL-Tiled.yaml all --cores 8 --rerun-incomplete