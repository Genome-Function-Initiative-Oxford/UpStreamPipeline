# Upstream pipelines repository

"Upstream" includes the necessary steps to go from raw data output (usually fastq files) to a format which is visually interpretable by a researcher (e.g., bigwigs). These upstream pipelines allow wet-lab scientists to reproducibly analyse their own data without needing any prior knowledge of bioinformatics. These pipelines are built using the snakemake framework and designed to be both user-friendly and to combat the issue of reproducibility in genomic data analysis.


### Currently available pipelines:
Further information is supplied in the README files for each of these pipelines.

#### :heavy_plus_sign: Helper Pipelines
[Reference genomes](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline/tree/main/Reference_Genomes)   
This is designed to streamline the download and index of reference genomes for use in the other pipelines.

[Build Calibration Genome](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline/tree/main/Build-Calibration-Genome)    
This is designed to streamline the catenation and indexing of a reference genome with a spike-in genome for use in the Calibrated ChIP-seq.

#### :dna: Main Pipelines 

##### GENETICS
[genetics/CATCH-UP](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline/tree/main/genetics/CATCH-UP)   
Designed for the upstream analysis of bulk ChIP-seq and ATAC-seq data.

[genetics/Calibrated ChIP-seq](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline/tree/main/genetics/ChIP-Seq-Calibrated)   
This is specifically designed for the analysis of ChIP-seq data across different experimental and biological conditions in which rigorous normalisation is required for comparison across conditions.

[genetics/tCaptureC](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline/tree/main/genetics/tCaptureC)   
A pipeline which can be used for the analysis of both Capture-C and Tiled Capture-C data.  This incorporates the previously published [HiCPro](https://github.com/nservant/HiC-Pro) and [HiCPlotter](https://github.com/akdemirlab/HiCPlotter) tools into one streamlined analysis.

##### TRANSCRIPTOMICS
[transcriptomics/Bulk-RNA-Seq](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline/tree/main/transcriptomics/Bulk-RNA-seq)   
Designed for the analysis of bulk RNA-seq data using the [STAR](https://github.com/alexdobin/STAR) RNA-seq mapping tool.


***
## Getting started
All of the upstream pipelines can be run using the __upstream__ conda environment, please follow the installation instruction detailed below. In doing so, the anlaysis is highly reproducible. 

### Installation instructions for conda environment

#### 1. Clone the repository
```
git clone git@github.com:Genome-Function-Initiative-Oxford/UpStreamPipeline.git
cd UpStreamPipeline
```

#### 2. Install anaconda
Check if [Anaconda](https://www.anaconda.com), [Miniconda](https://docs.conda.io/en/latest/miniconda.html), or [Mambaforge](https://mamba.readthedocs.io/en/latest/installation.html) is installed, using:
```
which conda
```   
If installed, the output should be:
```
~/anaconda3/condabin/conda
```
If [Anaconda](https://www.anaconda.com), [Miniconda](https://docs.conda.io/en/latest/miniconda.html), or [Mambaforge](https://mamba.readthedocs.io/en/latest/installation.html) is not installed, we recommend to install [Mambaforge](https://mamba.readthedocs.io/en/latest/installation.html), since it has already integrated mamba for a fast and parallelisable installation.   


Download [Mambaforge](https://mamba.readthedocs.io/en/latest/installation.html) ([Anaconda](https://www.anaconda.com) or [Miniconda](https://docs.conda.io/en/latest/miniconda.html)):
```
wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh
```
- Run the installer as follows, and follow the on-screen commands.
```
sh Mambaforge-Linux-x86_64.sh
``` 
#### 3. Create Anaconda environment
Activate the conda 'base' environment (if not active): 
```
conda activate base
```

There are two ways to create the conda env upstream environment:
1) Using mamba (if [Mambaforge](https://mamba.readthedocs.io/en/latest/installation.html) was installed), and follow the on screen instructions:
```
mamba env create --file=envs/upstream.yml
```
2) Using conda, and follow the on screen instructions.
```
conda env create --file=envs/upstream.yml
```

#### 4. Activate the environment
Now, the upstream environment is created it needs to be activated: 
```
conda activate upstream
```
You can then use all of our upstream pipelines using this environment, enjoy!

### Environment installation note
CATCH-UP has been successfully tested for the following operating systems: Ubuntu, CentOS, macOS (Intel CPU), and Windows. Unfortunately, it is not possible to install on macOS with M CPUs at the moment. 
For any error in the installation step, please open an [issue](https://github.com/Genome-Function-Initiative-Oxford/UpStreamPipeline/issues) so we can give a general solution for users.

### Reproducibility :repeat:
If required for publication, package versions within the environment can be exported as follows:
```
conda env export > upstream_environment_versions.yml
```

***

### Pipeline updates :construction:
If any changes are made to the pipelines, it is possible to update the repository by entering the main folder and pulling the update using:
   ```
   # Enter the main folder
   cd UpStreamPipeline

   # Pull updates
   git pull           
   ```
Alternatively, remove the cloned repository and then re-clone the repository as described above.   
Warning: use rm carefully!

```
rm -rf UpStreamPipeline
``` 
<hr>

### :warning: Warning for University of Oxford CCB users :warning:
When using this repository, use the default terminal and __do not__ load any module in the server (if logged-in).

***

### Contact us
If you have any suggestions, spot any errors, or have any questions regarding the pipelines, please do no hesitate to contact us anytime.   

:email: &emsp; [<simone.riva@imm.ox.ac.uk>](simone.riva@imm.ox.ac.uk)
