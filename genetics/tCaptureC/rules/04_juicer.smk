rule juicer:
    input:
        config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"logs/HiC-Pro_step2.log",
    output:
        config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"logs/juicer_for_UCSC/{sample}.log",
    params:
        hicpro2juicebox="script/HiC-Pro_3.1.0/bin/utils/hicpro2juicebox.sh",
        input_sample=config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"hic_results/data/{sample}/{sample}.allValidPairs",
        chrom_size=config["genome_size_txt"],
        juicer_tool="script/juicer/juicer_tools_1.22.01.jar",
        output_folder=config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"juicer_for_UCSC",
        log_juicer=config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"logs/juicer_for_UCSC",
        path_to_plotting_dir = config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"plots",

    shell:
        """
            mkdir -p {params.log_juicer}
            mkdir -p {params.output_folder}
            {params.hicpro2juicebox} -i {params.input_sample} -g {params.chrom_size} -j {params.juicer_tool} -o {params.output_folder}
            cp {params.path_to_plotting_dir}/pre_processing_log.txt {params.output_folder}/UCSC_params.txt
            echo Juicer on {wildcards.sample} Done! >> {output}
        """