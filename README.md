# Fast Formation Project

7/5/2021

Andrew Weng

Code and analysis results for the fast formation study.

Dataset consists of 40 pouch cells built, formed, and cycled at UM Battery Lab.

Data exported from [Voltaiq](umichbatterylab.voltaiq.co).


### Folder Descriptions

- `code/`: source code written in both Python and MATLAB
- `data/...microformation.../`: data from formation cycles, exported from Voltaiq
- `data/...aging.../`: data from aging tests, exported from Voltaiq
- `data/...diagnostic/`: post-processed from aging test data
- `documents/`: reference documents
- `output/`: processed data output (e.g. eSOH fit results, features extracted)


### Requirements

#### Python

- python3
- openpyxl
- scipy
- matplotlib
- ipdb
- numpy
- pandas
- pytest
- natsort
- seaborn
- sklearn
- jupyter

#### MATLAB

MATLAB R2020a was used to run the electrode-specific state of health (eSOH)
algorithm used to generate the equilibrium potential toy model. 

#### RStudio

RStudio is used to run the test for the differences in the coefficients of 
variation.


### Getting Started


#### Python: Test your environment

Start in the root directory. Run `pytest` to make sure the tests are passing.

```
pytest
```

This will make sure that you have all of the Python dependencies and data files 
necessary to use the data processing tools in this library.


#### Regenerating core datasets (if needed)

A few key operations for re-generating core datasets:

- `process_voltage_curves.m` is responsible to returning an output file containing
   eSOH metrics on each cell (`summary_esoh_table.csv`)

For correlation studies, you need to build a complete table of parameters. This is
done using a Python utility. To run Python source code, always start in the 
`code-base` directory:

```
cd code-base
python3

>>> from src.utils import build_correlation_table
>>> build_correlation_table()
```

`build_correlation_table()` will take in a `summary_esoh_table.csv` and return
an augmented table containing all of the information to complete the correlation study.

Check to make sure there exists a file called `output/correlations.csv`.

#### Running notebooks

To run the analysis notebooks, make sure you have `jupyter` installed.

Open up Jupyter from the Terminal like so:

```
python3 -m jupyter notebook
```

A new tab will open on your web browser containing the notebook. Proceed to open up
each notebook for exploration.
