rule hicpro_step1:
    input:
        config["analysis_name"]+os.sep+"config.txt"
    output:
        config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"logs/HiC-Pro_step1.log",
    params:
        origin_fastq_folder=config["origin_fastq_folder"],
        run_folder=config["analysis_name"],
        run_folder_tag=config["analysis_name"]+os.sep+config["hic_pro_output_tag"],
        config_system_file="script/HiC-Pro_3.1.0/config-system.txt",
        conda_env_path=config["conda_env_path"],
        hicpro_github_path=os.path.abspath("script/HiC-Pro_3.1.0"),
    shell:
        """
            mkdir -p {params.run_folder_tag}

            if [[ -d {params.run_folder_tag}/rawdata ]]
            then
                echo "Symbolic Links already created!"
            else
                ln -sf {params.origin_fastq_folder} {params.run_folder_tag}/rawdata
            fi

            python script/edit_config-system.py {params.config_system_file} {params.conda_env_path} {params.hicpro_github_path}

            cd {params.run_folder_tag}
            make --file ../../script/HiC-Pro_3.1.0/scripts/Makefile CONFIG_FILE=../../{input} CONFIG_SYS=../../script/HiC-Pro_3.1.0/config-system.txt all_sub 2>&1
            cd ../../
            echo HiC-Pro step1 Done! >> {output}
        """


rule hicpro_step2:
    input:
        config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"logs/HiC-Pro_step1.log",
    output:
        config["analysis_name"]+os.sep+config["hic_pro_output_tag"]+os.sep+"logs/HiC-Pro_step2.log",
    params:
        run_folder_tag=config["analysis_name"]+os.sep+config["hic_pro_output_tag"],
        configuration=config["analysis_name"]+os.sep+"config.txt",
    shell:
        """
            cd {params.run_folder_tag}
            make --file ../../script/HiC-Pro_3.1.0/scripts/Makefile CONFIG_FILE=../../{params.configuration} CONFIG_SYS=../../script/HiC-Pro_3.1.0/config-system.txt all_persample 2>&1
            cd ../../
            unlink {params.run_folder_tag}/rawdata
            echo HiC-Pro step2 Done! >> {output}
        """
