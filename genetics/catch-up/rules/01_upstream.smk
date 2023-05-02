origin_fastq_raw=pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"fastqfile_home_dir.txt", header=None)[0]
origin_fastq    =[of.split(".fastq.gz")[0] for of in list(origin_fastq_raw)]

ext_aligner=["_R1.fastq.gz", "_R2.fastq.gz"]
    
samples_r = pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"samples.csv", index_col="sample", sep="\t")

if config['merge_bams']=='True':
    try:
        merge_sample = pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"merge_bams.txt", header=None)[0].tolist()
    except:
        print("You must provide 'merge.txt' file")
        sys.exit()
    
    
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


rule trimming:
    input:
        expand(os.path.join(config["analysis_name"]+os.sep+config["reads"], "{samp}.fastq.gz"), samp=list(origin_fastq)),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["trimming_qc"], "{sample}_qc.txt"),
    params:
        config_name=config["analysis_name"],
        cut_bool=config["cutadapters_bool"],
        end=config["single_paired_end"],
        out_folder=config["analysis_name"]+os.sep+config["trimming"],
        in_fastq=os.path.join(config["analysis_name"]+os.sep+config["reads"], "{sample}"),
        out_fastq=os.path.join(config["analysis_name"]+os.sep+config["trimming"], "{sample}"),
        trimming_PE_extra=config["trimming_PE_extra"],
        trimming_SE_extra=config["trimming_SE_extra"],
        threads="4",
    log:
        os.path.join(config["analysis_name"], "logs/02_trimming/{sample}.txt"),
    shell:
        """
            if [ {params.cut_bool} == "True" ]
            then
                mkdir -p {params.out_folder}
                if [ {params.end} == "paired" ]
                then
                    trimmomatic PE -threads {threads} {params.in_fastq}_R1.fastq.gz {params.in_fastq}_R2.fastq.gz {params.out_fastq}_R1.fastq.gz {params.out_fastq}_R1_orphan.fastq.gz {params.out_fastq}_R2.fastq.gz {params.out_fastq}_R2_orphan.fastq.gz {params.trimming_PE_extra} > {output}
                    echo trimming PE DONE! >> {log}
                else
                    trimmomatic SE -threads {threads} {params.in_fastq}.fastq.gz {params.out_fastq}.fastq.gz {params.out_fastq}_orphan.fastq.gz {params.trimming_SE_extra} > {output}
                    echo trimming SE DONE! >> {log}
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
                    echo Skip trimming SE! >> {output}
                fi
            fi
        """


rule aligner:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["trimming_qc"], "{sample}_qc.txt"),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["aligner"], "{sample}.bam"),
    params:
        config_name=config["analysis_name"],
        sample_p=expand(config["analysis_name"]+os.sep+os.path.join(config["trimming"], "{samples}"), samples=["{sample}%s"%extB for extB in ext_aligner]),
        sample_s=expand(config["analysis_name"]+os.sep+os.path.join(config["trimming"], "{samples}"), samples=["{sample}.fastq.gz"]),
        aligner_algorithm=config['aligner_algorithm'],
        idx=config["aligner_dir"],
        out_folder=config["analysis_name"]+os.sep+config["aligner"],
        threads="4",
        end=config["single_paired_end"],
        extra=config["aligner_extra"],
    log:
        os.path.join(config["analysis_name"], "logs/03_aligner/{sample}.txt"),
    shell:
        """
            mkdir -p {params.out_folder}

            if [ {params.aligner_algorithm} == "bowtie2" ]
            then

                if [ {params.end} == "paired" ]
                then
                    (bowtie2 --threads {params.threads} -1 {params.sample_p[0]} -2 {params.sample_p[1]} -x {params.idx} {params.extra} | samtools view -o {output} --output-fmt BAM -) > {log}
                else
                    (bowtie2 --threads {params.threads} -U {params.sample_s} -x {params.idx} {params.extra} | samtools view -o {output} --output-fmt BAM -) > {log}
                fi
            else
                if [ {params.end} == "paired" ]
                then
                    bwa-mem2 mem -t {params.threads} {params.idx} {params.sample_p[0]} {params.sample_p[1]} | samtools view -@ {params.threads} -bh > {output}
                    echo bwa-mem2 Done! >> {log}
                else
                    bwa-mem2 mem -t {params.threads} {params.idx} {params.sample_s} | samtools view -@ {params.threads} -bh > {output}
                    echo bwa-mem2 Done! >> {log}
                fi
            fi
            
        """


rule filtering:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["aligner"], "{sample}.bam"),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["filtering"], "{sample}.bam"),
    log:
        os.path.join(config["analysis_name"], "logs/04_filtering/{sample}.txt"),
    params:
        config_name=config["analysis_name"],
        extra=config["filtering_extra"],
        end=config["single_paired_end"],
        filtering_folder=config["analysis_name"]+os.sep+config["filtering"],
    shell:
        """
            if [ {params.end} == "paired" ]
            then
                samtools view -o {output} {params.extra} {input}
            else
                mkdir -p {params.filtering_folder}
                cp {input} {output}
            fi
        """

        
rule samtools_sort:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["filtering"], "{sample}.bam"),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["sorted"], "{sample}.bam"),
    log:
        os.path.join(config["analysis_name"], "logs/05_samtools_sort/{sample}.txt"),
    params:
        config_name=config["analysis_name"],
        extra=config["samtools_sort_extra"],
    threads: 8
    wrapper:
        "v1.3.2/bio/samtools/sort"  
        

rule mark_duplicates:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["sorted"], "{sample}.bam"),
    output:
        bam=os.path.join(config["analysis_name"]+os.sep+config["duplicates"], "{sample}.bam"),
        metrics=os.path.join(config["analysis_name"]+os.sep+config["duplicates_qc"], "{sample}_metrics.txt"),
    log:
        os.path.join(config["analysis_name"], "logs/06_mark_duplicates/{sample}.txt"),
    params:
        config_name=config["analysis_name"],
        extra=config["mark_duplicates_extra"],
    resources:
        mem_mb=1024,
    wrapper:
        "v1.3.2/bio/picard/markduplicates" 


rule merge_bam:
    input:
        bam=expand(config["analysis_name"]+os.sep+os.path.join(config["duplicates"], "{samples}.bam"), samples=list(samples_r.index)),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["merge"], "{sample_merged}.bam"),
    params:
        config_name=config["analysis_name"],
        folder_sorted=config["analysis_name"]+os.sep+config["sorted"],
        folder_merge_bams=config["analysis_name"]+os.sep+config["merge"],
        merge_bams=config["merge_bams"],
    log:
        os.path.join(config["analysis_name"], "logs/07_merge/01_merge{sample_merged}.txt"),
    shell:
        """
            mkdir -p {params.folder_merge_bams}
            if [ "{params.merge_bams}" == "True" ]
            then
                samtools merge {output} {params.folder_sorted}/{wildcards.sample_merged}*
            else
                cp {params.folder_sorted}/{wildcards.sample_merged}* {output}
            fi
        """      
                
        
rule samtools_index:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["merge"], "{sample_merged}.bam"),  
    output:
        os.path.join(config["analysis_name"]+os.sep+config["merge"], "{sample_merged}.bam.bai"),        
    log:
        os.path.join(config["analysis_name"], "logs/07_merge/02_samtools_index/{sample_merged}.txt"),
    params:
        config_name=config["analysis_name"],
        extra=config["samtools_index_extra"], 
    threads: 4
    wrapper:
        "v1.3.2/bio/samtools/index"       
        
        
rule bam_coverage:
    input:
        bam=os.path.join(config["analysis_name"]+os.sep+config["merge"], "{sample_merged}.bam"),
        index=os.path.join(config["analysis_name"]+os.sep+config["merge"], "{sample_merged}.bam.bai"),      
    output:
        os.path.join(config["analysis_name"]+os.sep+config["bam_coverage"], "{sample_merged}.bw"),
    params:
        config_name=config["analysis_name"],
        extra1=config["bam_coverage_params1"],
        extra2=config["bam_coverage_params2"], 
        end=config["single_paired_end"],
    log:
        os.path.join(config["analysis_name"], "logs/08_bam_coverage/{sample_merged}.txt"),
    shell:
        """
            if [ {params.end} == "paired" ]
            then
                bamCoverage -b {input.bam} -o {output} {params.extra1} {params.extra2}
            else
                bamCoverage -b {input.bam} -o {output} {params.extra1}
            fi
        """
        
        
rule peak_lanceotron:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["bam_coverage"], "{sample_merged}.bw")
    output:
        os.path.join(config["analysis_name"]+os.sep+config["peaks_log"], "{sample_merged}.txt"),
    params:
        config_name=config["analysis_name"],
        folder=config["analysis_name"]+os.sep+config["peaks"],
        bam_coverage=config["bam_coverage_params1"],
    shell:
        """
            if [ "{params.bam_coverage}" == "-bs 1 --normalizeUsing RPKM" ]
            then
                lanceotron callPeaks {input} -f {params.folder}
                echo {wildcards.sample_merged} peak calling DONE! >> {output}
            else
                echo lanceotron peak calling, skipped because -bs 1 --normalizeUsing RPKM are different from default settings >> {output}
            fi
        """  
