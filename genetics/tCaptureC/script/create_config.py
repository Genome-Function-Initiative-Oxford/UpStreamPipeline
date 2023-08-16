import sys

output = sys.argv[1]
JOB_NAME = sys.argv[2]
JOB_MAIL = sys.argv[3]
BOWTIE2_IDX_PATH = sys.argv[4]
REFERENCE_GENOME = sys.argv[5]
GENOME_SIZE = sys.argv[6]
CAPTURE_TARGET = sys.argv[7]
GENOME_FRAGMENT = sys.argv[8]
LIGATION_SITE = sys.argv[9]
BIN_SIZE = sys.argv[10].split(",")

nfile = open(output, 'w')


nfile.write("# Please change the variable settings below if necessary\n")
nfile.write("#########################################################################\n")
nfile.write("## Paths and Settings  - Do not edit !\n")
nfile.write("#########################################################################\n\n")
nfile.write("TMP_DIR = tmp\n")
nfile.write("LOGS_DIR = logs\n")
nfile.write("BOWTIE2_OUTPUT_DIR = bowtie_results\n")
nfile.write("MAPC_OUTPUT = hic_results\n")
nfile.write("RAW_DIR = rawdata\n\n")
nfile.write("#######################################################################\n")
nfile.write("## SYSTEM AND SCHEDULER - Start Editing Here !!\n")
nfile.write("#######################################################################\n\n")
nfile.write("N_CPU = 2\n")
nfile.write("LOGFILE = hicpro.log\n")
nfile.write("JOB_NAME = %s\n"%JOB_NAME)
nfile.write("JOB_MEM = 10gb\n")
nfile.write("JOB_WALLTIME = 600:00:00\n")
nfile.write("JOB_QUEUE = batch\n")
nfile.write("JOB_MAIL = %s\n\n"%JOB_MAIL)
nfile.write("#########################################################################\n")
nfile.write("## Data\n")
nfile.write("#########################################################################\n\n")
nfile.write("PAIR1_EXT = _R1\n")
nfile.write("PAIR2_EXT = _R2\n\n")
nfile.write("#######################################################################\n")
nfile.write("## Alignment options\n")
nfile.write("#######################################################################\n\n")
nfile.write("FORMAT = phred33\n")
nfile.write("MIN_MAPQ = 0\n")
nfile.write("BOWTIE2_IDX_PATH = %s\n"%BOWTIE2_IDX_PATH)
nfile.write("BOWTIE2_GLOBAL_OPTIONS = --very-sensitive -L 30 --score-min L,-0.6,-0.2 --end-to-end --reorder\n")
nfile.write("BOWTIE2_LOCAL_OPTIONS =  --very-sensitive -L 20 --score-min L,-0.6,-0.2 --end-to-end --reorder\n\n")
nfile.write("#######################################################################\n")
nfile.write("## Annotation files\n")
nfile.write("#######################################################################\n\n")
nfile.write("REFERENCE_GENOME = %s\n"%REFERENCE_GENOME)
nfile.write("GENOME_SIZE = %s\n\n"%GENOME_SIZE)
nfile.write("#######################################################################\n")
nfile.write("## Capture Hi-C analysis\n")
nfile.write("#######################################################################\n\n")
nfile.write("CAPTURE_TARGET = %s\n"%CAPTURE_TARGET)
nfile.write("REPORT_CAPTURE_REPORTER = 0\n\n")
nfile.write("#######################################################################\n")
nfile.write("## Digestion Hi-C\n")
nfile.write("#######################################################################\n\n")
nfile.write("GENOME_FRAGMENT = %s\n"%GENOME_FRAGMENT)
nfile.write("LIGATION_SITE = %s\n"%LIGATION_SITE)
nfile.write("MIN_FRAG_SIZE = 20\n")
nfile.write("MAX_FRAG_SIZE = 100000\n")
nfile.write("MIN_INSERT_SIZE = 50\n")
nfile.write("MAX_INSERT_SIZE = 1000\n\n")
nfile.write("#######################################################################\n")
nfile.write("## Hi-C processing\n")
nfile.write("#######################################################################\n\n")
nfile.write("MIN_CIS_DIST =\n")
nfile.write("GET_ALL_INTERACTION_CLASSES = 1\n")
nfile.write("GET_PROCESS_SAM = 1\n")
nfile.write("RM_SINGLETON = 1\n")
nfile.write("RM_MULTI = 1\n")
nfile.write("RM_DUP = 1\n\n")
nfile.write("#######################################################################\n")
nfile.write("## Contact Maps\n")
nfile.write("#######################################################################\n\n")
nfile.write("BIN_SIZE = %s %s\n"%(BIN_SIZE[0], BIN_SIZE[1]))
nfile.write("MATRIX_FORMAT = upper\n\n")
nfile.write("#######################################################################\n")
nfile.write("## ICE Normalization\n")
nfile.write("#######################################################################\n\n")
nfile.write("MAX_ITER = 100\n")
nfile.write("FILTER_LOW_COUNT_PERC = 0\n")
nfile.write("FILTER_HIGH_COUNT_PERC = 0\n")
nfile.write("EPS = 0.1\n")
nfile.close()