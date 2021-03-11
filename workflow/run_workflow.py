import yt
import yt.analysis_modules.halo_analysis.api as haa
import yaml
import subprocess
import numpy as np


def find_halos(enzo_results,halo_coords):
    ds = yt.load('%s/RD0001/RedshiftOutput0001' %enzo_results)
    hc = haa.HaloCatalog(data_ds = ds, finder_method='fof',
                         output_dir='%s/RD0001/halo_catalogs/catalog' %enzo_results)
    hc.create()
    hc.load()
    ind = np.argmax(hc.halos_ds.r[:]["particle_mass"])
    coords = [float(_.in_units("unitary")) for _ in hc.halos_ds.r[:]["particle_position"][ind,:]]
    yaml.dump(coords, open(halo_coords, "w"))

    print('Found halos.')
    refine = True
    return(coords)

def generate_ic(seed_idx,music_dir,enzo_dir,
                music_ex,refine,seed=None,crds=None):
    with open(seed, "r") as f:
        seed_val = f.readline()
        f.close()
    seed_dict = {'seed': seed_val, 'seed_id': 'SEED%s' %seed_idx}
    print(seed_dict)

    if refine == False:
        music_par = '%s/ics_template.conf' %music_dir
        music_ic = '%s/SEED%s' %(music_dir,seed_idx)

        with open(music_par, "r") as f:
            contents = f.read()
            f.close()
        
        with open('%s/output_ics.conf' %music_dir, "a+") as f:
            f.write(contents.format(**seed_dict))
            f.close()


        process = subprocess.Popen('./MUSIC output_ics.conf', cwd=music_dir, shell=True)
        process.wait()
        print('Generated first set of IC')

        open('%s/output_ics.conf' %music_dir, 'w').close()
        
    else:
        center_dict = {'center_1': crds[0], 'center_2': crds[1], 'center_3':  crds[2]}
        center_dict.update(seed_dict)
        
        music_par = '%s/ics_centered_template.conf' %music_dir
        music_ic = '%s/SEED%s_initial_centered' %(music_dir,seed_idx)

        with open(music_par, "r") as f:
            contents = f.read()
            f.close()
        
        with open('%s/output_ics_centered_%s.conf' %(music_dir,seed_idx), "a+") as f:
            f.write(contents.format(**center_dict))
            f.close()

#        process = subprocess.Popen('./MUSIC output_ics_centered.conf', cwd=music_dir, shell=True)
#        process.wait()
#        print('Refined IC')
        
#        open('%s/output_ics_centered.conf' %music_dir, 'w').close()

def enzo_run(enzo_dir,refine):
    p1 = subprocess.Popen('mpirun -n 16 ./enzo.exe -d parameter_file.txt>& log_file', 
                                cwd=enzo_dir, shell=True)
    p1.wait()

    if refine == False:
        print('Completed first enzo run.')
    else:
        print('Completed refining enzo run.')

# def analyze(): TODO

seed_ids = ["%.1d" % i for i in range(1,11)]

workdir = '/dpool/cwagner4/working'
enzo_dir = '%s/enzo_sims' %workdir
enzo_par = '%s/parameter_file.txt' %enzo_dir
enzo_ex = '%s/enzo.exe' %enzo_dir
enzo_par_templ = '%s/parameter_file_template.txt' %enzo_dir
music_dir = '%s/music' %workdir
music_ex = '%s/MUSIC' %music_dir

#for seed_idx in seed_ids:

#    refine = False

#    enzo_results = '%s/output/seeds/SEED%s' %(enzo_dir, seed_idx)
#    halo_coords = '%s/halo_finding/coords.v' %enzo_results
#    seed = '../resources/SEED%s' %seed_idx 

#    generate_ic(seed=seed,music_dir=music_dir,
#                seed_idx=seed_idx,enzo_dir=enzo_dir,
#                music_ex=music_ex)
#    enzo_run(enzo_dir=enzo_dir,enzo_ex=enzo_ex,
#             enzo_par=enzo_par,enzo_results=enzo_results)
#    halo_crds = find_halos(enzo_results=enzo_results,halo_coords=halo_coords)
#    generate_ic(seed=seed,crds=halo_crds,
#                music_dir=music_dir,seed_idx=seed_idx,
#                enzo_dir=enzo_dir,music_ex=music_ex)
#    enzo_run(enzo_dir=enzo_dir,enzo_ex=enzo_ex,
#             enzo_par=enzo_par,enzo_results=enzo_results)
