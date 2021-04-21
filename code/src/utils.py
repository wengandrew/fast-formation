import numpy as np
import pandas as pd
import ipdb

PATH_OUTPUT = 'output'
PATH_ESOH = 'output/2020-10-esoh-results-summary/y100-fix/summary_esoh_table.csv'
PATH_CORR = 'output/correlation_data.csv'

IDX_ESOH_FRESH_CYCLE = 3
IDX_ESOH_AGED_CYCLE = 56

def append_esoh_metrics_to_correlations_table():
    """
    Take eSOH metrics and append it to the correlations table. Save a new
    correlations table
    """

    df_esoh = pd.read_csv(PATH_ESOH)
    df_corr = pd.read_csv(PATH_CORR)

    df_esoh_fresh = df_esoh[df_esoh['cycle_number'] == IDX_ESOH_FRESH_CYCLE]
    df_esoh_fresh = df_esoh_fresh.add_suffix(f'_c{IDX_ESOH_FRESH_CYCLE}')
    df_esoh_aged = df_esoh[df_esoh['cycle_number'] == IDX_ESOH_AGED_CYCLE]
    df_esoh_aged = df_esoh_aged.add_suffix(f'_c{IDX_ESOH_AGED_CYCLE}')

    df_merged_1 = pd.merge(df_corr, df_esoh_fresh,
                    how='left', left_on='cellid', right_on=f'cellid_c{IDX_ESOH_FRESH_CYCLE}')
    df_merged_2 = pd.merge(df_merged_1, df_esoh_aged,
                    how='left', left_on='cellid', right_on=f'cellid_c{IDX_ESOH_AGED_CYCLE}')

    df_merged_2.to_csv(f'{PATH_OUTPUT}/correlation_data_with_esoh.csv')

    print('Export complete.')


def get_label_registry():
    """
    Returns a dictionary containing labels
    """

    # Values are a tuple containing:
    # - label (str)
    # - axis limits (tuple)

    label_registry = dict()

    cycle_target_list = [3, 50, 56, 100, 150, 159, 200, 250, 262, 300, 350, 365, 400, 450]

    for idx in cycle_target_list:
        label_registry[f'dcr_10s_5_soc_at_c{idx}']  = (f'$R_{{10s, 5\% SOC}}$, c{idx} $(\\Omega)$', (0.025, 0.055))
        label_registry[f'dcr_10s_5_soc_at_c{idx}']  = (f'$R_{{10s, 5\% SOC}}$, c{idx} $(\\Omega)$', (0.025, 0.055))
        label_registry[f'dcr_10s_5_soc_at_c{idx}']  = (f'$R_{{10s, 5\% SOC}}$, c{idx} $(\\Omega)$', (0.025, 0.055))
        label_registry[f'dcr_10s_5_soc_at_c{idx}']  = (f'$R_{{10s, 5\% SOC}}$, c{idx} $(\\Omega)$', (0.025, 0.055))
        label_registry[f'dcr_10s_5_soc_at_c{idx}']  = (f'$R_{{10s, 5\% SOC}}$, c{idx} $(\\Omega)$', (0.025, 0.055))
        label_registry[f'dcr_10s_90_soc_at_c{idx}'] = (f'$R_{{10s, 90\% SOC}}$, c{idx} $(\\Omega)$', (None, None))
        label_registry[f'dcr_10s_0_soc_at_c{idx}']  = (f'$R_{{10s, 4\% SOC}}$, c{idx} $(\\Omega)$', (None, None))
        label_registry[f'dcr_10s_10_soc_at_c{idx}'] = (f'$R_{{10s, 10\% SOC}}$ c{idx} $(\\Omega)$', (None, None))

    for idx in cycle_target_list[1::]:
        label_registry[f'var_q_c{idx}_c3'] = (f'$\\Delta Q, c{idx}-c3$ (mAh)', (0, 65))

    label_registry[f'cycles_to_70_pct'] = ('Cycles to 70%', (None, None))
    label_registry['cycles_to_80_pct'] = ('Cycles to 80%', (None, None))
    label_registry['esoh_c3_Cn'] = ('$C_n$, c3 (Ah)', (1.9, 3.0))
    label_registry['esoh_c56_Cn'] = ('$C_n$, c56 (Ah)', (1.9, 3.0))
    label_registry['esoh_c159_Cn'] = ('$C_n$, c159 (Ah)', (1.9, 3.0))
    label_registry['esoh_c262_Cn'] = ('$C_n$, c262 (Ah)', (1.9, 3.0))
    label_registry['esoh_c365_Cn'] = ('$C_n$, c365 (Ah)', (1.9, 3.0))
    label_registry['esoh_c3_CnCp'] = ('$C_n/C_p$, c3 (Ah)', (0.9, 1.1))
    label_registry['esoh_c56_CnCp'] = ('$C_n/C_p$, c56 (Ah)', (0.9, 1.1))
    label_registry['esoh_c159_CnCp'] = ('$C_n/C_p$, c159 (Ah)', (0.9, 1.1))
    label_registry['esoh_c262_CnCp'] = ('$C_n/C_p$, c262 (Ah)', (0.9, 1.1))
    label_registry['esoh_c365_CnCp'] = ('$C_n/C_p$, c365 (Ah)', (0.9, 1.1))
    label_registry['esoh_c3_neg_excess'] = ('Neg Excess, c3 (Ah)', (0.2, 0.7))
    label_registry['esoh_c56_neg_excess'] = ('Neg Excess, c56 (Ah)', (0.2, 0.7))
    label_registry['esoh_c159_neg_excess'] = ('Neg Excess, c159 (Ah)', (0.2, 0.7))
    label_registry['esoh_c262_neg_excess'] = ('Neg Excess, c262 (Ah)', (0.2, 0.7))
    label_registry['esoh_c365_neg_excess'] = ('Neg Excess, c365 (Ah)', (0.2, 0.7))
    label_registry['form_final_discharge_capacity_ah'] = ('$Q_d$ (Ah)', (None, None))
    label_registry['form_coulombic_efficiency'] = ('$CE_f$', (None, None))
    label_registry['form_6hr_rest_mv_per_day_steady'] = ('$dV/dt_{ss}$ (mV/day)', (None, None))
    label_registry['form_6hr_rest_delta_voltage_v'] = ('$\Delta V_{rest,6hr}$ (V)', (None, None))
    label_registry['rpt_c3_delta_v'] = ('$\Delta V_{1hr, RPT}, c3$ (V)', (None, None))

    return label_registry


if __name__ == "__main__":
    append_esoh_metrics_to_correlations_table()
