# Notes for the Quantum Expresso Fundation proyect 

This are the firts notes for the proyect. 

## Dowload the mean code 
The code for this proyect start with this:
```bash
https://gitlab.com/QEF/q-e
```

## Compile the code 

To compile we do the following steps:
`Note`: To look for a module in leonardo we can do:
```bash
modmap -m vtune
```

```bash
# Load the modules
module load profile/base
module load intel/
module load intelmpi/
module load intel-oneapi-mpi/
module load intel-oneapi-mkl/
module load cmake/3.27.7  # >=3.2
#module load git/

# In leonardo we use
module load profile/base 
module load intel-oneapi-mpi/
module load intel-oneapi-mkl/
module load cmake/3.27.9  # >=3.2
module load intel-oneapi-compilers/2023.2.1

export FC=mpiifort
export CC=mpiicc
# check if icc is working with which icc or icc --version

```

```bash 
makdir build
cd build 

# Basic configuration
cmake .. -DQE_ENABLE_MPI=ON -DQE_ENABLE_SCALAPACK=ON

# Recomended version with cpu+mpi
# this will use Intel MPI, MKL and search LAPACK/BLAS optimized  
cmake -DQE_ENABLE_MPI=ON \
      -DQE_ENABLE_SCALAPACK=ON \
      -DQE_ENABLE_ELPA=OFF \
      -DQE_ENABLE_LIBXC=OFF \
      -DQE_ENABLE_HDF5=OFF \
      -DQE_LAPACK_INTERNAL=OFF \
      -DCMAKE_Fortran_COMPILER=mpiifort \
      -DCMAKE_C_COMPILER=mpiicc \
      ..


#In leonardo we do:

```
If MKL is available via Intel OneAPI, this should automatically detect LAPACK and SCALAPACK.
Now we continue with:

```bash 
# compile all pw.x, ph.x pp.x pwcond.x and neb.x
make pwall -j 

# compile only pw and ph
make pw ph -j

# all the binaries are in build/bin/
```

## Example 

Now I run the `job-leo-vtune.sh` and I get this configuration:

```bash
.
└── tests
    ├── Cu_ONCV_PBE-1.0.upf
    ├── H_ONCV_PBE-1.0.upf
    ├── O_ONCV_PBE-1.0.upf
    ├── d3hess.in
    ├── job-gali-vtune.sh
    ├── job-leo-vtune.sh
    ├── modified_files.txt
    ├── out
    │   ├── Cu_bulk-111-surface_0.save
    │   │   ├── Cu_ONCV_PBE-1.0.upf
    │   │   ├── H_ONCV_PBE-1.0.upf
    │   │   ├── O_ONCV_PBE-1.0.upf
    │   │   ├── charge-density.dat
    │   │   ├── data-file-schema.xml
    │   │   ├── wfc1.dat
    │   │   ├── wfc2.dat
    │   │   ├── wfc3.dat
    │   │   ├── wfc4.dat
    │   │   ├── wfc5.dat
    │   │   └── wfc6.dat
    │   ├── Cu_bulk-111-surface_0.xml
    │   ├── scf.out_nn1_17480263
    │   ├── test.err
    │   └── test.out
    ├── ph_irr32.in
    ├── ph_irr32_niter_4.in
    ├── scf.in
    └── slurmo
```
The folder `Cu_bulk-111-surface_0.save` in `out` contains all the necessary info to continue the following calculations, for example:
- Phonons calculations
- Aditional Electrinic properties like (DOS, bands, etc.)
- reinit SCF calculatios

Cu_ONCV_PBE-1.0. upf, etc.: local copies of your pseudopotentials, saved so that the calculation is reproducible.
- data-file-schema.xml: complete system structural information, atomic positions, cell, etc.
- charge-density.dat: converged load density.
- wfc.dat*: Kohn-Sham wave functions for each band (wfc = "wavefunction coefficients").

The `XML` file `Cu_bulk-111-surface_0.xml` with summary information of the converged calculation, which some later modules (for example EPW, Yambo, etc.) use to directly read structure and results.

Output file `SCF` `scf.out_nn1_17480263` Complete output of the SCF calculation, contains:

- Total energies
- Convergence of SCF
- Information on forces and tensioners
- Reprinted input parameters

To copy from leo:
```bash
rsync leonardo:/leonardo/home/userexternal/gparedes/qe-vtune-bands/directory_4_Gustavo/tests/out/Cu_bulk-111-surface_0.xml .
```
and i open tha file with https://www.xmlviewer.org or https://www.xmlviewer.org

## scf.in

## d3ness.in 
 
```bash
&D3_INPUT
   prefix   = 'Cu_bulk-111-surface_0',
   outdir   = './out',
   fildvscf = 'dvscf',
   fildyn   = 'Cu_bulk-111-surface_0_relax_0_0_ph_9.dyn',   ! dynmat output from ph.x at q=0
   fld3     = 'cuoh.d3',                                    ! output file with third derivatives
   ldisp    = .true.,                                       ! if you want to do q-point grid
   nq1 = 1, nq2 = 1, nq3 = 1,                               ! q-grid
   amass(1) = 63.546,                                      ! Cu mass
   amass(2) = 15.999,                                      ! O mass
   amass(3) = 1.0079,                                      ! H mass
   tr2_ph = 1.0d-14,                                        ! convergence threshold
/
```
- prefix and outdir match your SCF.

- amass: atomic masses, in the same order as your ATOMIC_SPECIES.

- ldisp and nq1,nq2,nq3: define if you want to use q-points mesh; for testing, you can leave 1 1 1.

- tr2_ph: convergence criterion for the calculation of forces.

## posible email

```bash
Dear [Name of adviser],

According to the ph_irr32.in file you sent me, I was able to create the scf.in file, which works correctly and I have already validated that it runs smoothly.

However, when trying to build and run the d3hess.in file, I encountered problems. I have carefully reviewed the format, variables and consistency with the SCF, but the calculation still fails when reading the namelist.

I attach the files that I am using (scf.in, ph_irr32.in and d3hess.in) for you to review.

Could you tell me if there is any additional reference or example that explains in detail how to build correctly the d3hess.in?

Thank you in advance for your help.

Cordial greetings,

Gustavo
```

## grep

to look for an specified output:

```bash
grep "convergence" out/scf.out_nn1_*
```
