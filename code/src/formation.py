import pytest
import ipdb
import pandas as pd
import glob
import numpy as np
from scipy import interpolate
from scipy import stats
from scipy.signal import savgol_filter
from matplotlib import pyplot as plt

PATH_CYCLE = 'data/2020-10-aging-test-cycles'
PATH_TIMESERIES = 'data/2020-10-aging-test-timeseries'
PATH_FORMATION = 'data/2020-06-microformation-timeseries'
PATH_METADATA = 'documents/cell_tracker.xlsx'
PATH_ESOH = 'output/2021-03-fast-formation-esoh-fits/summary_esoh_table.csv'

STEP_INDEX_C3_CHARGE = 7
STEP_INDEX_C3_DISCHARGE = 10
STEP_INDEX_C20_CHARGE = 13
STEP_INDEX_C20_DISCHARGE = 16
STEP_INDEX_HPPC_CHARGE = 22
STEP_INDEX_HPPC_DISCHARGE = 24

# This is a fixed number for this experiment
NUM_TOTAL_CELLS = 40

class FormationCell:
    """
    Representation of a cell that has gone through formation cycles at the
    University of Michigan battery lab. This cell will have gone through a
    series of experiments and include data on formation, aging, dvdq, etc.
    """

    def __init__(self, cellid):

        self.cellid = cellid

        # Initialize DataFrames
        self._df_timeseries = pd.DataFrame()
        self._df_cycles = pd.DataFrame()
        self._df_formation = pd.DataFrame()
        self._df_esoh_fitting_results = pd.DataFrame()

        self._metadata_dict = dict()


    def get_metadata(self):
        """
        Returns metadata for this cell as a dict

        Returns:
          A dictionary holding cell metadata
        """

        if not bool(self._metadata_dict):
            self._load_metadata()

        return self._metadata_dict


    def _load_metadata(self):
        """
        Retrieve metadata for this cell

        Assigns data as object property
        """

        df = pd.read_excel(PATH_METADATA, engine="openpyxl")

        df = df[df['cell_number'] == self.cellid]

        self._metadata_dict = df.to_dict('records')[0]


    def is_baseline_formation(self):
        """
        Return true if this cell used the fast formation protocol
        """

        df = self.get_metadata()

        return df['formation_protocol'] == 'Baseline'


    def is_plating(self):
        """
        Has this cell plated lithium?
        """

        df = self.get_metadata()

        return df['li_plating_possibility'] == 1


    def get_electrolyte_weight(self):
        """
        Return electrolyte fill weight
        """

        df = self.get_metadata()

        return df['electrolyte_weight_g']


    def get_channel_number(self):
        """
        Returns the channel number associated with the cycling test
        """

        df = self.get_metadata()

        return df['channel_number']


    def get_swelling_severity(self):
        """
        Return swelling severity metric for this cell
        """

        df = self.get_metadata()

        return df['swelling_rating']

    def get_thickness(self):
        """
        Return measured cell thickness in mm
        """

        df = self.get_metadata()

        return df['thickness_mm']


    def is_room_temp(self):
        """
        Return True if cell went through room temperature aging
        """

        df = self.get_metadata()

        return df['aging_test'] == 'RT'


    def get_formation_data(self):
        """
        Retrieve data from the formation cycles

        Returns:
          A Pandas DataFrame
        """

        if self._df_formation.empty:
            self._load_formation_data()

        return self._df_formation


    def _load_formation_data(self):
        """
        Retrive timeseries data from formation test.

        Assigns data as object property
        """

        regex = f'UM_Internal_0620_*_{self.cellid}.*.csv'

        file = glob.glob(f'{PATH_FORMATION}/{regex}')

        assert len(file) == 1, f'More than one file associated with ' \
                               f'cell {self.cellid}'

        df = pd.read_csv(file[0])

        # Make cycle number start from 1, not 0, to follow standard convention
        df['Cycle Number'] +=1

        self._df_formation = df


    def get_aging_data_timeseries(self):
        """
        Get timeseries data with caching implementation
        """

        if self._df_timeseries.empty:
            self._load_aging_data_timeseries()

        return self._df_timeseries


    def _load_aging_data_timeseries(self):
        """
        Retrieve timeseries data from the aging test.

        Assigns data as object property
        """

        regex = f'UM_Internal_0620_*_Cycling_Cell_{self.cellid}.*.csv'

        file = glob.glob(f'{PATH_TIMESERIES}/{regex}')

        assert len(file) == 1, f'More than one file associated with ' \
                               f'cell {self.cellid}'

        df = pd.read_csv(file[0])

        df['Cycle Number'] += 1

        self._df_timeseries = df


    def _load_esoh_fitting_results(self):
        """
        Retrive pre-calculated results from the eSOH fitting
        """

        file = glob.glob(f'{PATH_ESOH}')

        df = pd.read_csv(file[0])
        df = df[(df['cellid'] == self.cellid)]

        self._df_esoh_fitting_results = df


    def get_esoh_fitting_results(self):
        """
        Get the eSOH fitting results with catching implementation
        """

        if self._df_esoh_fitting_results.empty:
            self._load_esoh_fitting_results()

        return self._df_esoh_fitting_results


    def get_aging_data_cycles(self):
        """
        Get aging data with caching implementation
        """

        if self._df_cycles.empty:
            self._load_aging_data_cycles()

        return self._df_cycles


    def _load_aging_data_cycles(self):
        """
        Retrieve data by cycles from the aging test

        Returns:
          A Pandas DataFrame
        """

        regex = f'UM_Internal_0620_*_Cell_{self.cellid}.*.csv'

        file = glob.glob(f'{PATH_CYCLE}/{regex}')

        assert len(file) == 1, f'More than one file associated with ' \
                               f'cell {self.cellid}'

        df = pd.read_csv(file[0])

        # Make cycle number start at 1 instead of 0
        df['Cycle Number'] += 1

        # Drop the last cycle since there's no guarantee that this cycle
        # finished
        df = df[:-1]

        self._df_cycles = df


    def export_diagnostic_c20_data(self):
        """
        Writes csv files to disk containing the raw C/20 voltage data
        """

        results = self.process_diagnostic_c20_data()

        for res in results:

            chg_output = pd.DataFrame({'chg_capacity': res['chg_capacity'],
                                       'chg_voltage': res['chg_voltage'],
                                       'chg_dvdq': res['chg_dvdq']})

            chg_output.to_csv(f'diagnostic_test_cell_{self.cellid}_'\
                          f'cyc_{res["cycle_index"]}_charge.csv')

            dch_output = pd.DataFrame({'dch_capacity': res['dch_capacity'],
                                       'dch_voltage': res['dch_voltage'],
                                       'dch_dvdq': res['dch_dvdq']})

            dch_output.to_csv(f'diagnostic_test_cell_{self.cellid}_'\
                            f'cyc_{res["cycle_index"]}_discharge.csv')


        print('Done.')


    def process_diagnostic_c3_data(self):
        """
        Filters out aging timeseries data to include only C/3 charge and
        discharge curves

        Returns:
          A list of dictionaries containing the results
        """

        df = self.get_aging_data_timeseries()

        df_c3_charge = df[df['Step Index'] == STEP_INDEX_C3_CHARGE]
        df_c3_discharge = df[df['Step Index'] == STEP_INDEX_C3_DISCHARGE]

        c3_test_cycle_indices = np.unique(df_c3_charge['Cycle Number'])

        results = []

        for idx_cyc in c3_test_cycle_indices:

            df_chg = df_c3_charge[df_c3_charge['Cycle Number'] == idx_cyc]
            df_dch = df_c3_discharge[df_c3_discharge['Cycle Number'] == idx_cyc]

            curr_dict = dict()

            curr_dict['cycle_index'] = idx_cyc
            curr_dict['chg_capacity'] = df_chg['Charge Capacity (Ah)']
            curr_dict['chg_voltage'] = df_chg['Potential (V)']
            curr_dict['chg_dvdq'] = 1/df_chg['dQ/dV (Ah/V)']
            curr_dict['dch_capacity'] = df_dch['Discharge Capacity (Ah)']
            curr_dict['dch_voltage'] = df_dch['Potential (V)']
            curr_dict['dch_dvdq'] = 1/df_dch['dQ/dV (Ah/V)']

            results.append(curr_dict)

        return results


    def process_diagnostic_c20_data(self):
        """
        Filters out aging timeseries data to include only C/20 charge and
        discharge curves

        Returns:
          A list of dictionaries containing the results
        """

        df = self.get_aging_data_timeseries()

        df_c20_charge = df[df['Step Index'] == STEP_INDEX_C20_CHARGE]
        df_c20_discharge = df[df['Step Index'] == STEP_INDEX_C20_DISCHARGE]

        c20_test_cycle_indices = np.unique(df_c20_charge['Cycle Number'])

        results = []

        for idx_cyc in c20_test_cycle_indices:

            df_chg = df_c20_charge[df_c20_charge['Cycle Number'] == idx_cyc]
            df_dch = df_c20_discharge[df_c20_discharge['Cycle Number'] == idx_cyc]

            curr_dict = dict()

            curr_dict['cycle_index'] = idx_cyc
            curr_dict['chg_capacity'] = df_chg['Charge Capacity (Ah)']
            curr_dict['chg_voltage'] = df_chg['Potential (V)']
            curr_dict['chg_dvdq'] = 1/df_chg['dQ/dV (Ah/V)']
            curr_dict['dch_capacity'] = df_dch['Discharge Capacity (Ah)']
            curr_dict['dch_voltage'] = df_dch['Potential (V)']
            curr_dict['dch_dvdq'] = 1/df_dch['dQ/dV (Ah/V)']

            results.append(curr_dict)

        return results


    def get_formation_test_summary_statistics(self):
        """
        Return summary statistics from the formation cycle
        """

        # First cycle efficiency
        # Final post-formation cell capacity

        df = self.get_formation_data()

        res_dict = dict()

        # Index for cycle containing the final discharge capacity
        # Work around some quirks due to schedule file differences
        CYCLE_INDEX_LAST = np.max(df['Cycle Number']) if self.is_baseline_formation() else np.max(df['Cycle Number']) - 1

        df_first_cycle = df[df['Cycle Number'] == 1]
        df_last_cycle = df[df['Cycle Number'] == CYCLE_INDEX_LAST]

        res_dict['form_first_charge_capacity_ah'] = np.max(df_first_cycle['Charge Capacity (Ah)'])
        res_dict['form_first_discharge_capacity_ah'] = np.max(df_first_cycle['Discharge Capacity (Ah)'])
        res_dict['form_first_cycle_efficiency'] = res_dict['form_first_discharge_capacity_ah'] / \
                                                  res_dict['form_first_charge_capacity_ah']

        res_dict['form_final_discharge_capacity_ah'] = np.max(df_last_cycle['Discharge Capacity (Ah)'])

        # Process voltage decay signal during 12-hour rest step
        STEP_INDEX_6HR_REST = 12 if self.is_baseline_formation() else 13
        CYCLE_INDEX_6HR_REST = 3 if self.is_baseline_formation() else 7
        VOLTAGE_MAXIMUM = 4.2

        df_6hr_rest = df[(df['Cycle Number'] == CYCLE_INDEX_6HR_REST) &
                         (df['Step Index'] == STEP_INDEX_6HR_REST)]

        x = df_6hr_rest['Step Time (s)']
        y = df_6hr_rest['Potential (V)']

        # Smooth the signal
        y_smoothed = savgol_filter(y, 41, 3)
        voltage_final = y_smoothed[-1]
        delta_voltage = VOLTAGE_MAXIMUM - voltage_final

        # Estimate steady-state dV/dt using data from the last two hours
        x_steady = x[x > 4 * 3600]
        y_steady = y_smoothed[x > 4 * 3600]
        volts_per_second = stats.linregress(x_steady, y_steady)[0]
        mv_per_day_steady = volts_per_second * 86400 * 1000

        # Estimate initial dV/dt using data from the first 15 minutes
        x_initial = x[x < 15 * 60]
        y_initial = y_smoothed[x < 15 * 60]
        volts_per_second = stats.linregress(x_initial, y_initial)[0]
        mv_per_sec_initial = volts_per_second * 1000

        # Sanity check
        # plt.figure()
        # plt.plot(x, y, x, y_smoothed)
        # plt.show()
        # plt.savefig('test.png')

        # Process current bump signal during first CV hold step
        STEP_INDEX_FIRST_CV_HOLD = 4 if self.is_baseline_formation() else 5
        CYCLE_INDEX_FIRST_CV_HOLD = 1 if self.is_baseline_formation() else 1
        df_first_cv_hold = df[(df['Cycle Number'] == CYCLE_INDEX_FIRST_CV_HOLD) &
                              (df['Step Index'] == STEP_INDEX_FIRST_CV_HOLD)]

        cv_hold_capacity = df_first_cv_hold['Charge Capacity (Ah)'].iloc[-1] - \
                           df_first_cv_hold['Charge Capacity (Ah)'].iloc[0]

        # Package the results
        res_dict['form_6hr_rest_delta_voltage_v'] = delta_voltage
        res_dict['form_6hr_rest_voltage_v'] = voltage_final
        res_dict['form_6hr_rest_mv_per_day_steady'] = mv_per_day_steady
        res_dict['form_6hr_rest_mv_per_sec_initial'] = mv_per_sec_initial
        res_dict['form_first_cv_hold_capacity_ah'] = cv_hold_capacity
        return res_dict


    def calculate_var_q(self, to_plot=False):
        """
        Compute the variance in Q metric as reported by Seversen et al. from the
        2019 Nature Energy paper.
        """

        CYC_DVDQ_FRESH = 3
        CYC_DVDQ_FIRST_AGED = 56
        result_list = self.process_diagnostic_c20_data()

        # Make sure the dataset consists of the same set of cycles. If this is
        # false, the analysis may still work but we need to be more careful
        # about how we index into the data. For now let's catch and fail exceptions.
        assert result_list[0]['cycle_index'] == CYC_DVDQ_FRESH
        assert result_list[1]['cycle_index'] == CYC_DVDQ_FIRST_AGED

        q0 = result_list[0]['dch_capacity']
        v0 = result_list[0]['dch_voltage']

        q1 = result_list[1]['dch_capacity']
        v1 = result_list[1]['dch_voltage']

        f0 = interpolate.interp1d(v0, q0, fill_value='extrapolate')
        f1 = interpolate.interp1d(v1, q1, fill_value='extrapolate')

        v_shared = np.linspace(4.2, 3.0, 250)
        q0_interp = f0(v_shared)
        q1_interp = f1(v_shared)

        delta_q = q0_interp - q1_interp
        var_q = np.var(delta_q)

        if to_plot:
            plt.figure()
            plt.plot(delta_q, v_shared)
            plt.xlabel('Capacity (Ah)')
            plt.ylabel('Voltage (V)')
            plt.title(f'Cell {self.cellid}')

            plt.savefig(f'output/debug/var_q_cell_{self.cellid}')

            print('VarQ figure has been exported.')

        return var_q


    def get_aging_test_summary_statistics(self):
        """
        Return summary statistics from the aging test
        """

        # indices representing initial cell capacity
        IDX_INIT_CAPACITY = np.arange(3, 8)
        stats = dict()

        df = self.get_aging_data_cycles()
        dch_capacity = df['Discharge Capacity (Ah)']
        cyc_number   = df['Cycle Number']

        (hppc_stats, dcr_soc_targets) = self.summarize_hppc_pulse_statistics()

        initial_capacity = np.mean(dch_capacity[IDX_INIT_CAPACITY])
        capacity_retention = dch_capacity/initial_capacity

        np.interp(0.5, capacity_retention, dch_capacity)

        stats['initial_capacity'] = np.mean(dch_capacity[IDX_INIT_CAPACITY])
        stats['initial_capacity_std'] = np.std(dch_capacity[IDX_INIT_CAPACITY])

        # Filter the capacity retention vs cycle number data to get a clean
        # interp here
        idx_bad = []

        for idx in range(len(capacity_retention) - 1):

            curr_capacity = capacity_retention[idx]
            next_capacity = capacity_retention[idx + 1]
            if next_capacity - curr_capacity > 0.2:

                idx_bad.append(idx)

                # Subsequent 3 cycles also belong to diagnostic tests
                for jdx in [1, 2, 3]:
                    if idx + jdx < len(capacity_retention) - 1:
                        idx_bad.append(idx + jdx)

        capacity_retention[idx_bad] = np.nan

        df = pd.Series(capacity_retention)
        capacity_retention = df.interpolate(method='linear').bfill().to_numpy()

        stats['var_q_56_3'] = self.calculate_var_q()

        # EOL metrics
        stats['cycles_to_50_pct'] = find_cycles_to_target_retention(capacity_retention, cyc_number, 0.5)
        stats['cycles_to_60_pct'] = find_cycles_to_target_retention(capacity_retention, cyc_number, 0.6)
        stats['cycles_to_70_pct'] = find_cycles_to_target_retention(capacity_retention, cyc_number, 0.7)
        stats['cycles_to_80_pct'] = find_cycles_to_target_retention(capacity_retention, cyc_number, 0.8)

        # Capacity retention and cell resistance at different cycle numbers
        # Cycle #3 corresponds to the first available cycle
        cycle_target_list = [3, 100, 200, 300, 350, 400, 450, 500]

        for cycle_target in cycle_target_list:

            curr_retention = np.interp(cycle_target, cyc_number, capacity_retention)
            stats[f'retention_at_c{cycle_target}'] = curr_retention

            # Loop through the different SOCs for DCRs
            for dcr_soc_target in dcr_soc_targets:

                dcr_soc_target_int = int(dcr_soc_target*100)
                curr_dcr_10s_soc = np.interp(cycle_target, hppc_stats['cycle_index'],
                                         hppc_stats[f'dcr_10s_soc_{dcr_soc_target_int}'])
                curr_dcr_3s_soc = np.interp(cycle_target, hppc_stats['cycle_index'],
                                         hppc_stats[f'dcr_3s_soc_{dcr_soc_target_int}'])
                curr_dcr_1s_soc = np.interp(cycle_target, hppc_stats['cycle_index'],
                                         hppc_stats[f'dcr_1s_soc_{dcr_soc_target_int}'])

                stats[f'dcr_10s_{dcr_soc_target_int}_soc_at_c{cycle_target}'] = curr_dcr_10s_soc
                stats[f'dcr_3s_{dcr_soc_target_int}_soc_at_c{cycle_target}'] = curr_dcr_3s_soc
                stats[f'dcr_1s_{dcr_soc_target_int}_soc_at_c{cycle_target}'] = curr_dcr_1s_soc

        return stats



    def summarize_hppc_pulse_statistics(self):
        """
        Returns a summary table of only the most relevant HPPC metrics,
        including DCR at 0%, 50% and 100% SOC

        Returns a tuple of (DataFrame, list of SOC targets)
        """

        results_list = self.process_diagnostic_hppc_data()

        stats = []
        for result in results_list:

            data = result['data']

            data.sort_values(by=['capacity'])

            soc_vec = data['capacity']/np.max(data['capacity'])

            curr_result = dict()
            curr_result['cycle_index'] = result['cycle_index']

            soc_target_list = np.array([0, 5, 7, 10, 15, 20, 30, 50, 70, 90, 100])/100

            for soc_target in soc_target_list:

                # Lowest DCR value is treated as 0% SOC
                if soc_target == 0:
                    curr_dcr_10s = data['resistance_10s_ohm'].iloc[0]
                    curr_dcr_3s = data['resistance_3s_ohm'].iloc[0]
                    curr_dcr_1s = data['resistance_1s_ohm'].iloc[0]
                # Highest DCR value is treated as 100% SOC
                elif soc_target == 1:
                    curr_dcr_10s = data['resistance_10s_ohm'].iloc[-1]
                    curr_dcr_3s = data['resistance_3s_ohm'].iloc[-1]
                    curr_dcr_1s = data['resistance_1s_ohm'].iloc[-1]
                # Midpoints are calculated explicitly using interpolation
                else:
                    curr_dcr_10s = np.interp(soc_target, soc_vec, data['resistance_10s_ohm'])
                    curr_dcr_3s = np.interp(soc_target, soc_vec, data['resistance_3s_ohm'])
                    curr_dcr_1s = np.interp(soc_target, soc_vec, data['resistance_1s_ohm'])

                curr_result[f'dcr_10s_soc_{int(soc_target*100)}'] = curr_dcr_10s
                curr_result[f'dcr_3s_soc_{int(soc_target*100)}'] = curr_dcr_3s
                curr_result[f'dcr_1s_soc_{int(soc_target*100)}'] = curr_dcr_1s

            stats.append(curr_result)

        stats = pd.DataFrame(stats)

        return (stats, soc_target_list)


    def process_diagnostic_hppc_data(self):
        """
        Takes in raw data and returns a data structure holding processed
        HPPC pulse information; uses step indices to infer start and end of each
        pulse.

        Returns a list of dictionaries. Each dictionary holds:
          - key: cycle index containing the HPPC cycle
          - value: a Pandas DataFrame
        """

        df = self.get_aging_data_timeseries()

        df_hppc = df[df['Step Index'] == STEP_INDEX_HPPC_DISCHARGE]
        hppc_cycle_indices = np.unique(df_hppc['Cycle Number'])

        results_list = list()

        # Loop through each diagnostic test
        for curr_cyc in hppc_cycle_indices:

            curr_df = df[df['Cycle Number'] == curr_cyc]

            # Process each pulse
            pulse_list = []
            for idx, point in enumerate(curr_df['Step Index'].values):

                if idx == 0:
                    continue

                # Detect pulse start
                if point == STEP_INDEX_HPPC_DISCHARGE \
                    and curr_df['Step Index'].iloc[idx-1] != STEP_INDEX_HPPC_DISCHARGE:

                    capacity = curr_df['Charge Capacity (Ah)'].iloc[idx-1]
                    voltage_0 = curr_df['Potential (V)'].iloc[idx-1]

                    # Detect index corresponding to end of pulse
                    jdx = idx + 1
                    while True:
                        jdx += 1
                        if curr_df['Step Index'].iloc[jdx] != STEP_INDEX_HPPC_DISCHARGE:
                            break

                    # Extract, voltage-current-time vector for this pulse
                    voltage_vec = curr_df['Potential (V)'].iloc[idx:jdx]
                    current_vec = curr_df['Current (A)'].iloc[idx:jdx]
                    time_vec = curr_df['Test Time (s)'].iloc[idx:jdx] - \
                               curr_df['Test Time (s)'].iloc[idx]

                    # Pulses that did not last 10 seconds could indicate a fault
                    # in the test. We want to code to fail a this point so we
                    # can look more carefully at what is going on.
                    assert (np.abs(time_vec.iloc[-1] - 10) < 0.1), \
                        "Pulse did not last 10 seconds."

                    voltage_at_1_sec  = np.interp(1, time_vec, voltage_vec)
                    voltage_at_3_sec  = np.interp(3, time_vec, voltage_vec)
                    voltage_at_10_sec = np.interp(10, time_vec, voltage_vec, right=voltage_vec.iloc[-1])

                    # Use the mean current throughout the pulse to reduce noise
                    current_mean = np.abs(np.mean(current_vec))

                    result = dict()
                    result['capacity'] = capacity
                    result['voltage'] = voltage_0
                    result['resistance_1s_ohm']  = (voltage_0 - voltage_at_1_sec) / current_mean
                    result['resistance_3s_ohm']  = (voltage_0 - voltage_at_3_sec) / current_mean
                    result['resistance_10s_ohm'] = (voltage_0 - voltage_at_10_sec) / current_mean
                    result['current'] = current_mean

                    pulse_list.append(result)


            curr_result = dict()
            curr_result['cycle_index'] = curr_cyc
            curr_result['data'] = pd.DataFrame(pulse_list)

            results_list.append(curr_result)

        return results_list


    def __str__(self):

        return f'Formation Cell {self.cellid}'


"""
Helper Functions
"""

def export_all_c20_data():
    """
    Dumps all C/20 charge and discharge data into the current directory.
    """

    for cellid in range(1, NUM_TOTAL_CELLS + 1):
        print(f'Working on cell {cellid}...')
        cell = FormationCell(cellid)
        cell.export_diagnostic_c20_data()


def find_cycles_to_target_retention(retention, cyc_number, target_retention):
    """
    Returns first cycle to go below target retention

    Args:
      cyc_number (integer)
      retention (0-1), capacity retention (capacity / initial capacity)
      target_retention (0-1)

    Returns:
      returns a cycle number (integer)
    """

    if min(retention) > target_retention:
        return np.nan

    return cyc_number[np.where(retention < target_retention)[0][0]]



if __name__ == "__main__":

    # Simple test cases
    cell = FormationCell(36)
    cell.calculate_var_q()
    cell.summarize_hppc_pulse_statistics()
    cell.get_formation_test_summary_statistics()
    cell.get_metadata()
