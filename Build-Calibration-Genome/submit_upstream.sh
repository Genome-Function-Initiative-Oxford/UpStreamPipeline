#!/bin/bash
#SBATCH --partition=batch
#SBATCH --job-name=upstream
#SBATCH --mail-user=<your-email>
#SBATCH --mail-type=end,fail
#SBATCH --output=upstream.log
#SBATCH --mem 64G

source /path/to/baseenv/bin/activate upstream
#/t1-data/project/hugheslab/sriva/anaconda3/bin/activate
snakemake --configfile=config/analysis.yaml all --cores 1