### Environment Information

Setting up the via the original github via the following has compatibilty issues.

```Shell
conda env create --file=AF_unmasked/environment.yaml
python setup.py install
```

#### Idea: to modify a clone of the AF2 environment set up on the cluster to be the AF unmasked 
```Shell 
conda create --prefix=AF2.3.1_unmasked --clone /projects/ilfgrid/apps/alphafold-2.3.1/AF2.3.1_cuda11.8_conda_env
```

Problems: 
* [AlphaFold pinning to Openmm 7.5.1: Potential Fix ](https://github.com/google-deepmind/alphafold/issues/404#issuecomment-1100518057)

```Shell
 ERROR: Could not find a version that satisfies the requirement jaxlib==0.4.35 (from versions: 0.4.6, 0.4.7, 0.4.9, 0.4.10, 0.4.11, 0.4.12, 0.4.13, 0.4.14, 0.4.16, 0.4.17, 0.4.18, 0.4.19, 0.4.20, 0.4.21, 0.4.22, 0.4.23, 0.4.24, 0.4.25, 0.4.26, 0.4.27, 0.4.28, 0.4.29, 0.4.30)
ERROR: No matching distribution found for jaxlib==0.4.35
```

