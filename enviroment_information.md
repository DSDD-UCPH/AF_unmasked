### Environment Information

Setting up the via the original github via the following has compatibilty issues.

```Shell
conda env create --file=AF_unmasked/environment.yaml
python setup.py install
```

#### Idea: to modify a clone of the AF2 environment set up on the cluster to be the AF unmasked 
```Shell 
module load miniconda
conda create --prefix=AF2.3.1_unmasked --clone /projects/ilfgrid/apps/alphafold-2.3.1/AF2.3.1_cuda11.8_conda_env
conda install -c conda-forge biopython
```

Problems: 
* [AlphaFold pinning to Openmm 7.5.1: Potential Fix ](https://github.com/google-deepmind/alphafold/issues/404#issuecomment-1100518057)

```Shell
 ERROR: Could not find a version that satisfies the requirement jaxlib==0.4.35 (from versions: 0.4.6, 0.4.7, 0.4.9, 0.4.10, 0.4.11, 0.4.12, 0.4.13, 0.4.14, 0.4.16, 0.4.17, 0.4.18, 0.4.19, 0.4.20, 0.4.21, 0.4.22, 0.4.23, 0.4.24, 0.4.25, 0.4.26, 0.4.27, 0.4.28, 0.4.29, 0.4.30)
ERROR: No matching distribution found for jaxlib==0.4.35
```
Unpinned the OpenMM in AlphaFold

Changes:
`/projects/ilfgrid/apps/AF_unmasked/alphafold/relax/amber_minimize.py`
```Python
#from simtk import openmm
import openmm
#from simtk import unit
from openmm import unit
#from simtk.openmm import app as openmm_app
from openmm import app as openmm_app
#from simtk.openmm.app.internal.pdbstructure import PdbStructure
from openmm.app.internal.pdbstructure import PdbStructure
```

`/projects/ilfgrid/apps/AF_unmasked/alphafold/relax/cleanup.py`
from openmm import app
#from simtk.openmm import app

from openmm.app import element
#from simtk.openmm.app import element


Conda change: Verified these module changes are already on the cluster version of AF2.3.1
`/projects/ilfgrid/apps/AF_unmasked/AF2.3.1_unmasked/lib/python3.8/site-packages/pdbfixer/pdbfixer.py`

```python
import openmm as mm
#import simtk.openmm as mm

import openmm.app as app
#import simtk.openmm.app as app

from openmm import unit 
#import simtk.unit as unit

from openmm.app.internal.pdbstructure import PdbStructure
#from simtk.openmm.app.internal.pdbstructure import PdbStructure

from openmm.app.internal.pdbx.reader.PdbxReader import PdbxReader
#from simtk.openmm.app.internal.pdbx.reader.PdbxReader import PdbxReader

from openmm.app.element import hydrogen, oxygen
#from simtk.openmm.app.element import hydrogen, oxygen

from openmm.app.forcefield import NonbondedGenerator
#from simtk.openmm.app.forcefield import NonbondedGenerator

# Support Cythonized functions in OpenMM 7.3
# and also implementations in older versions.
try:
    from openmm.app.internal import compiled
    #from simtk.openmm.app.internal import compiled
    matchResidue = compiled.matchResidueToTemplate
except ImportError:
    matchResidue = app.forcefield._matchResidue
```

