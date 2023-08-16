import sys

config_system_file = sys.argv[1]
conda_env_path = sys.argv[2]
hicpro_github_path = sys.argv[3]

nfile = open(config_system_file, 'w')

nfile.write("#######################################################################\n")
nfile.write("## HiC-Pro - System settings\n")
nfile.write("#######################################################################\n")
nfile.write("#######################################################################\n")
nfile.write("## Required Software - Specified the DIRECTORY name of the executables\n")
nfile.write("## If not specified, the program will try to locate the executable\n")
nfile.write("## using the 'which' command\n")
nfile.write("#######################################################################\n")
nfile.write("R_PATH = %s/bin\n"%conda_env_path)
nfile.write("BOWTIE2_PATH = %s/bin\n"%conda_env_path)
nfile.write("SAMTOOLS_PATH = %s/bin\n"%conda_env_path)
nfile.write("PYTHON_PATH = %s/bin\n"%conda_env_path)
nfile.write("INSTALL_PATH = %s\n"%hicpro_github_path)
nfile.write("SCRIPTS = %s/scripts\n"%hicpro_github_path)
nfile.write("SOURCES = %s/scripts/src\n"%hicpro_github_path)
nfile.write("ANNOT_DIR = %s/annotation\n"%hicpro_github_path)
nfile.write("CLUSTER_SCRIPT = %s/scripts/make_slurm_script.sh\n"%hicpro_github_path)

nfile.close()
