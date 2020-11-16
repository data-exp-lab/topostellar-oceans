import yt
import yt.analysis_modules.halo_analysis.api as haa
import yaml

seed_ids = ["%.2d" % i for i in range(1,11)]
refine = False

workdir = '/dpool/cwagner4/working'
enzo_dir = '%s/enzo_sims' %workdir
enzo_par = '%s/parameter_file.txt' %enzo_dir
enzo_ex = '%s/enzo.exe' %enzo_dir
enzo_results = '%s/output/seeds/SEED--' %enzo_dir   #TODO
halo_coords = '%s/halo_finding/coords.v' %enzo_results
music_dir = '%s/music' %workdir
music_ex = '%s/MUSIC' %music_dir
music_ic = '%s/SEED--'      #TODO
seed = 'resources/SEED--'   #TODO 

def find_halos():
    ds = yt.load('%s/RD0001/RedshiftOutput0001' %enzo_results)
    hc = haa.HaloCatalog(data_ds = ds, finder_method='fof',
                         output_dir='%s/RD0001/halo_catalogs/catalog' %enzo_results)
    hc.create()
    hc.load()
    coords = [_.in_units("unitary") for _ in hc.halos_ds.r[:].argmax(("io", "particle_mass"))]
    yaml.dump(coords, open(halo_coords, "w"))

    refine = True

def generate_ic():

    with open(seed, "r") as f:
        seed_val = f.readline()
        f.close()
    seed_dict = {seed: seed_val, seed_id: 'SEED--'}     #TODO

    if refine == False:
       music_par = '%s/ics_template.conf' %music_dir
        with open(music_par, "w") as f:
            f.write(contents.format(seed_dict))
            f.close()
        shell('cd {music_dir}; ./{music_ex} {music_par}')
        print('Generated first set of IC')

    elif:
        with open(halo_coords, "r") as f:
            coord_val = f.readline()
            f.close()
        coord_dict = {halo_coords: coord_val, ...}  #TODO

        music_par = '%s/ics_centered_template.conf' %music_dir
        with open(music_par, "w") as f:
            f.write(contents.format(seed_dict))
            f.write(contents.format(coord_dict))
            f.close()

        shell('cd {music_dir}; ./{music_ex} {music_par}')
        print('Refined IC')

    shell('mv {music_ic} {enzo_dir}')

def enzo_run():
    shell('cd {enzo_dir}; mpirun -n 16 ./{enzo_ex} -d {enzo_par}>& log_file')
    shell('mv DD* RD* log_file Enzo_Build *.out Out* Evtime RunFinished {enzo_results}')


# def analyze(): TODO