# Source code for formation project

Readme last updated: 4/22/2012

This directory contains source code used to process data for the formation project.

## Directories and important functions

- `imgs/`: contains some images referenced in the notebooks
- `src/`: source code
  - `formation.py`: data processing engine for formation data
  - `diagnostics_Qs_voltage_only.m`: the "core" of the eSOH algorithm
  - `process_voltage_curves.m`: entry point for starting the eSOH analysis
  - `plot_figures.m`: deprecated method for making paper figures
- `tests/`: used to test the code`
  - `test_formation.py`: make sure all tests pass if you want to use `formation.py`

The root directory also contains a bunch of IPython Notebooks, including:
- `build_figures.ipynb`: used to make figures for Paper 1
- `build_regression_model.ipynb`: used to train the linear regression model for Paper 1
- `process_all_data.ipynb`: 
- `process_correalation_plots.ipynb`: package a bunch of data together into a giant output table
  - This is the function that produces the `correlation_data.csv` file that will be used for building any sort of data-driven predictive model
- `process_cycling_data.ipynb`: [DEPRECATED] Used to get plots of the cycling data before `formation.py` was built
- `process_dcr_correlations.ipynb`: a quick study to make sure `cellid` was not a confounding variable
- `process_formation_data.iypnb`: [DEPRECATED] Used to get plots of the formation data before `formation.py` was built
- `process_formation_voltage_decay_study.iypnb`: an attempt to convince ourselves that the formation 6-hour voltage decay signal is related to stoic shifts and not something else. I'm still not convinced.
