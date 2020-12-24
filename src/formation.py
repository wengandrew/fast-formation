import pytest
import ipdb
import pandas as pd
import glob
import numpy as np
from scipy.signal import savgol_filter
from matplotlib import pyplot as plt

PATH_CYCLE = 'data/2020-10-aging-test-cycles'
PATH_TIMESERIES = 'data/2020-10-aging-test-timeseries'
PATH_FORMATION = 'data/2020-06-microformation-timeseries'
PATH_METADATA = 'documents/cell_tracker.xlsx'

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


    def get_swelling_severity(self):
        """
        Return swelling severity metric for this cell
        """

        df = self.get_metadata()

        return df['swelling_rating']


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

        stats = dict()

        # Index for cycle containing the final discharge capacity
        CYCLE_INDEX_LAST = np.max(df['Cycle Number']) if self.is_baseline_formation() else np.max(df['Cycle Number']) - 1

        df_first_cycle = df[df['Cycle Number'] == 1]
        df_last_cycle = df[df['Cycle Number'] == CYCLE_INDEX_LAST]

        stats['form_first_charge_capacity_ah'] = np.max(df_first_cycle['Charge Capacity (Ah)'])
        stats['form_first_discharge_capacity_ah'] = np.max(df_first_cycle['Discharge Capacity (Ah)'])
        stats['form_first_cycle_efficiency'] = stats['form_first_discharge_capacity_ah'] / \
                                               stats['form_first_charge_capacity_ah']

        stats['form_final_discharge_capacity_ah'] = np.max(df_last_cycle['Discharge Capacity (Ah)'])

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
        delta_voltage = VOLTAGE_MAXIMUM - y_smoothed[-1]

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
        stats['form_6hr_rest_voltage_decay_v'] = delta_voltage
        stats['form_first_cv_hold_capacity_ah'] = cv_hold_capacity

        return stats


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

        hppc_stats = self.summarize_hppc_pulse_statistics()

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

        stats['cycles_to_50_pct'] = find_cycles_to_target_retention(capacity_retention, cyc_number, 0.5)
        stats['cycles_to_60_pct'] = find_cycles_to_target_retention(capacity_retention, cyc_number, 0.6)
        stats['cycles_to_70_pct'] = find_cycles_to_target_retention(capacity_retention, cyc_number, 0.7)
        stats['cycles_to_80_pct'] = find_cycles_to_target_retention(capacity_retention, cyc_number, 0.8)

        stats['initial_cell_dcr_0_soc'] = hppc_stats['dcr_soc_0'][0]
        stats['initial_cell_dcr_50_soc'] = hppc_stats['dcr_soc_50'][0]
        stats['initial_cell_dcr_100_soc'] = hppc_stats['dcr_soc_100'][0]

        stats['retention_at_c400'] = np.interp(400, cyc_number, capacity_retention)
        stats['dcr_0_soc_at_c400'] = np.interp(400, hppc_stats['cycle_index'], hppc_stats['dcr_soc_0'])
        stats['dcr_50_soc_at_c400'] = np.interp(400, hppc_stats['cycle_index'], hppc_stats['dcr_soc_50'])
        stats['dcr_100_soc_at_c400'] = np.interp(400, hppc_stats['cycle_index'], hppc_stats['dcr_soc_100'])


        return stats



    def summarize_hppc_pulse_statistics(self):
        """
        Returns a summary table of only the most relevant HPPC metrics,
        including DCR at 0%, 50% and 100% SOC

        Returns a DataFrame
        """

        results_list = self.process_diagnostic_hppc_data()

        stats = []
        for result in results_list:

            data = result['data']

            data.sort_values(by=['capacity'])

            dcr_soc_0 = data['resistance'].iloc[0]

            # The lowest SOC pulse runs into danger of hitting MinV before the
            # pulse is terminated. This will create a distortion in the signal
            # so make sure that this doesn't happen.
            assert data['duration_in_seconds'].iloc[0] > 9.9

            dcr_soc_100 = data['resistance'].iloc[-1]

            soc = data['capacity']/np.max(data['capacity'])

            dcr_soc_50 = np.interp(0.5, soc, data['resistance'])

            curr_result = dict()
            curr_result['cycle_index'] = result['cycle_index']
            curr_result['dcr_soc_0'] = dcr_soc_0
            curr_result['dcr_soc_50'] = dcr_soc_50
            curr_result['dcr_soc_100'] = dcr_soc_100

            stats.append(curr_result)

        stats = pd.DataFrame(stats)

        return stats


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

                    # Detect pulse end
                    voltage_1 = voltage_0
                    jdx = idx + 1
                    while True:
                        jdx += 1
                        if curr_df['Step Index'].iloc[jdx] != STEP_INDEX_HPPC_DISCHARGE:
                            voltage_1 = curr_df['Potential (V)'].iloc[jdx-1]
                            break

                    duration_in_seconds = curr_df['Test Time (s)'].iloc[jdx] - \
                                        curr_df['Test Time (s)'].iloc[idx]

                    current = np.abs(np.mean(curr_df['Current (A)'].iloc[idx:jdx]))
                    resistance = (voltage_0 - voltage_1)/current

                    result = dict()
                    result['capacity'] = capacity
                    result['voltage'] = voltage_0
                    result['resistance'] = resistance
                    result['current'] = current
                    result['duration_in_seconds'] = duration_in_seconds

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


"""
Driver code
"""

if __name__ == "__main__":

    cell = FormationCell(33)
    cell.summarize_hppc_pulse_statistics()
    cell.get_formation_test_summary_statistics()
    cell.get_metadata()
    cell.get_aging_test_summary_statistics()
