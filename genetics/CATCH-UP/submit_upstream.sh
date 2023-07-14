#!/bin/bash
#SBATCH --partition=<partition-name>
#SBATCH --job-name=<job-name>
#SBATCH --ntasks=2
#SBATCH --mem=64G
#SBATCH --mail-user=<your-email>
#SBATCH --time=03-12:00:00
#SBATCH --output=%j_%x.out
#SBATCH --error=%j_%x.err

source /path/to/baseenv/bin/activate upstream

snakemake --configfile=config/tutorial.yaml all --cores 2 --unlock
snakemake --configfile=config/tutorial.yaml all --cores 2 --rerun-incomplete
