import yt
import yt.analysis_modules.halo_analysis.api as haa

rule initial_enzo:
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

rule halo_finding:
    input: 
        data_directory = '/path/to/enzo/data/directory'
        data = '/path/to/first/enzo/data'

    output: 
        # still confused on what the point of output files are -- should i be
        # outputting an actual file with the coordinates? 

    run: 
        ds = yt.load(data)
        hc = haa.HaloCatalog(data_ds = ds, finder_method="fof", 
                             output_dir="{input.data_directory}/RD0001/halo_catalogs/catalog")
        hc.create()
        hc.load()
        coords = [_.in_units("unitary") for _ in hc.halos_ds.r[:].argmax(("io", "particle_mass"))]

        # output coords somehow? as file? as env variable?

