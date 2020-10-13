# NOTE: do i need to have this rule when it's basically identical to generate_ic.smk?
# create initial conditions with music
rule music_ic:
    input: 
        music_dir = 'path/to/music/dir'
        music_par='path/to/music/centered/config'
        music='path/to/music/executable'

    output:
        music_ic = 'path/to/music/results'

    run:
        # feed in random seed values to par file 
        # feed in new coordinates from halo finding

        # run music
        shell('cd {input.music_dir}; ./{input.music} {input.music_par}')

        # move initial conditions to enzo working
        # is this necessary? can enzo just be pointed to the music IC directory?