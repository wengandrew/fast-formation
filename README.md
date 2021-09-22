# Fast Formation Project

Last Updated 9/21/2021

Andrew Weng

Code and analysis results for the fast formation study.

Dataset consists of 40 pouch cells built, formed, and cycled at UM Battery Lab.

Data exported from [Voltaiq](https://umichbatterylab.voltaiq.co).


### Requirements

#### Python

- python3
- openpyxl
- scipy
- matplotlib
- ipdb
- jupyter
- numpy
- pandas
- pytest
- pyyaml
- natsort
- seaborn
- sklearn

#### MATLAB

MATLAB R2020a was used to run the electrode-specific state of health (eSOH)
algorithm used to generate outputs for the electrode stoichiometry model. The source code is available under the `/matlab/` directory.

#### RStudio

RStudio is used to run the test for the differences in the coefficients of
variation.


### Getting Started

#### Set up I/O folders

Modify `paths.yaml` to point to your local data directories.


#### Python: Test your environment

Start in the root directory. Run `pytest` to make sure that tests are passing.

```
pytest
```

This will make sure that your paths are all configured correctly and that your Python environment is set up correctly.

#### Regenerating core datasets (if needed)

A few key operations for re-generating core datasets:

- `process_voltage_curves.m` will return a `.csv` file containing
   eSOH metrics on each cell (`summary_esoh_table.csv`)

For correlation studies, first build the correlation table:

```
python

>>> from utils import build_correlation_table
>>> build_correlation_table()
```

`build_correlation_table()` will take in a `summary_esoh_table.csv` and return
an augmented table containing all of the information to complete the correlation study.

The output file will be dumped in the specified output directory, e.g `output/correlations.csv`.

#### Running notebooks

Start a Jupyter Lab session using:

```
jupyter lab
```
