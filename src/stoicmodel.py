"""
Utility functions as part of the electrode stoichiometry model

The functions defined here are used by
`build_electrode_stoichiometry_model.ipynb`

"""

import numpy as np
from scipy import interpolate
from matplotlib import pyplot as plt

# Plot aesthetics
COLOR_BASE = np.array([0, 0, 0])
COLOR_FAST = np.array([44, 121, 245])/255
COLOR_FAST_RT = np.array([0, 0, 1])
COLOR_FAST_HT = np.array([1, 0, 0])
LINESTYLE_BASE = ':'
LINESTYLE_FAST = '-'

# Pos/neg electrode colors
COLOR_POS = np.array([0, 0, 1])
COLOR_NEG = np.array([1, 0, 0])
COLOR_FULL = np.array([0, 0, 0])

COLOR_BG = (0.2, 0.2, 0.2)
COLOR_REF = (0.7, 0.7, 0.7)

NOMINAL_CAPACITY_AH = 2.36
CAPACITY_LIMITS_AH = (0.8, 2.4)
TARGET_RETENTION = 0.7

figsize = (9, 5.5)


def compute_resistance_curves(capacity_vec,
                              resistance_vec,
                              frac_cathode_resistance=0.7,
                              capacity_shift_ah=0,
                              resistance_growth_rate=0,
                              adjust_for_resistance_change=False,
                              swap_cathode_anode=False,
                              split_proportionally=False):
    """
    Create a data set consisting of pos, neg, and full cell resistance curves.

    We will apportion the resistances to qualitatively match the empirical results.

    A more quantitative break-down of resistances will require more careful data
    analysis of the cathode and anode contributions to the total cell resistance.
    This will require some more experiments which we will leave as future work.

    The advantage of this model construction is that it lets us easily study model
    sensitivities (i.e. hypothetical scenarios of different cathode/anode breakdown
    of the total cell resistance).

    Parameters
    ---------
    capacity_vec (np.array)
      vector of capacity for full cell

    resistance_vec (np.array)
      vector of resistance for full cell in Ohms

    frac_cathode_rct (0-1)
      fraction of total measured resistance attributed to cathode charge tranfser

    capacity_shift_ah (float)
      capacity corresponding to extra lithium lithium lost to SEI during formation

    resistance_growth_rate (float)
      SEI resistance growth per Ah of Li

    adjust_for_resistance_change (boolean)
      if True then will make an additional adjustment to the curve to account for
      intrinsic resistance growth

    swap_cathode_anode (boolean)
      if True then swap the cathode and anode resistance curves (for sensitivity analysis)

    split_proportionally (boolean)
      if True then split the resistance proportionally between cathode and anode
      based on frac_cathode_resistance


    Outputs
    ---------
    a dictionary containing:

      capacity_expanded
        an updated capacity vector that matches the dimensions of the shifted resistances

      resistance_full_modeled
        modeled full cell resistance after shifting (Ohms)

      resistance_cathode
        modeled cathod charge transfer resistance (Ohms)

      resistance_other
        modeled 'other' resistance (Ohms)


    Invariants
    ---------

    resistance_other + resistance_cathode_shifted = resistance_full_modeled

    """

    # Definition of "base" resistance
    capacity_threshold = 1
    resistance_base = np.min(resistance_vec[capacity_vec < capacity_threshold])

    # Reference resistance (intermediate step for constructing cathode resistance)
    resistance_ref = (1 - frac_cathode_resistance) * resistance_base * np.ones(np.size(resistance_vec))

    # Construct the cathode charge transfer resistance curve
    # Assumes:
    # - Cathode inherits all of the resistances at low capacities up to some reference point
    # - Cathode resistance flattens out after the capacity threshold
    resistance_cathode = resistance_vec - resistance_ref
    resistance_cathode[capacity_vec > capacity_threshold] = \
       resistance_cathode[capacity_vec <= capacity_threshold][-1]

    # Definition of R_other
    resistance_other = resistance_vec - resistance_cathode

    # Define shifted cathode charge transfer resistance

    # Shifting the resistance curve!

    # Expand the the capacity vector to include negative values
    cap_vec_min = 0
    cap_vec_max = np.max(capacity_vec)
    cap_vec_diff = np.diff(capacity_vec)[0]

    capacity_vec_expanded = np.arange(cap_vec_min, cap_vec_max + cap_vec_diff, cap_vec_diff)

    fn = interpolate.interp1d(capacity_vec, resistance_cathode, bounds_error=False, fill_value='extrapolate')
    resistance_cathode_shifted = fn(capacity_vec_expanded + capacity_shift_ah)

    fn2 = interpolate.interp1d(capacity_vec, resistance_other, bounds_error=False, fill_value='extrapolate')
    resistance_other_expanded = fn2(capacity_vec_expanded)

    if adjust_for_resistance_change:
        resistance_other += resistance_growth_rate * capacity_shift_ah

    # Calculated the shifted full cell resistance
    resistance_full_modeled = resistance_other_expanded + resistance_cathode_shifted

    # Assert invariants hold
#     assert np.all(resistance_cathode_shifted + resistance_other_expanded == resistance_full_modeled)

    output = dict()
    output['resistance_full_modeled'] = resistance_full_modeled

    output['capacity_expanded'] = capacity_vec_expanded
    output['resistance_cathode'] = resistance_cathode_shifted
    output['resistance_other'] = resistance_other_expanded

    # Define some simple operations for sensitivity studies

    # The cathode and anode curves are swapped
    if swap_cathode_anode:
        output['resistance_cathode'] = resistance_other_expanded
        output['resistance_other'] = resistance_cathode_shifted

    # Ignore all of that math we just did and simply split the total measured resistance
    if split_proportionally:
        output['resistance_cathode'] = resistance_full_modeled * frac_cathode_resistance
        output['resistance_other'] = resistance_full_modeled * (1 - frac_cathode_resistance)

    return output


def fetch_voltage_resistance_dataset(df_esoh, df_hppc,
                                     resistance_interp_kind='linear', # cubic, linear
                                     resistance_curves_type='default',
                                     frac_cathode_resistance=0.7):
    """
    Load the raw data and package it in an organized way.

    Make the entire dataset share a common x-axis basis.

    Parameters
    ----------
        df_esoh (DataFrame)
            DataFrame containing the eSOH data
        ef_hppc (DataFrame)
            DataFrame containing the HPPC data
        resistance_interp_kind
          the resistance measured by HPPC is discretized.
          this option lets the user set what kindof interpolation to do
          suggested options:
            linear: least "data creation"
            cubic: smooth curves for demonstration
        resistance_curves_type (str):
            default: cathode dominated
            swapped: anode dominated
            split: 50/50 partitioning

    Outputs a dictionary containing:
        capacity (Ah) : shared capacity basis
        positive electrode voltage (V)
        positive electrode resistance (mOhms)
        negative electrode voltage (V)
        negative electrode resistance (mOhms)
    """

    # Declare shared capacity basis
    shared_q = np.arange(-0.5, 3.01, 0.001)

    ## Unpack the equilibrium voltage data

    # Source: eSOH fitting outputs
    pos_q = df_esoh['pos']['Q']
    pos_v = df_esoh['pos']['V']
    neg_q = df_esoh['neg']['Q']
    neg_v = df_esoh['neg']['V']

    # Make data share common x-grid
    fn = interpolate.interp1d(pos_q, pos_v, bounds_error=False)
    pos_v = fn(shared_q)

    fn = interpolate.interp1d(neg_q, neg_v, bounds_error=False)
    neg_v = fn(shared_q)

    # Bring full cell voltage 3.0V back to "origin"
    # This must be done because the equilibrium voltage data doesn't
    # Precisely match the full cell voltage, leading to some voltage error
    # This error is quite large at low voltages where the shape of the
    # Thermodynamic is large. This creates a misalignment in what the eSOH
    # Model thinks is 0% SOC and what the data actually is saying
    ful_v  = pos_v - neg_v
    fn = interpolate.interp1d(ful_v, shared_q)
    model_error_cap_offset = fn(3.0)
    shared_q = shared_q - model_error_cap_offset

    ## Unpack the resistance data

    # Source: HPPC pulse data

    # Collect the full cell data
    capacity = df_hppc['capacity']

    # Build a higher fidelity, smooth signal for the toy model
    resistance = df_hppc['resistance_10s_ohm']
    capacity_hifi = np.linspace(np.min(capacity), np.max(capacity), 300)
    interp_fn = interpolate.interp1d(capacity, resistance,
                                     bounds_error=False,
                                     kind=resistance_interp_kind)
    resistance_hifi = interp_fn(capacity_hifi)

    # Build the synthetic curves from the toy model

    if resistance_curves_type == 'default':

        res_dict = compute_resistance_curves(capacity_hifi, resistance_hifi,
                                         frac_cathode_resistance)

    elif resistance_curves_type == 'swapped':

        res_dict = compute_resistance_curves(capacity_hifi, resistance_hifi,
                                         frac_cathode_resistance,
                                         swap_cathode_anode=True)

    elif resistance_curves_type == 'split':

        res_dict = compute_resistance_curves(capacity_hifi, resistance_hifi,
                                         frac_cathode_resistance,
                                         split_proportionally=True)

    else:

        assert f'"{resistance_curves_type}" is not a valid argument'


    res_q = res_dict['capacity_expanded']
    pos_r = res_dict['resistance_cathode']
    neg_r = res_dict['resistance_other']

    # Make data share common x-grid
    fn = interpolate.interp1d(res_q, pos_r, bounds_error=False, fill_value=np.NaN)
    pos_r_shared = fn(shared_q)

    fn = interpolate.interp1d(res_q, neg_r, bounds_error=False, fill_value=np.NaN)
    neg_r_shared = fn(shared_q)

    # Trim cathode voltage model output to end at 3V
    # (Don't let it extrapolate too much)
    pos_v[np.where(pos_v < 3.0)] = np.NaN

    # Package the results
    out = dict()
    out['capacity'] = shared_q
    out['pos_v'] = pos_v
    out['pos_r'] = pos_r_shared
    out['neg_v'] = neg_v
    out['neg_r'] = neg_r_shared

    return out


def fetch_voltage_resistance_dataset(df_esoh, df_hppc,
                                     resistance_interp_kind='linear', # cubic, linear
                                     resistance_curves_type='default',
                                     frac_cathode_resistance=0.7):
    """
    Load the raw data and package it in a neat way.

    Make the entire dataset share a common x-axis basis.

    Parameters
    ----------
        df_esoh (DataFrame)
            DataFrame containing the eSOH data
        ef_hppc (DataFrame)
            DataFrame containing the HPPC data
        resistance_interp_kind
          the resistance measured by HPPC is discretized.
          this option lets the user set what kindof interpolation to do
          suggested options:
            linear: least "data creation"
            cubic: smooth curves for demonstration
        resistance_curves_type (str):
            default: cathode dominated
            swapped: anode dominated
            split: 50/50 partitioning

    Outputs a dictionary containing:
        capacity (Ah) : shared capacity basis
        positive electrode voltage (V)
        positive electrode resistance (mOhms)
        negative electrode voltage (V)
        negative electrode resistance (mOhms)
    """

    # Declare shared capacity basis
    shared_q = np.arange(-0.5, 3.01, 0.001)

    ## Unpack the equilibrium voltage data

    # Source: eSOH fitting outputs
    pos_q = df_esoh['pos']['Q']
    pos_v = df_esoh['pos']['V']
    neg_q = df_esoh['neg']['Q']
    neg_v = df_esoh['neg']['V']

    # Make data share common x-grid
    fn = interpolate.interp1d(pos_q, pos_v, bounds_error=False)
    pos_v = fn(shared_q)

    fn = interpolate.interp1d(neg_q, neg_v, bounds_error=False)
    neg_v = fn(shared_q)

    # Bring full cell voltage 3.0V back to "origin"
    # This must be done because the equilibrium voltage data doesn't
    # Precisely match the full cell voltage, leading to some voltage error
    # This error is quite large at low voltages where the shape of the
    # Thermodynamic is large. This creates a misalignment in what the eSOH
    # Model thinks is 0% SOC and what the data actually is saying
    ful_v  = pos_v - neg_v
    fn = interpolate.interp1d(ful_v, shared_q)
    model_error_cap_offset = fn(3.0)
    shared_q = shared_q - model_error_cap_offset

    ## Unpack the resistance data

    # Source: HPPC pulse data

    # Collect the full cell data
    capacity = df_hppc['capacity']

    # Build a higher fidelity, smooth signal for the toy model
    resistance = df_hppc['resistance_10s_ohm']
    capacity_hifi = np.linspace(np.min(capacity), np.max(capacity), 300)
    interp_fn = interpolate.interp1d(capacity, resistance,
                                     bounds_error=False,
                                     kind=resistance_interp_kind)
    resistance_hifi = interp_fn(capacity_hifi)

    # Build the synthetic curves from the toy model

    if resistance_curves_type == 'default':

        res_dict = compute_resistance_curves(capacity_hifi, resistance_hifi,
                                         frac_cathode_resistance)

    elif resistance_curves_type == 'swapped':

        res_dict = compute_resistance_curves(capacity_hifi, resistance_hifi,
                                         frac_cathode_resistance,
                                         swap_cathode_anode=True)

    elif resistance_curves_type == 'split':

        res_dict = compute_resistance_curves(capacity_hifi, resistance_hifi,
                                         frac_cathode_resistance,
                                         split_proportionally=True)

    else:

        assert f'"{resistance_curves_type}" is not a valid argument'


    res_q = res_dict['capacity_expanded']
    pos_r = res_dict['resistance_cathode']
    neg_r = res_dict['resistance_other']

    # Make data share common x-grid
    fn = interpolate.interp1d(res_q, pos_r, bounds_error=False, fill_value=np.NaN)
    pos_r_shared = fn(shared_q)

    fn = interpolate.interp1d(res_q, neg_r, bounds_error=False, fill_value=np.NaN)
    neg_r_shared = fn(shared_q)

    # Trim cathode voltage model output to end at 3V
    # (Don't let it extrapolate too much)
    pos_v[np.where(pos_v < 3.0)] = np.NaN

    # Package the results
    out = dict()
    out['capacity'] = shared_q
    out['pos_v'] = pos_v
    out['pos_r'] = pos_r_shared
    out['neg_v'] = neg_v
    out['neg_r'] = neg_r_shared

    return out

def voltage_resistance_transform(res, shift_ah,
                                 pos_shrink_frac=0,
                                 pos_shrink_loc='bottom',
                                 neg_shrink_frac=0,
                                 neg_shrink_loc='bottom'):
    """
    Modify the voltage-resistance curves using a shift

    Parameters
    ---------
        res (Dict)
            contains the voltage and resistance curves
        shift_ah (numeric)
            value to shift by in Amp-hours
        pos_shrink_frac (numeric, 0-1)
            percentage to shrink the positive electrode curve
        pos_shrink_loc (str)
            shrink from either 'top' or 'bottom'
        neg_shrink_frac (numeric, 0-1)
            percentage to shrink the negative electrode curve
        neg_shrink_loc (str)
            shrink from either 'top' or 'bottom'

    Outputs
    ---------
         res_out (Dict)
             modified contents after the shift takes place
         some other useful metrics

    """

    assert pos_shrink_frac < 1 and pos_shrink_frac >=0, \
        'Positive electrode shrinkage must be a fraction.'
    assert neg_shrink_frac < 1 and neg_shrink_frac >=0, \
        'Negative electrode shrinkage must be a fraction.'

    res_out = res.copy()

    ## Perform the shift

    fn = interpolate.interp1d(res['capacity'] + shift_ah,
                              res['pos_v'], bounds_error=False)
    res_out['pos_v'] = fn(res['capacity'])

    fn = interpolate.interp1d(res['capacity'] + shift_ah,
                              res['pos_r'], bounds_error=False)
    res_out['pos_r'] = fn(res['capacity'])

    # Shrink the positive curve
    orig_capacity = res_out['capacity'].copy()
    pos_voltage = res_out['pos_v'].copy()
    pos_resistance = res_out['pos_r'].copy()
    pos_capacity = res_out['capacity'].copy()

    if pos_shrink_loc == 'top':
        pivot_index = np.where(~np.isnan(pos_voltage))[0][0]
    elif pos_shrink_loc == 'bottom':
        pivot_index = np.where(~np.isnan(pos_voltage))[0][-1]
    else:
        assert "Shrink location must be either 'top' or 'bottom'"

    temp_offset = pos_capacity[pivot_index]

    pos_capacity -= temp_offset
    pos_capacity = pos_capacity * (1 - pos_shrink_frac)
    pos_capacity += temp_offset

    fn = interpolate.interp1d(pos_capacity, pos_voltage, bounds_error=False)
    res_out['pos_v'] = fn(orig_capacity)

    fn = interpolate.interp1d(pos_capacity, pos_resistance, bounds_error=False)
    res_out['pos_r'] = fn(orig_capacity)

    # Shrink the negative curve
    orig_capacity = res_out['capacity'].copy()
    neg_voltage = res_out['neg_v'].copy()
    neg_resistance = res_out['neg_r'].copy()
    neg_capacity = res_out['capacity'].copy()

    if neg_shrink_loc == 'top':
        pivot_index = np.where(~np.isnan(neg_voltage))[0][0]
    elif neg_shrink_loc == 'bottom':
        pivot_index = np.where(~np.isnan(neg_voltage))[0][-1]
    else:
        assert "Shrink location must be either 'top' or 'bottom'"

    temp_offset = neg_capacity[pivot_index]

    neg_capacity -= temp_offset
    neg_capacity = neg_capacity * (1 - neg_shrink_frac)
    neg_capacity += temp_offset

    fn = interpolate.interp1d(neg_capacity, neg_voltage, bounds_error=False)
    res_out['neg_v'] = fn(orig_capacity)

    fn = interpolate.interp1d(neg_capacity, neg_resistance, bounds_error=False)
    res_out['neg_r'] = fn(orig_capacity)

    return res_out


def compute_useful_metrics(res, min_voltage, max_voltage, soc_target=0.05):
    """
    Take a standard result set and parse out some useful metrics

    Parameters
    ---------
        res (Dict)
            contains the voltage and resistance curves
        min_voltage
            e.g. 3.0
        max_voltage
            e.g. 4.2
        soc_target (0-1)
            target SOC for extracting the metrics

    Outputs (dictionary)
    ---------
        absolute capacity (Ah) : arbitrary x basis
        resistance at target SOC (mOhms)
        cell capacity (Ah) : respects voltage limits
        x0 : anode stoichiometry at SOC target
        y0 : anode stoichiometry at SOC target
        pos_v_at_100_soc: positive electrode voltage at 100% SOC
    """

    ful_v = res['pos_v'] - res['neg_v']
    ful_r = res['pos_r'] + res['neg_r']

    # Re-compute the cell capacity based on the voltage window renormalization
    fn = interpolate.interp1d(ful_v, res['capacity'])
    max_cap = fn(max_voltage)
    min_cap = fn(min_voltage)
    cell_cap = max_cap - min_cap

    # The capacity basis is a tricky thing. As the positive and negative curves slide
    # Around, the point at which the full cell equals Min Voltage (e.g. 3.0V) will change
    # On the basis of the full cell, 3.0V defines 0% SOC. So let's be careful about where
    # we take "5%" SOC
    absolute_cap_at_target_soc = min_cap + soc_target * cell_cap

    fn = interpolate.interp1d(res['capacity'], ful_r)

    resistance_at_target_soc = fn(absolute_cap_at_target_soc)

    # Compute x and y at target SOC
    idx0 = np.where(~np.isnan(res['pos_v']))[0][0]
    idx1 = np.where(~np.isnan(res['pos_v']))[0][-1]
    cathode_capacity = res['capacity'][idx1] - res['capacity'][idx0]
    cathode_capacity_at_target_soc = absolute_cap_at_target_soc - res['capacity'][idx0]
    y0 = 1 - cathode_capacity_at_target_soc / cathode_capacity

    idx0 = np.where(~np.isnan(res['neg_v']))[0][0]
    idx1 = np.where(~np.isnan(res['neg_v']))[0][-1]
    anode_capacity = res['capacity'][idx1] - res['capacity'][idx0]
    anode_capacity_at_target_soc = absolute_cap_at_target_soc - res['capacity'][idx0]
    x0 = anode_capacity_at_target_soc / anode_capacity

    # Cathode potential at Max Voltage
    fn = interpolate.interp1d(res['capacity'], res['pos_v'])
    pos_v_at_100_soc = fn(max_cap)

    # Package outputs
    output_dict = dict()
    output_dict['absolute_cap_at_target_soc'] = absolute_cap_at_target_soc
    output_dict['resistance_at_target_soc'] = resistance_at_target_soc
    output_dict['cell_cap'] = cell_cap
    output_dict['x0'] = x0
    output_dict['y0'] = y0
    output_dict['pos_v_at_100_soc'] = pos_v_at_100_soc

    return output_dict


def plot_shift(shift_mah, pos_shrink, neg_shrink, res_orig, metrics_orig,
               target_soc, min_voltage, max_voltage, xlims):

    res = voltage_resistance_transform(res_orig, shift_mah / 1000,
                                       pos_shrink_loc='bottom',
                                       neg_shrink_loc='top',
                                       pos_shrink_frac=pos_shrink,
                                       neg_shrink_frac=neg_shrink)


    metrics = compute_useful_metrics(res, min_voltage, max_voltage, target_soc)

    plt.figure(figsize=(6, 6))

    # Make the voltage plots
    plt.subplot(2,1,1)

    ax1 = plt.gca()
    ax2 = plt.gca().twinx()

    ax1.axvline(x=metrics['absolute_cap_at_target_soc'], color=COLOR_REF)
    ax1.axvline(x=metrics_orig['absolute_cap_at_target_soc'], color=COLOR_REF, linestyle=':', linewidth=0.7)

    ax1.plot(res['capacity'], res['pos_v'], color=COLOR_POS)
    ax2.plot(res['capacity'], res['neg_v'], color=COLOR_NEG)
    ax1.plot(res_orig['capacity'], res_orig['pos_v'], color=COLOR_POS, linestyle=':', linewidth=0.7)
    ax2.plot(res_orig['capacity'], res_orig['neg_v'], color=COLOR_NEG, linestyle=':', linewidth=0.7)

    ax1.plot(res['capacity'], res['pos_v'] - res['neg_v'],
             color=COLOR_FULL)
    ax1.plot(res_orig['capacity'], res_orig['pos_v'] - res_orig['neg_v'],
             color=COLOR_FULL, linestyle=':', linewidth=0.7)

#     ax1.set_xlabel('Capacity (Ah)')
    ax1.set_ylabel('Voltage (V)')
    ax1.set_xlim(xlims)
    ax1.set_ylim((2.6, 4.6))

    ax1.set_xticklabels([])

    ax2.tick_params(axis='y', colors=COLOR_NEG)
    ax2.yaxis.label.set_color(COLOR_NEG)
    ax2.spines["right"].set_edgecolor(COLOR_NEG)
    ax2.set_ylabel('Voltage vs Li/Li$^+$ (V)')
    ax2.set_ylim((0, 2.55))

#     metrics2 = compute_useful_metrics(res, target_soc - 0.00278)
#     plt.axvline(x=metrics2['absolute_cap_at_target_soc'], color=COLOR_REF)

#     plt.axvline(x=0, color=COLOR_REF)
#     plt.axvline(x=0 - 0.00278, color=COLOR_REF)

#     plt.legend([f'$\Delta$ Q$_\mathrm{{LLI}}$ = {shift_mah} mAh \n $x_{{100}}$ = {x0:.4f} \n $y_100$ = {y0:.4f} \n V$_\mathrm{{pos, 100\%SOC}}$ = {pos_v_at_100_soc :.3f} V'],
#                handlelength=0, frameon=False)
#     plt.title(f"""
#                 $\Delta$ Q$_\mathrm{{LLI}}$ = {shift_mah} mAh
#                 $x_{{100}}$ = {metrics['x0']:.4f}
#                 $y_{{100}}$ = {metrics['y0']:.4f}
#                 V$_\mathrm{{pos, 100\%SOC}}$ = {metrics['pos_v_at_100_soc'] :.3f} V
#                 """)
#     plt.title(f"$\Delta$ Q$_\mathrm{{LLI}}$ = {shift_mah} mAh \n V$_\mathrm{{pos, 100\%SOC}}$ = {metrics['pos_v_at_100_soc'] : .4f} V vs. Li/Li$^+$")

#     plt.legend([f'V$_\mathrm{{pos, 100\%SOC}}$: {metrics['pos_v_at_100_soc'] :.3f} V'],
#                handlelength=0, frameon=False)


#     plt.xlim((-0.01, 0.01))
#     plt.ylim((0.30, 0.34))

    # Make the resistance plot
    plt.subplot(2,1,2)
    plt.axvline(x=metrics['absolute_cap_at_target_soc'], color=COLOR_REF)
    plt.axvline(x=metrics_orig['absolute_cap_at_target_soc'], color=COLOR_REF, linestyle=':', linewidth=0.7)

    plt.plot(res['capacity'], res['pos_r'] * 1000, color=COLOR_POS)
    plt.plot(res_orig['capacity'], res_orig['pos_r'] * 1000, color=COLOR_POS, linestyle=':', linewidth=0.7)
    plt.plot(res['capacity'], res['neg_r'] * 1000, color=COLOR_NEG)
    plt.plot(res_orig['capacity'], res_orig['neg_r'] * 1000, color=COLOR_NEG, linestyle=':', linewidth=0.7)
    plt.plot(res['capacity'], (res['pos_r'] + res['neg_r']) * 1000, color=COLOR_FULL)
    plt.plot(res_orig['capacity'], (res_orig['pos_r'] + res_orig['neg_r']) * 1000, color=COLOR_FULL, linestyle=':', linewidth=0.7)

    # Put dots for the 5% SOC points
    plt.plot(metrics_orig['absolute_cap_at_target_soc'],
             metrics_orig['resistance_at_target_soc'] * 1000, marker='o', color=[0.5, 0.5, 0.5])
    plt.plot(metrics['absolute_cap_at_target_soc'],
             metrics['resistance_at_target_soc'] * 1000, marker='o', color='black')

    plt.xlabel('Capacity (Ah)')
    plt.ylabel('R$_{10s}$ (m$\Omega$)')
#     plt.legend([f'R$_{{10s,{target_soc*100}\%SOC}}$ = {resistance_at_target_soc * 1000 :.1f} m$\Omega$'],
#                handlelength=0, frameon=False)
    plt.xlim(xlims)
    plt.ylim((0, 55))
    plt.tight_layout()
