samples_r=pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"fastqfile_home_dir.txt", header=None)[0]
if config["single_paired_end"]=="paired":
    samples_r = [re.sub("_R\d+.fastq.gz", "", sr) for sr in list(samples_r)]
else:
    samples_r = [re.sub(".fastq.gz", "", sr) for sr in list(samples_r)]
    
rule trackDb:
    input:
        expand(os.path.join(config["analysis_name"]+os.sep+config["bam_coverage_log"], "{sample_r_all}_downsampled.txt"), sample_r_all=list(samples_r)),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["track"], "trackDb.txt"),
    params:
        bigdataurl=config["bigDataUrl"],
        bigwigs=config["analysis_name"]+os.sep+config["bam_coverage"],
    log:
        os.path.join(config["analysis_name"], "logs/12_track/trackDb.txt"),
    run:
        import glob, os
        bws = glob.glob(params.bigwigs+os.sep+'*')
        with open(str(output), 'w') as nfile:
            for idx, bw in enumerate(bws):
                name = bw.split('.bw')[0].split('/')[-1]
                nfile.write('track %s\n'%name)
                nfile.write('bigDataUrl %s%s.bw\n'%(params.bigdataurl, name))
                nfile.write('shortLabel %s\n'%name)
                nfile.write('longLabel %s\n'%name)
                nfile.write('type bigWig\n')
                nfile.write('visibility full\n')
                nfile.write('autoScale on\n')
                nfile.write('priority 1\n\n')
