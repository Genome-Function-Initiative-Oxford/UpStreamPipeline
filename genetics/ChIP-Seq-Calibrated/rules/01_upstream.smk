samples_r=pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"fastqfile_home_dir.txt", header=None)[0]
if config["single_paired_end"]=="paired":
    samples_r = [re.sub("_R\d+.fastq.gz", "", sr) for sr in list(samples_r)]
else:
    samples_r = [re.sub(".fastq.gz", "", sr) for sr in list(samples_r)]

origin_fastq_raw=pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"fastqfile_home_dir.txt", header=None)[0]
origin_fastq    =[of.split(".fastq.gz")[0] for of in list(origin_fastq_raw)]

ext_bowtie2=["_R1.fastq.gz", "_R2.fastq.gz"]
    
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
        cut_bool=config["cutadapters_bool"],
        end=config["single_paired_end"],
        in_fastq=os.path.join(config["analysis_name"]+os.sep+config["reads"], "{sample}"),
        info_trim_file=config["analysis_name"]+os.sep+config["trimming_qc"]+os.sep+"Untrimmed.txt",
        onfig_name=config["analysis_name"],
        out_fastq=os.path.join(config["analysis_name"]+os.sep+config["trimming"], "{sample}"),
        out_folder=config["analysis_name"]+os.sep+config["trimming"],
        threads=4,
        trimming_PE_extra=config["trimming_PE_extra"],
        trimming_SE_extra=config["trimming_SE_extra"],
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

        os.path.join(config["analysis_name"]+os.sep+config["trimming_qc"], "{sample}_qc.txt"),

rule bowtie2:
    input:
    output:
        os.path.join(config["analysis_name"]+os.sep+config["bowtie2"], "{sample}.bam"),
    params:
        config_name=config["analysis_name"],
        sample_p=expand(os.path.join(config["analysis_name"]+os.sep+config["trimming"], "{samples}"), samples=["{sample}%s"%extB for extB in ext_bowtie2]),
        sample_s=expand(os.path.join(config["analysis_name"]+os.sep+config["trimming"], "{samples}"), samples=["{sample}.fastq.gz"]),
        idx=config["bowtie2_dir"],
        out_folder=config["bowtie2"],
        threads="4",
        end=config["single_paired_end"],
        extra=config["bowtie2_extra"],
        samtools_extra=config["samtools_filtering_extra"],
    log:
        os.path.join(config["analysis_name"], "logs/03_bowtie2/{sample}.txt"),
    shell:
        """
            mkdir -p {params.config_name}/{params.out_folder}
            if [ {params.end} == "paired" ]
            then
                (bowtie2 --threads {params.threads} -1 {params.sample_p[0]} -2 {params.sample_p[1]} -x {params.idx} {params.extra} | grep -v XS: - | samtools view {params.samtools_extra} -o {output} --output-fmt BAM -) > {log}
            else
                (bowtie2 --threads {params.threads} -U {params.sample_s} -x {params.idx} {params.extra} | grep -v XS: - | samtools view {params.samtools_extra} -o {output} --output-fmt BAM -) > {log}
            fi
            
        """


rule samtools_sort:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["bowtie2"], "{sample}.bam"),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["sorted"], "{sample}_sorted.bam"),
    log:
        os.path.join(config["analysis_name"], "logs/04_samtools_sort/{sample}.txt"),
    params:
        config_name=config["analysis_name"],
        extra=config["samtools_sort_extra"],
    threads: 8
    wrapper:
        "v1.3.2/bio/samtools/sort"


rule mark_duplicates:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["sorted"], "{sample}_sorted.bam"),
    output:
        bam=os.path.join(config["analysis_name"]+os.sep+config["duplicates"], "{sample}_sorted_dedup.bam"),
        metrics=os.path.join(config["analysis_name"]+os.sep+config["duplicates_qc"], "{sample}_sorted_metrics.txt"),
    log:
        os.path.join(config["analysis_name"], "logs/05_mark_duplicates/{sample}.txt"),
    params:
        config_name=config["analysis_name"],
        extra=config["mark_duplicates_extra"],
    resources:
        mem_mb=1024,
    wrapper:
        "v1.3.2/bio/picard/markduplicates"      


rule split_genome:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["duplicates"], "{sample}_sorted_dedup.bam"),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["splitgenome"], "{sample}_sorted_dedup.bam"),
    params:
        config_name=config["analysis_name"],
        g=config["genome"],
        s=config["spikein"],
        bg=os.path.join(config["analysis_name"]+os.sep+config["splitgenome"], "{sample}_sorted_dedup_%s.bam"%config["genome"]),
        bs=os.path.join(config["analysis_name"]+os.sep+config["splitgenome"], "{sample}_sorted_dedup_%s.bam"%config["spikein"]),
    log:
        os.path.join(config["analysis_name"], "logs/06_split_genome/{sample}.log"),
    shell:
        """
            cp {input} {output}
            samtools view -h {input} | grep -v {params.s} | sed s/{params.g}\_chr/chr/g | samtools view -bhS - > {params.bg}
            samtools view -h {input} | grep -v {params.g} | sed s/{params.s}\_chr/chr/g | samtools view -bhS - > {params.bs}
        """        


rule read_counts:
    input:
        b1=os.path.join(config["analysis_name"]+os.sep+config["splitgenome"], "{sample}_sorted_dedup.bam"),
    output:
        rc=os.path.join(config["analysis_name"]+os.sep+config["readcounts"], "{sample}_readCounts.txt"),
    params:
        config_name=config["analysis_name"],
        b2=os.path.join(config["analysis_name"]+os.sep+config["splitgenome"], "{sample}_sorted_dedup_%s.bam"%config["genome"]),
        b3=os.path.join(config["analysis_name"]+os.sep+config["splitgenome"], "{sample}_sorted_dedup_%s.bam"%config["spikein"]),
    log:
        os.path.join(config["analysis_name"], "logs/07_read_counts/{sample}.log"),
    shell:
        """
            echo {wildcards.sample} $(samtools view -c -t 56 {input.b1}) $(samtools view -c -t 56 {params.b2}) $(samtools view -c -t 56 {params.b3}) >> {output.rc}
        """


rule downsampling_factor:
    input: 
        expand(os.path.join(config["analysis_name"]+os.sep+config["readcounts"], "{sample}_readCounts.txt"), sample=list(samples_r)),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["downsampling_factor_log"], "downsamplingCalculations.txt"),
    params:
        config_name=config["analysis_name"],
        input_provided=config["input_provided"],
    shell:
        """
            python scripts/downSampling_calc.py {params.config_name} {params.input_provided}
            echo down-sampling calculation DONE! >> {output}
        """


rule downsampling:
    input:
        ds=os.path.join(config["analysis_name"]+os.sep+config["downsampling_factor_log"], "downsamplingCalculations.txt"),
        rc=os.path.join(config["analysis_name"]+os.sep+config["readcounts"], "{sample}_readCounts.txt"),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["downsampling_log"], "{sample}_sorted_dedup_downsampled.txt"),
    params:
        config_name=config["analysis_name"],
        input_provided=config["input_provided"],
        i1=os.path.join(config["analysis_name"]+os.sep+config["splitgenome"], "{sample}_sorted_dedup_%s.bam"%config["genome"]),
        i2=os.path.join(config["analysis_name"]+os.sep+config["splitgenome"], "{sample}_sorted_dedup_%s.bam"%config["spikein"]),
        o1=os.path.join(config["analysis_name"]+os.sep+config["downsampling"], "{sample}_sorted_dedup_downsampled_%s.bam"%config["genome"]),
        o2=os.path.join(config["analysis_name"]+os.sep+config["downsampling"], "{sample}_sorted_dedup_downsampled_%s.bam"%config["spikein"]),
        t2=os.path.join(config["analysis_name"]+os.sep+config["downsampling"], "{sample}_%s_read_count_after_downsampling.txt"%config["spikein"]),
        ds=os.path.join(config["analysis_name"]+os.sep+config["downsampling_factor"], "downsamplingCalculations.txt"),
    shell:
        """
            DOWNSAMPLING_FACTOR="`grep {wildcards.sample} {params.ds} | cut -f 10 -`"
            
            mkdir -p {params.config_name}/results/09_downsampling
            
            sambamba view -h -t 56 -f bam --subsampling-seed=123 -s $DOWNSAMPLING_FACTOR {params.i1} -o {params.o1}
            sambamba view -h -t 56 -f bam --subsampling-seed=123 -s $DOWNSAMPLING_FACTOR {params.i2} -o {params.o2} 
            
            DOWNSAMP_COUNT="`sambamba view -c -t 56 {params.o2}`"
            echo $DOWNSAMP_COUNT
            echo Read count after downsampling is: $DOWNSAMP_COUNT >> {params.t2}
            
            echo down-sampling DONE! >> {output}
        """


rule bam_coverage:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["downsampling_log"], "{sample}_sorted_dedup_downsampled.txt"),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["bam_coverage_log"], "{sample}_downsampled.txt"),
    params:
        config_name=config["analysis_name"],
        i1=os.path.join(config["analysis_name"]+os.sep+config["downsampling"], "{sample}_sorted_dedup_downsampled_%s.bam"%config["genome"]),
        i2=os.path.join(config["analysis_name"]+os.sep+config["downsampling"], "{sample}_sorted_dedup_downsampled_%s.bam"%config["spikein"]),
        o1=os.path.join(config["analysis_name"]+os.sep+config["bam_coverage"], "{sample}_sorted_dedup_downsampled_%s.bw"%config["genome"]),
        o2=os.path.join(config["analysis_name"]+os.sep+config["bam_coverage"], "{sample}_sorted_dedup_downsampled_%s.bw"%config["spikein"]),
        extra1=config["bam_coverage_params1"],
        extra2=config["bam_coverage_params2"],
        end=config["single_paired_end"],
    shell:
        """
            mkdir -p {params.config_name}/results/10_bam_coverages
            
            if [ {params.end} == "paired" ]
            then
                bamCoverage -b {params.i1} -o {params.o1} {params.extra1} {params.extra2}
                bamCoverage -b {params.i2} -o {params.o2} {params.extra1} {params.extra2}
            else
                bamCoverage -b {params.i1} -o {params.o1} {params.extra1}
                bamCoverage -b {params.i2} -o {params.o2} {params.extra1}
            fi
            
            echo {wildcards.sample} bam_coverage DONE! >> {output}
        """


rule peak_lanceotron:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["bam_coverage_log"], "{sample}_downsampled.txt"),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["peaks_log"], "{sample}_downsampled.txt"),
    params:
        config_name=config["analysis_name"],
        b1=os.path.join(config["analysis_name"]+os.sep+config["bam_coverage"], "{sample}_sorted_dedup_downsampled_%s.bw"%config["genome"]),
        b2=os.path.join(config["analysis_name"]+os.sep+config["bam_coverage"], "{sample}_sorted_dedup_downsampled_%s.bw"%config["spikein"]),
        folder=os.path.join(config["analysis_name"]+os.sep+config["peaks"]),
        bam_coverage=config["bam_coverage_params1"],
    shell:
        """
            if [ "{params.bam_coverage}" == "-bs 1 --normalizeUsing RPKM"  ]
            then
                lanceotron callPeaks {params.b1} -f {params.folder}
                lanceotron callPeaks {params.b2} -f {params.folder}
                echo {wildcards.sample} peak calling DONE! >> {output}
            else
                echo lanceotron peak calling, skipped because -bs 1 --normalizeUsing RPKM are different from default settings >> {output}
            fi
        """  

