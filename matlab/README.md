# MATLAB Resources

## Description of functions

`process_voltage_curves.m` 

Main runner code which runs the voltage fitting algorithm on the 
entire dataset. Loops through each cell and each aging point for 
each cell. Wraps around `run_esoh.m` which is used to run the voltage
fitting for every individual dataset.

This function will generate an output `.csv` file at a specified path.


`run_esoh.m` 

Runs the voltage-fitting algorithm on a single dataset, returning
a struct holding results (e.g. Cn, Cp, x100, ...). This function wraps
`run_voltage_fit.m` to run the actual optimization algorithm.

This function returns a struct holding the results but does not write
to file.


`plot_summary_esoh_table.m`

Generates standard plots given a set of voltage fitting results that
have already been written to file. Writes the plots into an output 
folder specified by the user at the top of the script.



