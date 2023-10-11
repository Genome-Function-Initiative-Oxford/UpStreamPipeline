origin_fastq_raw=pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"1_fastqfile_home_dir.txt", header=None)[0]
origin_fastq    =[of.split(".fastq.gz")[0] for of in list(origin_fastq_raw)]

if config["concatenate_fastq"] == "True":
    origin_fastq_raw_concat = pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"2_fastqfile_concat.txt", header=None)[0]
    origin_fastq_concat = [of.split(".fastq.gz")[0] for of in list(origin_fastq_raw_concat)]
    read_folder = config["reads_concat"]
else:
    read_folder = config["reads"]
    origin_fastq_conact = origin_fastq

ext_star=["_R1.fastq.gz", "_R2.fastq.gz"]
    
samples_r = pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"samples.csv", index_col="sample", sep="\t")

genomeV = config['genome_built_version']

if config['merge_bams']=='True':
    try:
        merge_sample = pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"3_merge_bams.txt", header=None)[0].tolist()
    except:
        print("You must provide 'merge.txt' file")
        sys.exit()
    
if config["single_paired_end"] == "paired":
    add_p_featurecounts = " -p"
else:
    add_p_featurecounts = ""
    
rule move_fastq:
    input:
        r1=os.path.join(config["fastq_home_dir"], "{sample_or}.fastq.gz"),
    output:
        r1=os.path.join(config["analysis_name"]+os.sep+config["reads"], "{sample_or}.fastq.gz"),
    params:
        config_name=config["analysis_name"],
    log:
        os.path.join(config["analysis_name"], "logs/01_move_fastq/{sample_or}.txt"),
    shell:
        """
            cp {input.r1} {output.r1}
            echo Copy DONE! >> {log}
        """


rule concatenating:
    input:
        expand(os.path.join(config["analysis_name"]+os.sep+config["reads"], "{samp}.fastq.gz"), samp=list(origin_fastq)),
    output:
        f=os.path.join(config["analysis_name"]+os.sep+config["reads_concat"], "{sample}.txt"),
    params:
        folderin=config["analysis_name"]+os.sep+config["reads"],
        folderout=config["analysis_name"]+os.sep+config["reads_concat"],
        end=config["single_paired_end"],
        concat=config["concatenate_fastq"],
    log:
        os.path.join(config["analysis_name"], "logs/01_move_fastq/{sample}_concat.txt"),
    run:
        if params.concat == "True":
            import glob, subprocess
            if params.end == 'paired':
                
                infastq1 = glob.glob(params.folderin+os.sep+wildcards.sample+"*"+"_R1.fastq.gz")
                infastq2 = glob.glob(params.folderin+os.sep+wildcards.sample+"*"+"_R2.fastq.gz")

                outfasq1 = params.folderout+os.sep+wildcards.sample+"_R1.fastq.gz"
                outfasq2 = params.folderout+os.sep+wildcards.sample+"_R2.fastq.gz"

                command = ['cat %s > %s'%(" ".join(infastq1), outfasq1)]
                subprocess.run(command, shell=True)
                
                command = ['cat %s > %s'%(" ".join(infastq2), outfasq2)]
                subprocess.run(command, shell=True)
            
            else:
                
                infastq = glob.glob(params.folderin+os.sep+wildcards.sample+"*"+".fastq.gz")
                outfasq = params.folderout+os.sep+wildcards.sample+".fastq.gz"

                command = ['cat %s > %s'%(" ".join(infastq), outfasq)]
                subprocess.run(command, shell=True)
            
            with open(output.f, 'w') as nfile:
                nfile.write("Concatenation Done!")
        else:
            with open(output.f, 'w') as nfile:
                nfile.write("Skip concatenation!")


rule trimming:
    input:
        c=os.path.join(config["analysis_name"]+os.sep+config["reads_concat"], "{sample}.txt"),
        # f=expand(os.path.join(config["analysis_name"]+os.sep+read_folder, "{samp}.fastq.gz"), samp=list(origin_fastq_conact)),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["trimming_qc"], "{sample}_qc.txt"),
    params:
        config_name=config["analysis_name"],
        cut_bool=config["cutadapters_bool"],
        end=config["single_paired_end"],
        out_folder=config["analysis_name"]+os.sep+config["trimming"],
        in_fastq=os.path.join(config["analysis_name"]+os.sep+read_folder, "{sample}"),
        out_fastq=os.path.join(config["analysis_name"]+os.sep+config["trimming"], "{sample}"),
        trimming_PE_extra=config["trimming_PE_extra"],
        trimming_SE_extra=config["trimming_SE_extra"],
        threads=4,
        info_trim_file=config["analysis_name"]+os.sep+config["trimming_qc"]+os.sep+"Untrimmed.txt",
    log:
        os.path.join(config["analysis_name"], "logs/02_trimming/{sample}.txt"),
    shell:
        """
            if [ {params.cut_bool} == "True" ]
            then
                mkdir -p {params.out_folder}
                if [ {params.end} == "paired" ]
                then
                    trimmomatic PE -threads {params.threads} -trimlog {log} {params.in_fastq}_R1.fastq.gz {params.in_fastq}_R2.fastq.gz {params.out_fastq}_R1.fastq.gz {params.out_fastq}_R1_orphan.fastq.gz {params.out_fastq}_R2.fastq.gz {params.out_fastq}_R2_orphan.fastq.gz {params.trimming_PE_extra}
                    echo trimming PE DONE! >> {output}
                else
                    trimmomatic SE -threads {params.threads} -trimlog {log} {params.in_fastq}.fastq.gz {params.out_fastq}.fastq.gz {params.trimming_SE_extra}
                    echo trimming SE DONE! >> {output}
                fi
            else
                mkdir -p {params.out_folder}
                if [ {params.end} == "paired" ]
                then
                    cp {params.in_fastq}_R1.fastq.gz {params.out_fastq}_R1.fastq.gz
                    cp {params.in_fastq}_R2.fastq.gz {params.out_fastq}_R2.fastq.gz
                    echo Skip trimming PE! >> {output}
                else
                    cp {params.in_fastq}.fastq.gz {params.out_fastq}.fastq.gz
                    echo These fastq files have not been trimmed!!! >> {params.info_trim_file}
                    echo Skip trimming SE! >> {output}
                fi
            fi
        """


rule star:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["trimming_qc"], "{sample}_qc.txt"),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["star"], "{sample}Aligned.out.bam"),
    params:
        config_name=config["analysis_name"],
        store_star=config["analysis_name"]+os.sep+config["star"],
        sample_p=expand(config["analysis_name"]+os.sep+os.path.join(config["trimming"], "{samples}"), samples=["{sample}%s"%extB for extB in ext_star]),
        sample_s=expand(config["analysis_name"]+os.sep+os.path.join(config["trimming"], "{samples}"), samples=["{sample}.fastq.gz"]),
        idx=config["star_dir"],
        out_folder=config["analysis_name"]+os.sep+config["star"],
        threads="8",
        end=config["single_paired_end"],
        extra="",
    log:
        os.path.join(config["analysis_name"], "logs/03_star/{sample}_%s.txt"%genomeV),
    shell:
        """
            mkdir -p {params.out_folder}
            if [ {params.end} == "paired" ]
            then
                STAR --genomeDir {params.idx}/ --readFilesIn {params.sample_p[0]} {params.sample_p[1]} --readFilesCommand zcat --outSAMtype BAM Unsorted --runThreadN {params.threads} --outReadsUnmapped Fastx --outFileNamePrefix {params.store_star}/{wildcards.sample}
            else
                STAR --genomeDir {params.idx}/ --readFilesIn {params.sample_s} --readFilesCommand zcat --outSAMtype BAM Unsorted --runThreadN {params.threads} --outReadsUnmapped Fastx --outFileNamePrefix {params.store_star}/{wildcards.sample}
            fi
        """


rule samtools_sort:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["star"], "{sample}Aligned.out.bam"),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["sorted"], "{sample}_%s.bam"%genomeV),
    log:
        os.path.join(config["analysis_name"], "logs/04_samtools_sort/{sample}_%s.txt"%genomeV),
    params:
        config_name=config["analysis_name"],
        extra=config["samtools_sort_extra"],
    threads: 8
    wrapper:
        "v1.3.2/bio/samtools/sort"      


rule merge_bam:
    input:
        bam=expand(config["analysis_name"]+os.sep+os.path.join(config["sorted"], "{samples}_%s.bam"%genomeV), samples=list(samples_r.index)),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["merge"], "{sample_merged}_%s.bam"%genomeV),
    params:
        config_name=config["analysis_name"],
        folder_sorted=config["analysis_name"]+os.sep+config["sorted"],
        folder_merge_bams=config["analysis_name"]+os.sep+config["merge"],
        merge_bams=config["merge_bams"],
    log:
        os.path.join(config["analysis_name"], "logs/05_merge/{sample_merged}_%s.txt"%genomeV),
    shell:
        """
            mkdir -p {params.folder_merge_bams}
            if [ "{params.merge_bams}" == "True"  ]
            then
                samtools merge {output} {params.folder_sorted}/{wildcards.sample_merged}*
            else
                cp {params.folder_sorted}/{wildcards.sample_merged}* {output}
            fi
        """         
        
        
rule mark_duplicates:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["merge"], "{sample_merged}_%s.bam"%genomeV),
    output:
        bam=os.path.join(config["analysis_name"]+os.sep+config["duplicates"], "{sample_merged}_%s.bam"%genomeV),
        metrics=os.path.join(config["analysis_name"]+os.sep+config["duplicates_qc"], "{sample_merged}_%s.txt"%genomeV),
    log:
        os.path.join(config["analysis_name"], "logs/06_mark_duplicates/{sample_merged}_%s.txt"%genomeV),
    params:
        config_name=config["analysis_name"],
        extra=config["mark_duplicates_extra"],
    resources:
        mem_mb=1024,
    wrapper:
        "v1.3.2/bio/picard/markduplicates" 
        
        
rule move_sorted_dedup:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["duplicates"], "{sample_merged}_%s.bam"%genomeV),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["indices"], "{sample_merged}_%s.bam"%genomeV),
    params:
        config_name=config["analysis_name"],
        folder_samtools_index=config["analysis_name"]+os.sep+config["indices"],
    log:
        os.path.join(config["analysis_name"], "logs/07_samtools_index/01_move_sorted_dedup/{sample_merged}_%s.txt"%genomeV),
    shell:
        """
            mkdir -p {params.folder_samtools_index}
            cp {input} {output}
        """ 
        
        
rule samtools_index:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["indices"], "{sample_merged}_%s.bam"%genomeV),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["indices"], "{sample_merged}_%s.bam.bai"%genomeV),        
    log:
        os.path.join(config["analysis_name"], "logs/07_samtools_index/02_samtools_index/{sample_merged}_%s.txt"%genomeV),
    params:
        config_name=config["analysis_name"],
        extra=config["samtools_index_extra"], 
    threads: 4
    wrapper:
        "v1.3.2/bio/samtools/index"       
        
        
rule bam_coverage:
    input:
        bam=os.path.join(config["analysis_name"]+os.sep+config["indices"], "{sample_merged}_%s.bam"%genomeV),
        index=os.path.join(config["analysis_name"]+os.sep+config["indices"], "{sample_merged}_%s.bam.bai"%genomeV),        
    output:
        os.path.join(config["analysis_name"]+os.sep+config["bam_coverage"], "{sample_merged}_%s.bw"%genomeV),
    params:
        config_name=config["analysis_name"],
        extra1=config["bam_coverage_params1"],
        extra2=config["bam_coverage_params2"],
        end=config["single_paired_end"],
    log:
        os.path.join(config["analysis_name"], "logs/08_bam_coverage/{sample_merged}_%s.txt"%genomeV),
    shell:
        """
            if [ {params.end} == "paired" ]
            then
                bamCoverage -b {input.bam} -o {output} {params.extra1} {params.extra2}
            else
                bamCoverage -b {input.bam} -o {output} {params.extra1}
            fi
        """
        

rule feature_counts:
    input:
        sam=os.path.join(config["analysis_name"]+os.sep+config["indices"], "{sample_merged}_%s.bam"%genomeV),
        sambai=os.path.join(config["analysis_name"]+os.sep+config["indices"], "{sample_merged}_%s.bam.bai"%genomeV),
        annotation=config["gtf_annotation"],
    output:
        multiext(os.path.join(config["analysis_name"]+os.sep+config["feature_counts"], "{sample_merged}_%s"%genomeV),
                 ".featureCounts",
                 ".featureCounts.summary",
                 ".featureCounts.jcounts"),
    threads:
        2
    params:
        tmp_dir="",   # implicitly sets the --tmpDir flag
        r_path="",    # implicitly sets the --Rpath flag
        extra="-O --fracOverlap 0.2%s"%add_p_featurecounts
    log:
        os.path.join(config["analysis_name"], "logs/09_feature_counts/{sample_merged}_%s.txt"%genomeV),
    wrapper:
        "0.72.0/bio/subread/featurecounts"



            