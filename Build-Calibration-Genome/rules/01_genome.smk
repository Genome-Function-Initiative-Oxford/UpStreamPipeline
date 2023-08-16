rule custom_genome:
    input:
        g1 = config['genome1']['fa'],
        g2 = config['genome2']['fa'],
    output:
        os.path.join(config["analysis_name"]+os.sep+config['custom_bowtie2_dir'], 'genome.txt'),
    params:
        config_name=config["analysis_name"],

        c1 = config['genome1']['chr'],
        c2 = config['genome2']['chr'],
        out = config["analysis_name"]+os.sep+config['custom_bowtie2_dir'],
        move_output_files=config["move_output_files"],
        out_dir=config["output_dir"],
        out_dir_tag=config["tag_output_dir"],
    log:
        os.path.join(config["analysis_name"], "logs/01_custom_genome/genome.log"),
    shell:
        """         
            sed 's/>chr/>{params.c1}/g' {input.g1} > {params.out}/genome1.fa
            sed 's/>chr/>{params.c2}/g' {input.g2} > {params.out}/genome2.fa
            
            cat {params.out}/genome1.fa {params.out}/genome2.fa > {params.out}/genome.fa

            bowtie2-build {params.out}/genome.fa {params.out}/genome
            
            rm -rf {params.out}/genome1.fa
            rm -rf {params.out}/genome2.fa
            
            if [ {params.move_output_files} == "true" ]
            then
                mkdir -p {params.out_dir}/{params.out_dir_tag}
                mv {params.config_name} {params.out_dir}/{params.out_dir_tag}/
                cp config/{params.config_name}.yaml {params.out_dir}/{params.out_dir_tag}/
            fi         
            
            echo {params.c1} and {params.c2} bowtie2-build, and if selected, results move into {params.move_output_files} >> {output}
        """