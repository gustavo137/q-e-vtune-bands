#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --time=00:15:00
#SBATCH --error=out/test.err                 # std-error file
#SBATCH --output=out/test.out                # std-output file
#SBATCH --account=ICT25_MHPC_0           #Sis25_baroni    # account number
#SBATCH --partition=boost_usr_prod
#SBATCH --qos=boost_qos_dbg
##SBATCH --dependency=afterany:16530568

## Modules
module purge
module load profile/base
module load intel-oneapi-mpi/
module load intel-oneapi-mkl/
#module load cmake/3.27.9  # >=3.2
module load intel-oneapi-compilers/2023.2.1

#module load vtune 
module load intel-oneapi-vtune/


## # Routes to your newly compiled executables
##export PW=/g100_work/Sis25_baroni/pietrod/build_intel_741/bin/pw.x 
##export D3H=/g100_work/Sis25_baroni/pietrod/build_intel_741/bin/d3hess.x
##export PH=/g100_work/Sis25_baroni/pietrod/build_intel_741/bin/ph.x
export PW=/leonardo/home/userexternal/gparedes/qe-vtune-bands/build/bin/pw.x
export D3H=/leonardo/home/userexternal/gparedes/qe-vtune-bands/build/bin/d3hess.x
export PH=/leonardo/home/userexternal/gparedes/qe-vtune-bands/build/bin/ph.x
export suffix=nn${SLURM_NNODES}_${SLURM_JOB_ID}

## Control of threads 
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1

## # Execution of commands
## scf.in created based on EPW/examples/sic/epw/scf.in
## d3hess.in comming from

### Working
srun --cpu_bind=cores $PW -i scf.in > out/scf.out_${suffix}

## I need tofix this one
#srun --cpu_bind=cores $D3H -i d3hess.in > out/d3hess.out_${suffix}

### Working 
#srun --cpu_bind=cores $PH -i ph_irr32.in > out/ph_irr32.out_${suffix}
#srun --cpu_bind=cores $PH -nb 2 -i ph_irr32.in > out/ph_irr32_NB2.out_${suffix}

### Running with profiling
srun --cpu_bind=cores vtune -trace-mpi -collect hotspot -result-dir results_hotspot_${SLURM_JOB_ID} -- $PH -nb 2 -i ph_irr32_niter_4.in > out/ph_irr32_NB2_prof${suffix}
