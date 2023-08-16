sample_names = glob.glob(config["origin_fastq_folder"]+os.sep+"*")
sample_names = [s.split("/")[-1] for s in sample_names]

rule pre_processing_plot:
    input:
        config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"logs/HiC-Pro_step2.log",
    output:
        config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"plots/{sample}_HiCPlotter-py3.sh",
    params:
        path_to_hic_results_dir = config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep,
        path_to_plotting_dir = config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"plots",
        region = config["region"],
        sample_name = "{sample}",
        resolution = config["resolution_hp"],
        lowerPercentile = config["lowerPercentile"],
        upperPercentile = config["upperPercentile"],
    shell:
        """
            mkdir -p {params.path_to_plotting_dir}

            python script/pre_process_for_plotting.py \
                {params.region} \
                {params.sample_name} \
                {params.path_to_hic_results_dir} \
                {params.path_to_plotting_dir} \
                {params.resolution} \
                {params.lowerPercentile} \
                {params.upperPercentile} \
                {output}

        """


rule plot_heatmap:
    input:
        config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"plots/{sample}_HiCPlotter-py3.sh",
    output:
        config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"logs/{sample}_heatmap.log",
    params:
        path = config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"plots",
        script = "{sample}_HiCPlotter-py3.sh"
    shell:
        """
            cd {params.path}
            sh {params.script}
            cd ../../../
            echo Plotting DONE! >> {output}
        """


rule plot_virtual_capture:
    input:
        expand(config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"plots/{samp}_HiCPlotter-py3.sh", samp=sample_names),
    output:
        config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"logs/virtual_capture.log",
    params:
        view_point=config["view_point"],
        resolution_vc=config["resolution_vc"],
        plotWindow=config["plotWindow"],
        matrices=config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"hic_results/matrix",
        path = config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"plots",
        condition = config["condition"],
    shell:
        """
            python script/virtual_capture.py \
                {params.view_point} \
                {params.resolution_vc} \
                {params.plotWindow} \
                {params.matrices} \
                {params.path} \
                {params.condition}
            echo Plotting DONE! >> {output}
        """
