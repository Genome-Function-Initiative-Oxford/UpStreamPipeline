#!/bin/bash
#SBATCH --partition=batch
#SBATCH --job-name=DownloadRefGenome
#SBATCH --ntasks=2
#SBATCH --mem=64G
#SBATCH --mail-user=simone.riva@imm.ox.ac.uk
#SBATCH --time=03-12:00:00
#SBATCH --output=%j_%x.out
#SBATCH --error=%j_%x.err

source /project/hugheslab/sriva/anaconda3/bin/activate upstream
snakemake --configfile=config/analysis.yaml all --cores 1 --unlock
snakemake --configfile=config/analysis.yaml all --cores 1 --rerun-incomplete