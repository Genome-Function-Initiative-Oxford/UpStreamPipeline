samples_r = pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"samples.csv", index_col="sample", sep="\t")

genomeV = config['genome_built_version']

rule fastq_fastqc:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["reads"], "{sample_or}.fastq.gz"),
    output:
        html=os.path.join(config["analysis_name"]+os.sep+config["reads_qc"], "{sample_or}.html"),
        zip=os.path.join(config["analysis_name"]+os.sep+config["reads_qc"], "{sample_or}_fastqc.zip"),
    params: "--quiet"
    log:
        os.path.join(config["analysis_name"], "logs/01_move_fastq/{sample_or}_fastqc.txt"),
    threads: 1
    wrapper:
        "v1.3.2/bio/fastqc"


rule trimming_fastqc:
    input:
        expand(os.path.join(config["analysis_name"]+os.sep+config["trimming_qc"], "{samp}_qc.txt"), samp=list(samples_r.index)),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["trimming_qc"], "{sample_or}_fastqc.txt"),
    params:
        input_fastq=os.path.join(config["analysis_name"]+os.sep+config["trimming"], "{sample_or}.fastq.gz"),
        input_fastq_orphan=os.path.join(config["analysis_name"]+os.sep+config["trimming"], "{sample_or}_orphan.fastq.gz"),
        thread="1",
        folder=os.path.join(config["analysis_name"]+os.sep+config["trimming_qc"]),
    log:
        os.path.join(config["analysis_name"], "logs/02_trimming/{sample_or}_fastqc.txt"),
    shell:
        """
            mkdir -p {params.tmp}

            fastqc --quiet --noextract --threads {params.thread} --outdir {params.folder} {params.input_fastq}

            fastqc --quiet --noextract --threads {params.thread} --outdir {params.folder} {params.input_fastq_orphan}
            
            echo trimming_fastqc Done! >> {output}
        """


rule aligner_stats:
    input:
        bam=os.path.join(config["analysis_name"]+os.sep+config["aligner"], "{sample}_%s.bam"%genomeV),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["aligner_qc"], "{sample}_%s_stats.txt"%genomeV),
    params:
        extra="",
    log:
        os.path.join(config["analysis_name"], "logs/03_aligner/{sample}_%s_stats.txt"%genomeV),
    wrapper:
        "v1.3.2/bio/samtools/stats"

        
rule aligner_multiqc:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["aligner_qc"], "{sample}_%s_stats.txt"%genomeV),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["aligner_qc"], "{sample}_%s_multiqc.html"%genomeV),
    params:
        extra="",
    log:
        os.path.join(config["analysis_name"], "logs/03_aligner/{sample}_%s_multiqc.txt"%genomeV),
    wrapper:
        "v1.3.2/bio/multiqc"
        
        
rule sorted_dedup_stats:
    input:
        bam=os.path.join(config["analysis_name"]+os.sep+config["duplicates"], "{sample}_%s.bam"%genomeV),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["duplicates_qc"], "{sample}_%s_stats.txt"%genomeV),
    params:
        extra="",
    log:
        os.path.join(config["analysis_name"], "logs/06_duplicates/{sample}_%s_stats.txt"%genomeV),
    wrapper:
        "v1.3.2/bio/samtools/stats"

        
rule sorted_dedup_multiqc:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["duplicates_qc"], "{sample}_%s_stats.txt"%genomeV),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["duplicates_qc"], "{sample}_%s_multiqc.html"%genomeV),
    params:
        extra="",
    log:
        os.path.join(config["analysis_name"], "logs/06_duplicates/{sample}_%s_multiqc.txt"%genomeV),
    wrapper:
        "v1.3.2/bio/multiqc"


rule merge_stats:
    input:
        bam=os.path.join(config["analysis_name"]+os.sep+config["merge"], "{sample_merged}_%s.bam"%genomeV),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["merge_qc"], "{sample_merged}_%s_stats.txt"%genomeV),
    params:
        extra="",
    log:
        os.path.join(config["analysis_name"], "logs/07_merge/{sample_merged}_%s_stats.txt"%genomeV),
    wrapper:
        "v1.3.2/bio/samtools/stats"

        
rule merge_multiqc:
    input:
        os.path.join(config["analysis_name"]+os.sep+config["merge_qc"], "{sample_merged}_%s_stats.txt"%genomeV),
    output:
        os.path.join(config["analysis_name"]+os.sep+config["merge_qc"], "{sample_merged}_%s_multiqc.html"%genomeV),
    params:
        extra="",
    log:
        os.path.join(config["analysis_name"], "logs/07_merge/{sample_merged}_%s_multiqc.txt"%genomeV),
    wrapper:
        "v1.3.2/bio/multiqc"