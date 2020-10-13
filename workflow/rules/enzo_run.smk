rule final_enzo:
    input:
        music_ic = 'path/to/music/initial/conditions' # or do i have to move them all to where the enzo script lives?
        enzo_dir = '/path/to/enzo/directory'
        par_file = 'path/to/enzo/par/file'
        enzo_ex = '/path/to/enzo/executable'
    
    output: 
        output_dir = '/path/to/enzo/data/directory' # is this what makes sense?
    
    run: 
        shell('cd {input.enzo_dir}; mpirun -n 16 ./{input.enzo_ex} -d {input.par_file}>& log_file') 

        # move everything to output_dir

rule email: 
#TODO make a rule to send me a notification when the long enzo run wraps up