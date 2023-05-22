# Upstream pipelines repository

### Warning for Oxford University CCB users
<ins>When using this repository, use the default terminal and do not load any module in the server (if logged-in).</ins>


## Installation instructions for conda environment

### Clone the repository
```
git clone git@github.com:Hughes-Genome-Group/UpStreamPipeline.git
cd UpStreamPipeline
```

### Anaconda installation
- Check if [Anaconda](https://www.anaconda.com) is installed: ```which conda```   
- Anaconda is installed if the output is: ```~/anaconda3/condabin/conda```    
- If Anaconda is not installed: 
    - downlaod [Anaconda](https://www.anaconda.com), [Miniconda](https://docs.conda.io/en/latest/miniconda.html), or [Mambaforge](https://mamba.readthedocs.io/en/latest/installation.html), using ```wget```, e.g. ```wget https://repo.continuum.io/archive/Anaconda3-2021.11-Linux-x86_64.sh```
    - run the installer thrugh ```sh```, e.g. ```sh Anaconda3-2021.11-Linux-x86_64.sh``` and follow the command on the screen (carefully)
NB: If you do not want to use Anaconda, it is possible to use [Miniconda](https://docs.conda.io/en/latest/miniconda.html) or [Mambaforge](https://mamba.readthedocs.io/en/latest/installation.html) (we recommend [Mambaforge](https://mamba.readthedocs.io/en/latest/installation.html), since mamba is already included).

### Create Anaconda environment:
Activate Anaconda env base (if not active): ```conda activate base``` or ```conda activate```

There are two ways to create the upstream environment:
1) Create conda env upstream using conda: ```conda env create --file=envs/upstream.yml``` and follow the on screen instruction.

2) To make the installation faster, you can install mamba (point **a**) (unless [Mambaforge](https://mamba.readthedocs.io/en/latest/installation.html) was installed, which already contains mamba, and you can skip to point (**b**): 
    **a**) ```conda install -c conda-forge mamba``` and follow the screen. If the command raises any conflicts, try ```conda install mamba -n base -c conda-forge```. 
    **b**) Then, create the env upstream using mamba: ```mamba env create --file=envs/upstream.yml``` and follow the on screen instruction.

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
