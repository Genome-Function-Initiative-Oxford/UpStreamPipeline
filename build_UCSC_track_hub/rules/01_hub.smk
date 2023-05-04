rule create_track_hub:
    output:
        os.path.join(config["analysis_name"]+os.sep+config['folder_out'], 'directory.txt'),
    params:
        config_name=config["analysis_name"],

        genome=config["genome"],
        pd=config["pub_directory"],
        tpd=config["tag_pub_directory"],
        url="http://genome.ucsc.edu/goldenPath/help/examples/hubDirectory",
        
        bigDataUrl="https://datashare.molbiol.ox.ac.uk/public",
        pub_url=config["pub_directory"].replace("/datashare/", ""),
        
    shell:
        """
            mkdir -p {params.pd}/{params.tpd}/{params.genome}
            
            (cd {params.pd}/{params.tpd}/ && curl -O {params.url}/hub.txt)            
            echo -e "genome {params.genome}\ntrackDb {params.genome}/trackDb.txt" >> {params.pd}/{params.tpd}/genomes.txt
            (cd {params.pd}/{params.tpd}/{params.genome}/ && curl -O {params.url}/hg19/trackDb.txt)
            
            echo -e "copy and paste the follwing url to create the hub in UCSC:\n\n{params.bigDataUrl}/{params.pub_url}/{params.tpd}/hub.txt" >> results/UCSC_url.txt
            echo UCSC track hub created in public folder {params.pd}/{params.tpd} >> {output}
        """
