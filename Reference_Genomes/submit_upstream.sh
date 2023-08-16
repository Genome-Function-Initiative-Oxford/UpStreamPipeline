#!/bin/bash
#SBATCH --partition=batch
#SBATCH --job-name=DownloadRefGenome
#SBATCH --ntasks=2
#SBATCH --mem=64G
#SBATCH --mail-user=<email>
#SBATCH --time=03-12:00:00
#SBATCH --output=%j_%x.out
#SBATCH --error=%j_%x.err

source /path/to/baseenv/bin/activate upstream

snakemake --configfile=config/analysis.yaml all --cores 1 --unlock
snakemake --configfile=config/analysis.yaml all --cores 1 --rerun-incomplete