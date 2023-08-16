rule digest_genome:
    output:
        config["analysis_name"]+os.sep+"%s_%s.bed"%(config["genome_build"], config["restriction_enzyme"])

    params:
        run_folder=config["analysis_name"],
        genome=config["genome_build"],
        genome_path=config["genome_path"],
        restriction_enzyme=config["restriction_enzyme"],
    shell:
        """
            mkdir -p {params.run_folder}
            python script/digest_genome.py -r {params.restriction_enzyme} -o {output} {params.genome_path}
        """


rule create_config:
    input:
        config["analysis_name"]+os.sep+"%s_%s.bed"%(config["genome_build"], config["restriction_enzyme"])
    output:
        config["analysis_name"]+os.sep+"config.txt"
    params:
        run_folder=config["analysis_name"],
        email=config["email"],
        bowtie_index_path=config["bowtie_index_path"],
        genome=config["genome_build"],
        genome_size_txt=config["genome_size_txt"],
        capture_target_bed=config["capture_target_bed"],
        ligation_site=config["ligation_site"],
        bin_size=config["bin_size"],
        genome_fragment=os.path.abspath(config["analysis_name"]+os.sep+"%s_%s.bed"%(config["genome_build"], config["restriction_enzyme"])),
    shell:
        """
            python script/create_config.py \
                    {output} \
                    {params.run_folder} \
                    {params.email} \
                    {params.bowtie_index_path} \
                    {params.genome} \
                    {params.genome_size_txt} \
                    {params.capture_target_bed} \
                    {params.genome_fragment} \
                    {params.ligation_site} \
                    {params.bin_size}
        """
