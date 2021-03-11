# create initial conditions with music
rule music_ic:
    input: 
        seed = 'resources/SEED{sample}',
        music_dir = config["music"]["working_directory"],
        music_par = '{input.music_dir}/ics_template.conf',
        music = config["music"]["executable"],
        enzo_dir = config["enzo"]["working_directory"]

    output:
        music_ic = '{input.music_dir}/SEED{sample}',
        output_par = '{input.music_dir}/SEED{sample}/parameter_file.txt'

    run:
        with open({input.seed}, "r") as f:
            seed_val = f.readline()
            f.close()

        seed_dict = {seed: seed_val, seed_id: 'SEED{sample}'}
        
        with open({input.music_par}, "w") as f:
            f.write(contents.format(seed_dict))
            f.close()

        # run music
        shell('cd {input.music_dir}; ./{input.music} {input.music_par}')

        print('Generated first set of IC')

        # move IC to enzo working directory
        shell('mv {output.music_ic} {input.enzo_dir}')