from datetime import datetime

samples_r = pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"samples.csv", index_col="sample", sep="\t")

genomeV = config['genome_built_version']

if config['merge_bams']=='True':
    try:
        samples = pd.read_csv(config["analysis_name"]+os.sep+config["single_paired_folder"]+os.sep+"3_merge_bams.txt", header=None)[0].tolist()
    except:
        print("You must provide 'merge.txt' file")
        sys.exit()
else:
    samples = list(samples_r.index)


rule cleaning_folders:
    input:
        expand(os.path.join(config["analysis_name"]+os.sep+config["bam_coverage"], "{sample_merged}_%s.bw"%genomeV), sample_merged=samples),

    output:
        os.path.join(config["analysis_name"]+os.sep+config["cleaning"], "moving.txt"),
    params:
        config_name=config["analysis_name"],
        
        move_bw_public_folder=config["move_bw_public_folder"],
        public_output_dir=config["public_output_dir"],
        tag_public_output_dir=config["tag_public_output_dir"],
        
        delete_intermediate_files=config["delete_intermediate_files"],
        move_output_files=config["move_output_files"],
        out_dir=config["output_dir"],
        out_dir_tag=config["tag_output_dir"],
        out_dir_time=datetime.now().strftime("%Y-%m-%d"),
        
        single_paired_folder_rm=config["single_paired_folder_rm"],
        single_paired_folder=config["analysis_name"]+os.sep+config["single_paired_folder"],
        
        reads_rm=config["reads_rm"],
        reads=config["analysis_name"]+os.sep+config["reads"],

        trimming_rm=config["trimming_rm"],
        trimming=config["analysis_name"]+os.sep+config["trimming"],

        star_rm=config["star_rm"],
        star=config["analysis_name"]+os.sep+config["star"],

        sorted_rm=config["sorted_rm"],
        sorted=config["analysis_name"]+os.sep+config["sorted"],

        merge_rm=config["merge_rm"],
        merge=config["analysis_name"]+os.sep+config["merge"],
        
        duplicates_rm=config["duplicates_rm"],
        duplicates=config["analysis_name"]+os.sep+config["duplicates"],

        indices_rm=config["indices_rm"],
        indices=config["analysis_name"]+os.sep+config["indices"],
        
        bam_coverage_rm=config["bam_coverage_rm"],
        bam_coverage=config["analysis_name"]+os.sep+config["bam_coverage"],
        
        feature_counts_rm=config["feature_counts_rm"],
        feature_counts=config["analysis_name"]+os.sep+config["feature_counts"],
        
        track_rm=config["track_rm"],
        track=config["analysis_name"]+os.sep+config["track"],
        
    shell:
        """
            if [ {params.move_bw_public_folder} == "True" ]
            then
                mkdir -p {params.public_output_dir}/{params.tag_public_output_dir}
                cp {params.bam_coverage}/* {params.public_output_dir}/{params.tag_public_output_dir}/
            fi
        
            if [ {params.delete_intermediate_files} == "True" ]
            then
                echo Cleaning in progress...

                if [ {params.single_paired_folder_rm} == "True"  ]
                then
                    rm -rf {params.single_paired_folder}
                fi
                if [ {params.reads_rm} == "True"  ]
                then
                    rm -rf {params.reads}
                fi
                if [ {params.trimming_rm} == "True"  ]
                then
                    rm -rf {params.trimming}
                fi
                if [ {params.star_rm} == "True"  ]
                then
                    rm -rf {params.star}
                fi
                if [ {params.sorted_rm} == "True"  ]
                then
                    rm -rf {params.sorted}
                fi
                if [ {params.merge_rm} == "True"  ]
                then
                    rm -rf {params.merge}
                fi
                if [ {params.duplicates_rm} == "True"  ]
                then
                    rm -rf {params.duplicates}
                fi 
                if [ {params.indices_rm} == "True"  ]
                then
                    rm -rf {params.indices}
                fi
                if [ {params.bam_coverage_rm} == "True"  ]
                then
                    rm -rf {params.bam_coverage}
                fi
                if [ {params.feature_counts_rm} == "True"  ]
                then
                    rm -rf {params.feature_counts}
                fi
                if [ {params.track_rm} == "True"  ]
                then
                    rm -rf {params.track}
                fi
            fi
                       
            if [ {params.move_output_files} == "True" ]
            then
                mkdir -p {params.out_dir}/{params.out_dir_time}_{params.out_dir_tag}
                mv {params.config_name}/results {params.out_dir}/{params.out_dir_time}_{params.out_dir_tag}/
                mv {params.config_name}/QCs {params.out_dir}/{params.out_dir_time}_{params.out_dir_tag}/
                mv {params.config_name}/logs {params.out_dir}/{params.out_dir_time}_{params.out_dir_tag}/
                cp config/{params.config_name}.yaml {params.out_dir}/{params.out_dir_time}_{params.out_dir_tag}/
                mkdir -p {params.config_name}/results
            fi        

            echo If selected, results move into {params.out_dir} >> {output}
            rm -rf logs
          """
        

    

    

    

    

    

    

    

    


    
