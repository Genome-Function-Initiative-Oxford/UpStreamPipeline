#!/bin/bash
#SBATCH --partition=batch
#SBATCH --job-name=Build_UCSC_track_hub
#SBATCH --ntasks=2
#SBATCH --mem=8G
#SBATCH --mail-user=<email>
#SBATCH --time=00-12:00:00
#SBATCH --output=%j_%x.out
#SBATCH --error=%j_%x.err

source /path/to/baseenv/bin/activate upstream

snakemake --configfile=config/analysis.yaml all --cores 1