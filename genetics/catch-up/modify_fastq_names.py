import os, glob, sys

path = sys.argv[1]

print("Modifying fastq names in %s folder..."%path)
fastqs = glob.glob(path+os.sep+"*.fastq.gz")
if len(fastqs) == 0:
	fastqs = glob.glob(path+os.sep+"*.fq.gz")
if len(fastqs) == 0:
	print("Something wrong with the fastq files!")
	sys.exit(0)
for fastq in fastqs:
	old = fastq
	new = fastq.replace("_001.fastq.gz", ".fastq.gz")
	new = new.replace("_001.fq.gz", ".fastq.gz")
	new = new.replace(".fq.gz", ".fastq.gz")
	os.rename(old, new)
print("Done.")
