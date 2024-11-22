#### AlphaFold Unmasked Examples

[2VB1](https://www.rcsb.org/structure/2vb1): Simple example well known monomer 1

Simplest case for debugging it will just be passed it's own mmCIF as a template to see if the system works

```Fasta
>2VB1_1|Chain A|LYSOZYME C|GALLUS GALLUS (9031)
KVFGRCELAAAMKRHGLDNYRGYSLGNWVCAAKFESNFNTQATNRNTDGSTDYGILQINSRWWCNDGRTPGSRNLCNIPCSALLSSDITASVNCAKKIVSDGNGMNAWVAWRNRCKGTDVQAWIRGCR
```

Template setup 
```Shell
python AF_unmasked/prepare_templates.py --target mono/2VB1_1.fasta --template templates/2VB1_template.cif --output_dir AF_models/ --align
```
Output
```
Deleting clashing residues... 2 clashes found.

Aligning target sequence 1 (seq: KVFGRCELAA...) to template chain A (seq: KVFGRCELAA...)
KVFGRCELAAAMKRHGLDNYRGYSLGNWVCAAKFESNFNTQATNRNTDGSTDYGILQINSRWWCNDGRTPGSRNLCNIPCSALLSSDITASVNCAKKIVSDGNGMNAWVAW--RCKGTDVQAWIRGCRL
KVFGRCELAAAMKRHGLDNYRGYSLGNWVCAAKFESNFNTQATNRNTDGSTDYGILQINSRWWCNDGRTPGSRNLCNIPCSALLSSDITASVNCAKKIVSDGNGMNAWVAWRNRCKGTDVQAWIRGCRL
Run AlphaFold with, e.g.:
python run_alphafold.py --fasta_paths mono/2VB1_1.fasta --flagfile databases.flag --flagfile AF_models/2VB1_1/template_data/templates.flag --output_dir AF_models --cross_chain_templates --dropout --model_preset='multimer_v2' --separate_homomer_msas
```