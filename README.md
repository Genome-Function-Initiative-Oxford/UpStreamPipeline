# Upstream pipelines repository

### Warning for Oxford University CCB users
<ins>When using this repository, use the default terminal and do not load any module in the server (if logged-in).</ins>


## Installation instructions for conda environment

### Clone the repository
```
git clone git@github.com:Genome-Function-Initiative-Oxford/UpStreamPipeline.git
cd UpStreamPipeline
```

### Anaconda installation
- Check if [Anaconda](https://www.anaconda.com), [Miniconda](https://docs.conda.io/en/latest/miniconda.html), or [Mambaforge](https://mamba.readthedocs.io/en/latest/installation.html) is installed, using ```which conda```   
- If installed the output is: ```~/anaconda3/condabin/conda```.
- If [Anaconda](https://www.anaconda.com), [Miniconda](https://docs.conda.io/en/latest/miniconda.html), or [Mambaforge](https://mamba.readthedocs.io/en/latest/installation.html) is not installed: 
    - We recommend to install [Mambaforge](https://mamba.readthedocs.io/en/latest/installation.html), since it has already integrated mamba for a fast and parallelisable installation.
    - Download [Mambaforge](https://mamba.readthedocs.io/en/latest/installation.html) ([Anaconda](https://www.anaconda.com) or [Miniconda](https://docs.conda.io/en/latest/miniconda.html)) using ```wget```, e.g. ```wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh```.
    - Run the installer through ```sh```, e.g. ```sh Mambaforge-Linux-x86_64.sh``` and follow the command on the screen (carefully).

### Create Anaconda environment:
Activate conda env base (if not active): ```conda activate base``` or ```conda activate```

There are two ways to create the conda env upstream environment:
1) Using mamba (if [Mambaforge](https://mamba.readthedocs.io/en/latest/installation.html) was installed): ```mamba env create --file=envs/upstream.yml``` and follow the on screen instruction.
2) Using conda: ```conda env create --file=envs/upstream.yml``` and follow the on screen instruction.

Now, the upstream environment is created and needs to be activated: ```conda activate upstream```. You can then access one of the following pipelines and play with it (enjoy!).
        
### Pipelines:

- In this repository the following upstream pipelines are listed:
    - reference_genome (Download and Index Reference Genomes)
    - genetics/catch-up (Bulk ChIP and ATAC sequencing upstream analysis)
    - *...work in progress..*
    
### Pipeline update:
- If any changes are made to the pipelines, it is possible to update the repository by entering the main folder and pulling the update using:
   ```
   cd UpStreamPipeline # entering in the main folder
   git pull            # pull updates
   ```
- or removing the cloned repository using ```rm -rf UpStreamPipeline``` (using `rm` carefully) and re-clone the repository as described above.
    
<hr>

### Contact us
If you have any suggestions, spot any errors, or have any questions regarding the pipelines, please do no hesitate to contact us anytime.

Email: [<simone.riva@imm.ox.ac.uk>](simone.riva@imm.ox.ac.uk)
