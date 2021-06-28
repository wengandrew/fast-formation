
# Legend
(*) : different between baseline and fast formation
(+) : probably comparable between baseline and fast formation

# (*) DEF: pseudo-capacity below 3.2V during first discharge (proxy for low-SOC resistance)
res_dict['form_first_discharge_capacity_below_3p2v_ah']

# Extract "voltage rebound after initial discharge" as a proxy to low-SOC resistance

# (*) DEF: Voltage rebound after initial discharge, 1 second
res_dict['form_first_discharge_rest_voltage_rebound_1s']

# (*) DEF: Voltage rebound after initial discharge, 10 seconds
res_dict['form_first_discharge_rest_voltage_rebound_10s']

# (*) DEF: Voltage rebound after initial discharge, 30 minutes
res_dict['form_first_discharge_rest_voltage_rebound_1800s']

# Extract voltage trace from the top of the C/10 charge preceding the
# 6-hour voltage decay. PAttia suggested using the shape of this curve
# to determine if the voltage decay is related to shifts in the voltage
# curve, e.g. due to relative stoic realignment between positive and
# negative electrode.

# (*) DEF: (Q, V) data-series from the C/10 charge curve preceding the 6-hour voltage decay
res_dict['form_last_charge_voltage_trace_cap_ah']
res_dict['form_last_charge_voltage_trace_voltage_v']

# Try to get the "10s resistance" from the C/20 charge step. This is a
# pseudo-resistance since there is no real rest here and the preceding
# step includes a bunch of voltage polarization. But this is the best we
# might be able to do.

# (*) DEF: Voltage after 1s of charging at C/10 from 0% SOC (pseudo-resistance)
res_dict['form_last_charge_voltage_after_1s']

# (*) DEF: Voltage after 10s of charging at C/10 from 0% SOC (pseudo-resistance)
res_dict['form_last_charge_voltage_after_10s']

# (*) DEF: Voltage after 60s of charging at C/10 from 0% SOC (pseudo-resistance)
res_dict['form_last_charge_voltage_after_60s']

# (*) DEF: Charge capacity of the very first cycle (Ah)
res_dict['form_first_charge_capacity_ah']

# (*) DEF: Discharge capacity of the very first cycle (Ah)
res_dict['form_first_discharge_capacity_ah']

# (*) DEF: Ratio of charge and discharge capacity for the very first cycle
res_dict['form_first_cycle_efficiency']

# (+) DEF: Discharge capacity corresponding to the very last cycle of
#         formation (C/10 for both profiles)
res_dict['form_final_discharge_capacity_ah']

# (+) DEF: C/10 charge dV/dQ peak-to-peak distance (Ah)
#      There is a typo in the variable name
res_dict['form_c20_charge_qpp_ah']

# (+) DEF: C/10 charge dV/dQ right peak height (V/Ah)
#      There is a typo in the variable name
res_dict['form_c20_charge_right_peak_v_per_ah']

# (+) DEF: Delta voltage after 6 hour rest at 100% SOC (preceded by a C/100 CV cut)
res_dict['form_6hr_rest_delta_voltage_v']

# (+) DEF: Final voltage after 6 hour rest at 100% SOC (preceded by a C/100 CV cut)
res_dict['form_6hr_rest_voltage_v']

# (+) DEF: Steady-state voltage decay rate after 6 hour rest at 100% SOC (mV/day)
#     (Averaged over last 2 hours)
res_dict['form_6hr_rest_mv_per_day_steady']

# (+) DEF: Initial voltage drop rate after 6 hour rest at 100% SOC (mV/sec)
#      (Averaged over first 15 minutes)
res_dict['form_6hr_rest_mv_per_sec_initial']

# (+) DEF: First cycle CV hold capacity (Ah)
res_dict['form_first_cv_hold_capacity_ah']
