rule final_enzo:
    input:
        enzo_dir = config["enzo"]["working_directory"],
        par_file = '{input.enzo_dir}/parameter_file.txt',
        enzo_ex = config["enzo"]["executable"]
    
    output: 
        output_dir = '{input.enzo_dir}/output/seeds/SEED{sample}'
    
    run: 
        shell('cd {input.enzo_dir}; mpirun -n 16 ./{input.enzo_ex} -d {input.par_file}>& log_file') 
        shell('mv DD* RD* log_file Enzo_Build *.out Out* Evtime RunFinished {output.output_dir}')

#rule email: 
#TODO make a rule to send me a notification when the long enzo run wraps up