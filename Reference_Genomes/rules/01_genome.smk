rule custom_genome:
    output:
        os.path.join(config["analysis_name"]+os.sep+config['folder_out'], 'genome.txt'),
    params:
        config_name=config["analysis_name"],
        
        folder_out = config["analysis_name"]+os.sep+config["folder_out"],
        
        genome = config["genome"],
        method = config["method"],
        public_url = "https://hgdownload.soe.ucsc.edu/goldenPath/",

        move_output_files=config["move_output_files"],
        out_dir=config["output_dir"],
        out_dir_tag=config["tag_output_dir"],
    log:
        os.path.join(config["analysis_name"], "logs/genome.log"),
    shell:
        """         
            wget -P {params.folder_out} {params.public_url}{params.genome}/bigZips/{params.genome}.fa.gz
            wget -P {params.folder_out} {params.public_url}{params.genome}/bigZips/{params.genome}.chrom.sizes
            if [ {params.method} == "bwa-mem2" ]
            then
                wget -P {params.folder_out} https://hgdownload.cse.ucsc.edu/goldenpath/{params.genome}/database/refGene.txt.gz
                gunzip -f {params.folder_out}refGene.txt.gz
                bwa-mem2 index {params.folder_out}{params.genome}.fa.gz
            fi   
            if [ {params.method} == "bowtie" ]
            then
                wget -P {params.folder_out} https://hgdownload.cse.ucsc.edu/goldenpath/{params.genome}/database/refGene.txt.gz
                gunzip -f {params.folder_out}refGene.txt.gz
                gunzip -f {params.folder_out}{params.genome}.fa.gz
                bowtie-build {params.folder_out}{params.genome}.fa {params.folder_out}/{params.genome}
            fi
            if [ {params.method} == "bowtie2" ]
            then
                wget -P {params.folder_out} https://hgdownload.cse.ucsc.edu/goldenpath/{params.genome}/database/refGene.txt.gz
                gunzip -f {params.folder_out}refGene.txt.gz
                gunzip -f {params.folder_out}{params.genome}.fa.gz
                mkdir -p {params.folder_out}{params.genome}.bowtie2.index/
                bowtie2-build {params.folder_out}{params.genome}.fa {params.folder_out}{params.genome}.bowtie2.index/{params.genome}
            fi
            if [ {params.method} == "star" ]
            then
                gunzip -f {params.folder_out}{params.genome}.fa.gz
                if [ {params.genome} == "hg38" ]
                then
                    wget -P {params.folder_out} https://ftp.ensembl.org/pub/release-111/gtf/homo_sapiens/Homo_sapiens.GRCh38.111.gtf.gz
                    gunzip -f {params.folder_out}/Homo_sapiens.GRCh38.111.gtf.gz
                    STAR --runMode genomeGenerate --genomeDir {params.folder_out} --genomeFastaFiles {params.folder_out}{params.genome}.fa --outTmpDir {params.folder_out}_STARtmp
                elif [ {params.genome} == "hg19" ]
                then
                    echo "to be implemented"
                elif [ {params.genome} == "mm9" ]
                then
                    echo "to be implemented"
                elif [ {params.genome} == "mm10" ]
                then
                    echo "to be implemented"
                elif [ {params.genome} == "mm39" ]
                then
                    echo "to be implemented"
                fi
            fi
            if [ {params.move_output_files} == "True" ]
            then
                mkdir -p {params.out_dir}/{params.out_dir_tag}
                mv {params.config_name} {params.out_dir}/{params.out_dir_tag}/
                cp config/{params.config_name}.yaml {params.out_dir}/{params.out_dir_tag}/
            fi   
            mkdir -p {params.folder_out}
            echo {params.method} for {params.genome} DONE, and if selected, results moved into {params.out_dir} >> {output}
            rm -rf logs
        """