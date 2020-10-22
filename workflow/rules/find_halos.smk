import yt
import yt.analysis_modules.halo_analysis.api as haa
import yaml

rule initial_enzo:
    input:
        enzo_dir = config["enzo"]["working_directory"], 
        par_file = config["enzo"]["parameter_file"],
        enzo_ex = config["enzo"]["executable"],
        seed = '../resources/SEED{sample}'
    
    output:
        output_dir = '{input.enzo_dir}/SEED{sample}/halo_finding' #does this make sense

    run: 
        shell('cd {input.enzo_dir}; mpirun -n 16 ./{input.enzo_ex} -d {input.par_file}>& log_file') 
        shell('mv DD* RD* log_file Enzo_Build *.out Out* Evtime RunFinished {output.output_dir}')

rule halo_finding:
    input:
        data_dir = '{input.enzo_dir}/SEED{sample}/halo_finding'
    output: 
        coords_output = '{input.output_dir}/coords.yaml'

    run: 
        ds = yt.load('{input.data_dir}/RD0001/RedshiftOutput0001')
        hc = haa.HaloCatalog(data_ds = ds, finder_method="fof", 
                             output_dir="{input.data_dir}/RD0001/halo_catalogs/catalog")
        hc.create()
        hc.load()
        coords = [_.in_units("unitary") for _ in hc.halos_ds.r[:].argmax(("io", "particle_mass"))]
        yaml.dump(coords, open({output.coords_output}, "w"))