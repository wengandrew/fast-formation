import numpy as np
import pandas as pd
import yaml

from src.formation import FormationCell

paths = yaml.load(open('paths.yaml', 'r'), Loader=yaml.FullLoader)

PATH_OUTPUT = paths['outputs']
PATH_ESOH = paths['outputs'] + 'summary_esoh_table.csv'
PATH_CORR = paths['outputs'] + 'correlation_data.csv'
IDX_ESOH_FRESH_CYCLE = 3
IDX_ESOH_AGED_CYCLE = 56

def export_hppc_data(cellid):
    """
    Exports HPPC data for a given cellid
    """

    assert cellid > 0 and cellid <= 40

    formation_cell = FormationCell(cellid)

    res_list = formation_cell.process_diagnostic_hppc_data()

    for res in res_list:

        cycle_index = res['cycle_index']
        print(f'Exporting HPPC data for cell {cellid}, cycle {cycle_index}...')

        data = res['data']
        data.to_csv(f'hppc_data_cell_{cellid}_processed_cycle_{cycle_index}.csv')

        raw_pulses = res['raw_pulses']
        raw_pulses.to_csv(f'hppc_data_cell_{cellid}_raw_pulses_cycle_{cycle_index}.csv')

        raw_all = res['raw_all']
        raw_all.to_csv(f'hppc_data_cell_{cellid}_raw_all_cycle_{cycle_index}.csv')


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
        label_registry[f'dcr_1s_5_soc_at_c{idx}']  = (f'$R_{{1s, 5\% SOC}}$, c{idx} $(\\Omega)$', (0.025, 0.055))
        label_registry[f'dcr_10s_50_soc_at_c{idx}']  = (f'$R_{{10s, 50\% SOC}}$, c{idx} $(\\Omega)$', (0.025, 0.055))
        label_registry[f'dcr_10s_90_soc_at_c{idx}']  = (f'$R_{{10s, 90\% SOC}}$, c{idx} $(\\Omega)$', (0.025, 0.055))
        label_registry[f'dcr_10s_5_soc_at_c{idx}']  = (f'$R_{{10s, 5\% SOC}}$, c{idx} $(\\Omega)$', (0.025, 0.055))
        label_registry[f'dcr_10s_5_soc_at_c{idx}']  = (f'$R_{{10s, 5\% SOC}}$, c{idx} $(\\Omega)$', (0.025, 0.055))
        label_registry[f'dcr_10s_90_soc_at_c{idx}'] = (f'$R_{{10s, 90\% SOC}}$, c{idx} $(\\Omega)$', (None, None))
        label_registry[f'dcr_10s_0_soc_at_c{idx}']  = (f'$R_{{10s, 4\% SOC}}$, c{idx} $(\\Omega)$', (None, None))
        label_registry[f'dcr_10s_10_soc_at_c{idx}'] = (f'$R_{{10s, 10\% SOC}}$ c{idx} $(\\Omega)$', (None, None))
        label_registry[f'esoh_c{idx}_y0'] = (f'$y_{{0}}$, c{idx}', (None, None))
        label_registry[f'esoh_c{idx}_y100'] = (f'$y_{{100}}$, c{idx}', (None, None))
        label_registry[f'esoh_c{idx}_x0'] = (f'$x_{{0}}$, c{idx}', (None, None))
        label_registry[f'esoh_c{idx}_x100'] = (f'$x_{{100}}$, c{idx}', (None, None))

    # Disable showing cycle number in label if it's the 'first' cycle (c3)
    label_registry[f'dcr_10s_5_soc_at_c3']  = (f'$R_{{10s, 5\% SOC}}$ $(\\Omega)$', (0.025, 0.055))
    label_registry[f'dcr_1s_5_soc_at_c3']  = (f'$R_{{1s, 5\% SOC}}$ $(\\Omega)$', (0.025, 0.055))
    label_registry[f'dcr_10s_50_soc_at_c3']  = (f'$R_{{10s, 50\% SOC}}$ $(\\Omega)$', (0.025, 0.055))
    label_registry[f'dcr_10s_90_soc_at_c3']  = (f'$R_{{10s, 90\% SOC}}$ $(\\Omega)$', (0.025, 0.055))
    label_registry[f'dcr_10s_5_soc_at_c3']  = (f'$R_{{10s, 5\% SOC}}$ $(\\Omega)$', (0.025, 0.055))
    label_registry[f'dcr_10s_5_soc_at_c3']  = (f'$R_{{10s, 5\% SOC}}$ $(\\Omega)$', (0.025, 0.055))
    label_registry[f'dcr_10s_5_soc_at_c3_chg']  = (f'$R^{{\mathrm{{CHG}}}}_{{10s, 5\% SOC}}$ $(\\Omega)$', (0.025, 0.055))
    label_registry[f'dcr_10s_0_soc_at_c3_chg']  = (f'$R^{{\mathrm{{CHG}}}}_{{10s, 4\% SOC}}$ $(\\Omega)$', (0.025, 0.055))
    label_registry[f'dcr_10s_90_soc_at_c3'] = (f'$R_{{10s, 90\% SOC}}$ $(\\Omega)$', (None, None))
    label_registry[f'dcr_10s_0_soc_at_c3']  = (f'$R_{{10s, 4\% SOC}}$ $(\\Omega)$', (None, None))
    label_registry[f'dcr_10s_10_soc_at_c3'] = (f'$R_{{10s, 10\% SOC}}$ $(\\Omega)$', (None, None))
    label_registry[f'esoh_c3_y0'] = (f'$y_{{0}}$', (None, None))
    label_registry[f'esoh_c3_y100'] = (f'$y_{{100}}$', (None, None))
    label_registry[f'esoh_c3_x0'] = (f'$x_{{0}}$', (None, None))
    label_registry[f'esoh_c3_x100'] = (f'$x_{{100}}$', (None, None))


    for idx in cycle_target_list[1::]:
        label_registry[f'var_q_c20_c{idx}_c3_ah'] = (f'$Var(Q(V)), C/20, c{idx}-c3$ (mAh)', (0, 65))

    label_registry['var_q_1c_c100_c10_ah'] = ('Var(Q(V)), 1C, c100-c10 (Ah)', (None, None))
    label_registry['var_q_1c_c100_c10_mah'] = ('Var(Q(V)), 1C, c100-c10 (mAh)', (None, None))
    label_registry['cycles_to_80_pct'] = ('Cycles to 80%', (None, None))
    label_registry['cycles_to_70_pct'] = ('Cycles to 70%', (None, None))
    label_registry['cycles_to_60_pct'] = ('Cycles to 60%', (None, None))
    label_registry['cycles_to_50_pct'] = ('Cycles to 50%', (None, None))
    label_registry['thickness_mm'] = ('Thickness (mm)', (None, None))
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
    label_registry['form_last_charge_voltage_after_1s'] = ('Form last chg V, 1s', (None, None))
    label_registry['form_final_discharge_capacity_ah'] = ('$Q_\mathrm{d}$ (Ah)', (None, None))
    label_registry['form_first_charge_capacity_ah'] = ('$Q_\mathrm{c}$ (Ah)', (None, None))
    label_registry['form_first_discharge_capacity_below_3p2v_ah'] = ('$Q_d<3.2V (Ah)', (None, None))
    label_registry['form_qc_minus_qd_ah'] = ('$Q_\mathrm{LLI}$ (Ah)', (None, None))
    label_registry['form_coulombic_efficiency'] = ('$\mathrm{CE}_\mathrm{f}$', (None, None))
    label_registry['form_6hr_rest_mv_per_day_steady'] = ('$dV/dt_{ss}$ (mV/day)', (None, None))
    label_registry['form_first_cycle_efficiency'] = ('Form 1st Cyc Eff.', (None, None))
    label_registry['form_6hr_rest_delta_voltage_v'] = ('$\Delta V_{rest,6hr}$ (V)', (None, None))
    label_registry['rpt_c3_delta_v'] = ('$\Delta V_{1hr, RPT}, c3$ (V)', (None, None))

    return label_registry


def export_correlation_table(output_path=PATH_CORR):
    """
    Export the table of correlation features

    Parameters
    ---------
    output_path: path for saving file

    Returns
    ---------
    None
    """

    df = build_correlation_table()
    df.to_csv(f'{output_path}')


def build_correlation_table():
    """
    Build a table of correlation features. The compilation includes data from:
      - formation
      - cycling
      - eSOH metrics

    Parameters
    ---------
    None

    Returns
    ---------
    dataframe containing the table

    """

    formation_cells = []
    cellid_list = np.arange(1, 41)

    for cellid in cellid_list:
        formation_cells.append(FormationCell(cellid))

    all_summary_data = []

    for cell in formation_cells:

        if cell.cellid == 9:
            continue

        print(f'Working on compiling data on cell #{cell.cellid}...')

        curr_summary = dict()

        curr_summary['cellid'] = cell.cellid
        curr_summary['channel_number'] = cell.get_channel_number()
        curr_summary['is_room_temp_aging'] = 1 if cell.is_room_temp() else 0
        curr_summary['is_baseline_formation'] = 1 if cell.is_baseline_formation() else 0

        # Add information from the formation cycles
        curr_summary.update(cell.get_formation_test_summary_statistics())
        curr_summary['form_coulombic_efficiency'] = curr_summary['form_final_discharge_capacity_ah'] / curr_summary['form_first_charge_capacity_ah']
        curr_summary['form_qc_minus_qd_ah'] = curr_summary['form_first_charge_capacity_ah'] - curr_summary['form_final_discharge_capacity_ah']
        # Add the results from the aging test
        curr_summary.update(cell.get_aging_test_summary_statistics())

        # Add the 1-hour delta V measurements from the RPTs
        voltage_res_array = cell.process_diagnostic_4p2v_voltage_decay()
        for voltage_res in voltage_res_array:
            curr_summary[f'rpt_c{voltage_res["cycle_index"]}_delta_v'] = voltage_res['delta_voltage']

        # Add the eSOH fitting results for two different cycle numbers
        df_esoh = cell.get_esoh_fitting_results()
        esoh_common_cycles_arr = [3, 56, 159, 262, 365]
        for cyc_idx in esoh_common_cycles_arr:
            df_curr = df_esoh[df_esoh['cycle_number'] == cyc_idx].drop(columns=['cellid', 'cycle_number'])
            curr_summary.update(df_curr.add_prefix(f'esoh_c{cyc_idx}_').to_dict('records')[0])
            curr_summary[f'esoh_c{cyc_idx}_CnCp'] = curr_summary[f'esoh_c{cyc_idx}_Cn'] / curr_summary[f'esoh_c{cyc_idx}_Cp']

        curr_summary['is_plating'] = 1 if cell.is_plating() else 0
        curr_summary['swelling_severity'] = cell.get_swelling_severity()
        curr_summary['thickness_mm'] = cell.get_thickness()
        curr_summary['electrolyte_weight_g'] = cell.get_electrolyte_weight()

        all_summary_data.append(curr_summary)

    df_corr = pd.DataFrame(all_summary_data)

    return df_corr


if __name__ == "__main__":
    append_esoh_metrics_to_correlations_table()
