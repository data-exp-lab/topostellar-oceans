import os
import sys
import numpy as np 
import glob

sys.path.insert(0, 'enzo_sims')
sys.path.insert(0, 'music')
import panel_plots

# set random seeds
rand_list = np.random.randint(10000, 99999, size=6)

# set JLs
jl_list = [4, 8, 16, 32, 64, 128]

def create_templates(parameters, dest_path):
    for fn in glob.glob("initialize/*.template"):
        contents = open(fn, "r").read()
        if not os.path.isdir(dest_path):
            os.makedirs(dest_path)
        dest_fn = os.path.join(dest_path, os.path.basename(fn.rsplit(".", 1)[0]))
        with open(dest_fn, "w") as f:
            f.write(contents.format(**parameters))
        dest_ic = os.path.join(dest_path, "UM_IC")
        src_ic = os.path.abspath("./UM_IC")
        if os.path.exists(dest_ic):
            os.unlink(dest_ic)
        os.symlink(src_ic, dest_ic)


# create initial conditions with music
rule music_first:
    input: 
        music_par='music/ics_template.conf'
        music='music/MUSIC'
    run:
        # feed in random seed values to par file 

        # run music
        shell('cd music; ./{input.music} {input.music_par}')

        # move initial conditions to enzo working

# first pass enzo run
rule enzo_first:
    input:
        enzo_par='enzo_sims/parameter.txt'
        enzo='enzo_sims/enzo.exe'
        email='enzo_sims/email.txt'
    run:
        shell('cd enzo_sims; mpirun -n 16 ./{input.enzo} -d {input.enzo_par}>& log_file; sendmail cwagner4@illinois.edu < {input.email}') 

# find halos
rule halos:
    input: 
        # input all the music data files

# run music again centered on halos
rule music_second:
    input:
        music_par='music/ics_example.conf'
        music='music/MUSIC'
    run:
        # feed in new coordinates
        
        # run music
        shell('cd music; ./{input.music} {input.music_par}')

        # move initial conditions to enzo working

# run enzo again centered on halos TODO: can i just call this rule again instead
rule enzo_second:
    input:
        enzo_par='enzo_sims/parameter.txt'
        enzo='enzo_sims/enzo.exe'
        email='enzo_sims/email.txt'
    run:
        shell('cd enzo_sims; mpirun -n 16 ./{input.enzo} -d {input.enzo_par}>& log_file; sendmail cwagner4@illinois.edu < {input.email}')

# make plots
rule plot:
    input:
        # input specific snapshots based on some cutoff to compare all JLs and seeds
    run:
        # run function for making panel plot

        
# run templating function to create template files
rule template:
    run:
        for amp in driving_amps:
            dest_path = os.path.join("initialize", "templates",
                "driven_amp{:05}".format(amp) )
            create_templates( {'driven_amp': float(amp)}, dest_path = dest_path)

# cd to appropriate directory and run gamer based on all template files
rule gamer:
    input: 
        directories=("initialize/templates/driven_amp{:05}".format(amp) for amp in driving_amps[11:]),
        gamer='gamer/src/gamer'
    run:
        for dir in input.directories:
            shell('cd {dir}; ./../../../{input.gamer}')

# make diagnostic plots
rule plots:
    input:
        directories=("initialize/templates/driven_amp{:05}".format(amp) for amp in driving_amps[4:]),
    run:
        for dir in input.directories:
            print("Working in "+str(dir))
            try:
                print("Making phase plots for the Mach number.")
                post_processing.mach_number(path=dir, idx_start=1, idx_end=100, didx=1)

            except OSError:
                print("Out of data, moving to next sim.")
                pass
            
            for i in fields:
                for j in ['x','y','z']:
                    try:
                        print("Making slice plots for "+str(i)+" along the "+str(j)+" axis.")
                        post_processing.slice_plot(path=dir, field = i, axis = j, 
                                                   idx_start=1, idx_end=100, didx=1) 
                    except OSError:
                        print("Out of data, moving to next sim.")
                        pass 
        print("Finished making all plots.") 

# make gifs from plots
rule gifs:
    input:
        directories=("initialize/templates/driven_amp{:05}".format(amp) for amp in driving_amps),
	home="/dpool/cwagner4/working/gamer_sims/turbulence"
    output:
        mach="2d-Profile_density_mach_number_cell_mass.gif",
        densx="Slice_x_density.gif",
        densy="Slice_y_density.gif",
        densz="Slice_z_density.gif",
        vmagx="Slice_x_velocity_magnitude.gif",
        vmagy="Slice_y_velocity_magnitude.gif",
        vmagz="Slice_z_velocity_magnitude.gif"
    run:
        for dir in input.directories:
            for name in filenames:
                print("Making "+str(name)+".gif")
                shell('cd {dir}/images; pwd; convert -delay 15 -loop 0 *{name}.png {name}.gif; mv *.gif gifs; cd {input.home}')
