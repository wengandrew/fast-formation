import pytest
import ipdb
import pandas as pd
import glob
import numpy as np

PATH_CYCLE = r'/Users/aweng/Google Drive File Stream/My Drive/' \
              'formation/data/2020-10-aging-test-cycles'
PATH_TIMESERIES = r'/Users/aweng/Google Drive File Stream/My Drive/' \
                   'formation/data/2020-10-aging-test-timeseries'
PATH_METADATA = []

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

        # Initialize these dataframes only
        self._df_timeseries = []
        self._df_cycles = []


    def get_cell_metadata(self):
        """
        Returns metadata for this cell as a dict

        Returns:
          A dictionary holding cell metadata
        """

        pass


    def get_formation_data_timeseries(self):
        """
        Retrieve data from the formation cycles

        Returns:
          A Pandas DataFrame
        """

        return 0

    def get_aging_data_timeseries(self):
        """
        Get timeseries data with caching implementation
        """

        if not self._df_timeseries:
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

        if self._df_cycles == []:
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

        pass


    def get_aging_test_summary_statistics(self):
        """
        Return summary statistics from the aging test
        """

        stats = dict()

        df = self.get_aging_data_cycles()
        dch_capacity = df['Discharge Capacity (Ah)']
        cyc_number   = df['Cycle Number']

        hppc_stats = self.summarize_hppc_pulse_statistics()

        initial_capacity = np.mean(dch_capacity[4:7])
        capacity_retention = dch_capacity/initial_capacity

        np.interp(0.5, capacity_retention, dch_capacity)

        stats['initial_capacity'] = np.mean(dch_capacity[4:7])
        stats['initial_capacity_std'] = np.std(dch_capacity[4:7])

        stats['cycles_to_50_pct'] = np.interp(0.5, capacity_retention, cyc_number)
        stats['cycles_to_60_pct'] = np.interp(0.6, capacity_retention, cyc_number)
        stats['cycles_to_70_pct'] = np.interp(0.7, capacity_retention, cyc_number)
        stats['cycles_to_80_pct'] = np.interp(0.8, capacity_retention, cyc_number)

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


    def __print__(self):

        print(f'Cell {self.cellid}')


def export_all_c20_data():
    """
    Dumps all C/20 charge and discharge data into the current directory.
    """

    for cellid in range(1, NUM_TOTAL_CELLS+1):
        print(f'Working on cell {cellid}...')
        cell = FormationCell(cellid)
        cell.export_diagnostic_c20_data()



if __name__ == "__main__":

    cell = FormationCell(1)
    cell.get_aging_test_summary_statistics()

