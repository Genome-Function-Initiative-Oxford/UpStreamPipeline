samples_r = pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"samples.csv", index_col="sample", sep="\t")

genomeV = config['genome_built_version']

if config['merge_bams']=='True':
    try:
        merge_sample = pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"3_merge_bams.txt", header=None)[0].tolist()
    except:
        print("You must provide 'merge.txt' file")
        sys.exit()
else:
    merge_sample = list(samples_r.index)
    
    
rule trackDb:
    input:
        expand(config["analysis_name"]+os.sep+os.path.join(config["bam_coverage"], "{sample_merged}_%s.bw"%genomeV), sample_merged=list(merge_sample)),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["track"], "trackDb.txt"),
    params:
        bigdataurl=config["bigDataUrl"],
        bigwigs=config["analysis_name"]+os.sep+config["bam_coverage"],
        public_output_dir=config["public_output_dir"],
        tag_public_output_dir=config["tag_public_output_dir"],
    log:
        os.path.join(config["analysis_name"], "logs/10_track/trackDb.txt"),
    run:
        import glob, os
        bws = glob.glob(params.bigwigs+os.sep+'*')
        with open(str(output), 'w') as nfile:
            for idx, bw in enumerate(bws):
                name = bw.split('.bw')[0].split('/')[-1]
                nfile.write('track %s\n'%name)
                nfile.write('bigDataUrl %s%s.bw\n'%(params.bigdataurl+params.public_output_dir+os.sep+params.tag_public_output_dir, name))
                nfile.write('shortLabel %s\n'%name)
                nfile.write('longLabel %s\n'%name)
                nfile.write('type bigWig\n')
                nfile.write('visibility full\n')
                nfile.write('autoScale on\n')
                nfile.write('priority 1\n\n')
