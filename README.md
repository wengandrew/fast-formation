# Fast Formation Project

Last Updated 10/4/2021.

Andrew Weng

Code and analysis results for the fast formation study.

Dataset consists of 40 pouch cells built, formed, and cycled at UM Battery Lab.

Data exported from [Voltaiq](https://voltaiq.co).


## Getting Started

First, set up a virtual environment (e.g. using `pyenv`) for this project.

The code runs on Python 3.8.8.

Inside your virtual environment, install the necessary packages using:

```
pip install -r requirements.txt
```


#### Download the raw data files

The raw battery data is not stored in this repo. Download a copy of the data [here](https://doi.org/10.7302/pa3f-4w30).


#### Set up I/O folders

Modify `paths.yaml` to point to your local paths. For example:

```

 data: '/Users/aweng/code/fast-formation/data/'
 outputs: '/Users/aweng/code/fast-formation/output/'
 documents: '/Users/aweng/code/fast-formation/documents/'

```

#### Python: Test your environment

Start in the root directory of the repository.

Run `pytest` to make sure that tests are passing.

```
python -m pytest
```

This will make sure that your paths and environment are set up correctly.

#### Regenerating core datasets (if needed)

A few key operations for re-generating core datasets:

- `process_voltage_curves.m` will return a `.csv` file containing eSOH metrics
   on each cell (`summary_esoh_table.csv`)

For correlation studies, first build the correlation table:

```
python

>>> from src.utils import build_correlation_table
>>> build_correlation_table()
```

`build_correlation_table()` will take in a `summary_esoh_table.csv` and return
an augmented table containing all of the information to complete the correlation
study.

The output file will be dumped in the specified output directory, e.g
`output/correlations.csv`.

#### Running notebooks

Start a Jupyter Lab session using:

```
jupyter lab
```

#### MATLAB

MATLAB R2020a was used to run the electrode-specific state of health (eSOH)
algorithm used to generate outputs for the electrode stoichiometry model. The
source code is available under the `/matlab/` directory.

The main function to run is `process_voltage_curves.m`. This function will read
in the relevant input files from the formation tests and return diagnostic
signals.

The paths for the MATLAB executables assume the current folder is the base
directory of the repository and that the `data` and `output` folders are one level
above this directory. Before running the code, add the `/matlab/` directory
into the path using `addpath matlab`. Do not run the code from the `/matlab/` folder.

#### RStudio

RStudio is used to run the test for the differences in the coefficients of
variation.
