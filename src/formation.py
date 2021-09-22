import glob
import numpy as np
import json, yaml
import pandas as pd
import natsort
from matplotlib import pyplot as plt
from scipy import interpolate, stats
from scipy.signal import find_peaks, savgol_filter

# Configure paths
paths = yaml.load(open('paths.yaml', 'r'), Loader=yaml.FullLoader)

PATH_CYCLE      = paths['data'] + '2020-10-aging-test-cycles'
PATH_TIMESERIES = paths['data'] + '2020-10-aging-test-timeseries'
PATH_FORMATION  = paths['data'] + '2020-06-microformation-timeseries'
PATH_METADATA   = paths['documents'] + 'cell_tracker.xlsx'
PATH_ESOH_SUMMARY = paths['outputs'] + 'summary_esoh_table.csv'
PATH_ESOH_DATA = paths['outputs'] + '2021-04-12-formation-esoh-fits'

# Configure step indices during cycling RPTs
STEP_INDEX_C3_CHARGE = 7
STEP_INDEX_C3_DISCHARGE = 10
STEP_INDEX_C20_CHARGE = 13
STEP_INDEX_C20_DISCHARGE = 16
STEP_INDEX_HPPC_CHARGE = 22
STEP_INDEX_HPPC_DISCHARGE = 24

# Configure step indices during cycling 1C charge-discharges
STEP_INDEX_CYCLING_CHARGE_CC = 30
STEP_INDEX_CYCLING_CHARGE_CV = 31
STEP_INDEX_CYCLING_CHARGE_REST = 32
STEP_INDEX_CYCLING_DISCHARGE_CC = 33
STEP_INDEX_CYCLING_DISCHARGE_REST = 34

# Configure step indices during formation
STEP_INDEX_FORMATION_C20_CHARGE_BASELINE = 10
STEP_INDEX_FORMATION_C20_DISCHARGE_BASELINE = 13
STEP_INDEX_FORMATION_C20_CHARGE_FAST = 11
STEP_INDEX_FORMATION_C20_DISCHARGE_FAST = 14
STEP_INDEX_FORMATION_FIRST_DISCHARGE_BASELINE = 6
STEP_INDEX_FORMATION_FIRST_DISCHARGE_FAST = 9
STEP_INDEX_FORMATION_FIRST_DISCHARGE_REST_BASELINE = 7
STEP_INDEX_FORMATION_FIRST_DISCHARGE_REST_FAST = [] # Does not exist

# This is a fixed number for this experiment
NUM_TOTAL_CELLS = 40
NOM_CAP_AH = 2.36 # Nominal cell capacity in Amp-hours

class FormationCell:
    """
    Representation of a cell that has gone through formation cycles at the
    University of Michigan battery lab.

    This cell will have gone through a series of experiments and include data
    during formation and during the cycle test.

    This class handles ingestion of all relevant datasets and provides methods
    to process and summarize key features from each part of the test.
    """

    def __init__(self, cellid):

        self.cellid = cellid

        # Initialize DataFrames
        self._df_timeseries = pd.DataFrame()
        self._df_cycles = pd.DataFrame()
        self._df_formation = pd.DataFrame()
        self._df_esoh_fitting_results = pd.DataFrame()

        # Initialize dictionaries
        self._metadata_dict = dict()


    def __repr__(self):
        """
        Returns a string representation of the object"""

        if self.is_baseline_formation():
            formation_type = 'Baseline Formation'
        else:
            formation_type = 'Fast Formation'

        if self.is_room_temp():
            temperature_type = 'Room Temp'
        else:
            temperature_type = '45C'

        return f"Cell {self.cellid}, {formation_type}, {temperature_type}"


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

        assert len(file) == 1, f'File is missing or more than one file ' \
                               f'is associated with cell {self.cellid}. ' \
                               f'Check "{PATH_FORMATION}/{regex}"'

        df = pd.read_csv(file[0])

        # Make cycle number start from 1, not 0, to follow standard convention
        df['Cycle Number'] += 1

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
        Retrive pre-calculated summary results from the eSOH fitting
        """

        file = glob.glob(f'{PATH_ESOH_SUMMARY}')

        df = pd.read_csv(file[0])
        df = df[(df['cellid'] == self.cellid)]

        self._df_esoh_fitting_results = df


    def get_esoh_fitting_data(self):
        """
        Retrieve raw data from the eSOH fits

        Returns:
          - A list of dictionaries. Each dictionary holds
        """

        # Load in the json files
        file_list = glob.glob(f'{PATH_ESOH_DATA}/cell_{self.cellid}_*.json')

        file_list = natsort.natsorted(file_list)

        data_list = []

        for file in file_list:

            with open(file) as f:
                data = json.load(f)
                data['cycle_index'] = float(file.split('/')[-1]
                                                .split('_')[-1]
                                                .split('.')[0])
                data_list.append(data)

        return data_list


    def get_esoh_fitting_results(self):
        """
        Get the eSOH fitting summary results with caching implementation
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


    def get_aging_data_discharge_curve(self, cycle_index):
        """
        Return discharge voltage curve for a particular cycle index

        Args:
           cycle index (int):

        Returns:
           Pandas DataFrame containing only the data for this cycle
        """

        df = self.get_aging_data_timeseries()

        df = df[ (df['Cycle Number'] == cycle_index) & \
                 (df['Step Index'] == STEP_INDEX_CYCLING_DISCHARGE_CC) ]

        assert not df.empty, f'No data found for cycle index {cycle_index}'

        return df


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
            curr_dict['chg_capacity'] = df_chg['Charge Capacity (Ah)'].astype('float')
            curr_dict['chg_voltage'] = df_chg['Potential (V)'].astype('float')
            curr_dict['chg_dvdq'] = 1/df_chg['dQ/dV (Ah/V)'].astype('float')
            curr_dict['dch_capacity'] = df_dch['Discharge Capacity (Ah)'].astype('float')
            curr_dict['dch_voltage'] = df_dch['Potential (V)'].astype('float')
            curr_dict['dch_dvdq'] = 1/df_dch['dQ/dV (Ah/V)'].astype('float')

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


    def get_formation_test_final_c20_charge(self):
        """
        Return DataFrame for the final C/20 charge from the formation test
        """

        df = self.get_formation_data()

        if self.is_baseline_formation():
            CYCLE_INDEX_LAST = np.max(df['Cycle Number'])
            step_index_c20_charge = STEP_INDEX_FORMATION_C20_CHARGE_BASELINE
        else:
            CYCLE_INDEX_LAST = np.max(df['Cycle Number']) - 1
            step_index_c20_charge = STEP_INDEX_FORMATION_C20_CHARGE_FAST

        df_c20_charge = df[(df['Cycle Number'] == CYCLE_INDEX_LAST) &
                           (df['Step Index'] == step_index_c20_charge)]


        return df_c20_charge


    def get_formation_test_final_c20_charge_qpp(self, to_plot=False):
        """
        Return peak to peak capacity corresponding to the final C/20 charge from
        the formation test. Implement some sort of peak finding algorithm to do
        this.

        Returns a tuple:
          capacity_peak_to_peak_ah: peak to peak capacity in Ah
          right_peak_height_v_per_ah: height of the right peak. This might be
                                      some indicator of SEI uniformity?

        """

        df = self.get_formation_test_final_c20_charge()

        capacity = df['Charge Capacity (Ah)'].values
        voltage = df['Potential (V)'].values

        # Exclude values above 1.5Ah from this analysis.
        to_keep = capacity < 1.25
        voltage = voltage[to_keep]
        capacity = capacity[to_keep]

        dvdq = np.gradient(voltage)/np.gradient(capacity)

        dvdq_smoothed = savgol_filter(dvdq, 5, 3)

        idx_peaks, properties = find_peaks(dvdq_smoothed, height=0.35, prominence=0.005)


        # Discard first if there are three peaks
        if len(idx_peaks) == 3:
            idx_peaks = idx_peaks[1::]
            properties['peak_heights'] = properties['peak_heights'][1::]

        assert len(idx_peaks) == 2, "Too many peaks found."

        capacity_peak_to_peak_ah = capacity[idx_peaks[-1]] - capacity[idx_peaks[0]]

        assert capacity_peak_to_peak_ah > 0, "Something went wrong with the peak indexing."

        if to_plot:
            plt.figure()
            plt.plot(capacity, dvdq_smoothed)
            plt.plot(capacity[idx_peaks], dvdq_smoothed[idx_peaks], 'o')
            plt.ylim((0.1, 0.7))
            plt.xlabel('Charge Capacity (Ah)')
            plt.ylabel('dV/dQ (V/Ah)')
            plt.savefig(f'qpp_cell_{self.cellid}.png')
            plt.close()

        right_peak_height_v_per_ah = properties['peak_heights'][-1]

        return capacity_peak_to_peak_ah, right_peak_height_v_per_ah


    def get_formation_test_final_c20_discharge(self):
        """
        Return DataFrame for the final C/20 discharge from the formation test
        """

        df = self.get_formation_data()

        if self.is_baseline_formation():
            CYCLE_INDEX_LAST = np.max(df['Cycle Number'])
            step_index_c20_discharge = STEP_INDEX_FORMATION_C20_DISCHARGE_BASELINE
        else:
            CYCLE_INDEX_LAST = np.max(df['Cycle Number']) - 1
            step_index_c20_discharge = STEP_INDEX_FORMATION_C20_DISCHARGE_FAST

        df_c20_discharge = df[(df['Cycle Number'] == CYCLE_INDEX_LAST) &
                              (df['Step Index'] == step_index_c20_discharge)]

        return df_c20_discharge



    def get_formation_test_summary_statistics(self):
        """
        Return summary statistics from the formation cycle
        """

        df = self.get_formation_data()

        res_dict = dict()

        # Index for cycle containing the final discharge capacity
        # Work around some quirks due to schedule file differences
        if self.is_baseline_formation():
            CYCLE_INDEX_LAST = np.max(df['Cycle Number'])
            step_index_c20_charge = STEP_INDEX_FORMATION_C20_CHARGE_BASELINE
            step_index_first_discharge = STEP_INDEX_FORMATION_FIRST_DISCHARGE_BASELINE
            step_index_first_discharge_rest = STEP_INDEX_FORMATION_FIRST_DISCHARGE_REST_BASELINE
        else:
            CYCLE_INDEX_LAST = np.max(df['Cycle Number']) - 1
            step_index_c20_charge = STEP_INDEX_FORMATION_C20_CHARGE_FAST
            step_index_first_discharge = STEP_INDEX_FORMATION_FIRST_DISCHARGE_FAST
            step_index_first_discharge_rest = STEP_INDEX_FORMATION_FIRST_DISCHARGE_REST_FAST

        df_first_cycle = df[df['Cycle Number'] == 1]
        df_last_cycle = df[df['Cycle Number'] == CYCLE_INDEX_LAST]

        df_c20_charge = df[(df['Cycle Number'] == CYCLE_INDEX_LAST) &
                           (df['Step Index'] == step_index_c20_charge)]

        df_first_discharge = df[(df['Step Index'] == step_index_first_discharge)]

        # Extract "capacity below 3.2V" metric as a proxy to low-SOC resistance
        idx_below_3p2v = np.where(df_first_discharge['Potential (V)'] < 3.2)[0]
        cap_vec_below_3p2v = df_first_discharge['Discharge Capacity (Ah)'].iloc[idx_below_3p2v]

        # (*) : different between baseline and fast formation
        # (+) : probably comparable between baseline and fast formation

        # (*) DEF: pseudo-capacity below 3.2V during first discharge (proxy for low-SOC resistance)
        res_dict['form_first_discharge_capacity_below_3p2v_ah'] = cap_vec_below_3p2v.iloc[-1] - cap_vec_below_3p2v.iloc[0]

        # Extract "voltage rebound after initial discharge" as a proxy to low-SOC resistance
        if step_index_first_discharge_rest:
            df_first_discharge_rest = df[(df['Step Index'] == step_index_first_discharge_rest) &
                                         (df['Cycle Number'] == 1)]

            rest_voltage_arr = df_first_discharge_rest['Potential (V)']
            rest_time_arr = df_first_discharge_rest['Step Time (s)']

            first_discharge_rest_interpolant = interpolate.interp1d(rest_time_arr, rest_voltage_arr)

            # (*) DEF: Voltage rebound after initial discharge, 1 second
            res_dict['form_first_discharge_rest_voltage_rebound_1s'] = first_discharge_rest_interpolant(1).tolist()

            # (*) DEF: Voltage rebound after initial discharge, 10 seconds
            res_dict['form_first_discharge_rest_voltage_rebound_10s'] = first_discharge_rest_interpolant(10).tolist()

            # (*) DEF: Voltage rebound after initial discharge, 30 minutes
            res_dict['form_first_discharge_rest_voltage_rebound_1800s'] = first_discharge_rest_interpolant(1800).tolist()

        else:
            # No data! Return empty
            res_dict['form_first_discharge_rest_voltage_rebound_1s'] = np.nan
            res_dict['form_first_discharge_rest_voltage_rebound_10s'] = np.nan
            res_dict['form_first_discharge_rest_voltage_rebound_1800s'] = np.nan

        # Extract voltage trace from the top of the C/10 charge preceding the
        # 6-hour voltage decay. PAttia suggested using the shape of this curve
        # to determine if the voltage decay is related to shifts in the voltage
        # curve, e.g. due to relative stoic realignment between positive and
        # negative electrode.
        MIN_VOLTAGE = 4.1
        c20_charge_voltage_end_vec = df_c20_charge['Potential (V)'][df_c20_charge['Potential (V)'] > MIN_VOLTAGE]
        c20_charge_capacity_end_vec = df_c20_charge['Charge Capacity (Ah)'][df_c20_charge['Potential (V)'] > MIN_VOLTAGE]

        # (*) DEF: (Q, V) data-series from the C/10 charge curve preceding the 6-hour voltage decay
        res_dict['form_last_charge_voltage_trace_cap_ah'] = c20_charge_capacity_end_vec
        res_dict['form_last_charge_voltage_trace_voltage_v'] = c20_charge_voltage_end_vec

        # Try to get the "10s resistance" from the C/20 charge step. This is a
        # pseudo-resistance since there is no real rest here and the preceding
        # step includes a bunch of voltage polarization. But this is the best we
        # might be able to do.
        voltage_interpolant = interpolate.interp1d(df_c20_charge['Step Time (s)'],
                                                   df_c20_charge['Potential (V)'])

        # (*) DEF: Voltage after 1s of charging at C/10 from 0% SOC (pseudo-resistance)
        res_dict['form_last_charge_voltage_after_1s'] = voltage_interpolant(1).tolist()

        # (*) DEF: Voltage after 10s of charging at C/10 from 0% SOC (pseudo-resistance)
        res_dict['form_last_charge_voltage_after_10s'] = voltage_interpolant(10).tolist()

        # (*) DEF: Voltage after 60s of charging at C/10 from 0% SOC (pseudo-resistance)
        res_dict['form_last_charge_voltage_after_60s'] = voltage_interpolant(60).tolist()

        # More aggregate variables

        # (*) DEF: Charge capacity of the very first cycle (Ah)
        res_dict['form_first_charge_capacity_ah'] = np.max(df_first_cycle['Charge Capacity (Ah)'])

        # (*) DEF: Discharge capacity of the very first cycle (Ah)
        res_dict['form_first_discharge_capacity_ah'] = np.max(df_first_cycle['Discharge Capacity (Ah)'])

        # (*) DEF: Ratio of charge and discharge capacity for the very first cycle
        res_dict['form_first_cycle_efficiency'] = res_dict['form_first_discharge_capacity_ah'] / \
                                                  res_dict['form_first_charge_capacity_ah']

        # (+) DEF: Discharge capacity corresponding to the very last cycle of
        #         formation (C/10 for both profiles)
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

        # Extract the voltage drop for different time cutoffs
        # e.g. 0 to 1 hour, 0 to 2 hours
        for time_cutoff_hr in [1, 2, 3, 4, 5, 6]:
            these_voltages = y_smoothed[x < time_cutoff_hr * 3600]
            res_dict[f'form_6hr_rest_delta_voltage_v_0_to_{time_cutoff_hr}_hr'] = \
                y_smoothed[0] - these_voltages[-1]

        for time_cutoff_hr in [0, 1, 2, 3, 4, 5]:
            these_voltages = y_smoothed[x > time_cutoff_hr * 3600]
            final_voltage = y_smoothed[-1]
            res_dict[f'form_6hr_rest_delta_voltage_v_{time_cutoff_hr}_to_6_hr'] = \
                these_voltages[0] - final_voltage

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


        # Process current bump signal during first CV hold step
        STEP_INDEX_FIRST_CV_HOLD = 4 if self.is_baseline_formation() else 5
        CYCLE_INDEX_FIRST_CV_HOLD = 1 if self.is_baseline_formation() else 1
        df_first_cv_hold = df[(df['Cycle Number'] == CYCLE_INDEX_FIRST_CV_HOLD) &
                              (df['Step Index'] == STEP_INDEX_FIRST_CV_HOLD)]

        cv_hold_capacity = df_first_cv_hold['Charge Capacity (Ah)'].iloc[-1] - \
                           df_first_cv_hold['Charge Capacity (Ah)'].iloc[0]

        # Add info about the C/20 charge peak to peak distance
        (c20_charge_qpp_ah, c20_charge_right_peak_v_per_ah) = self.get_formation_test_final_c20_charge_qpp()

        # (+) DEF: C/10 charge dV/dQ peak-to-peak distance (Ah)
        #      There is a typo in the variable name
        res_dict['form_c20_charge_qpp_ah'] = c20_charge_qpp_ah

        # (+) DEF: C/10 charge dV/dQ right peak height (V/Ah)
        # .    There is a typo in the variable name
        res_dict['form_c20_charge_right_peak_v_per_ah'] = c20_charge_right_peak_v_per_ah

        # (+) DEF: Delta voltage after 6 hour rest at 100% SOC (preceded by a C/100 CV cut)
        res_dict['form_6hr_rest_delta_voltage_v'] = delta_voltage

        # (+) DEF: Final voltage after 6 hour rest at 100% SOC (preceded by a C/100 CV cut)
        res_dict['form_6hr_rest_voltage_v'] = voltage_final

        # (+) DEF: Steady-state voltage decay rate after 6 hour rest at 100% SOC (mV/day)
        #     (Averaged over last 2 hours)
        res_dict['form_6hr_rest_mv_per_day_steady'] = mv_per_day_steady

        # (+) DEF: Initial voltage drop rate after 6 hour rest at 100% SOC (mV/sec)
        #      (Averaged over first 15 minutes)
        res_dict['form_6hr_rest_mv_per_sec_initial'] = mv_per_sec_initial

        # (+) DEF: First cycle CV hold capacity (Ah)
        res_dict['form_first_cv_hold_capacity_ah'] = cv_hold_capacity

        return res_dict


    def calculate_var_q_from_cycling(self, cyc1, cyc0, to_plot=False):
        """
        Compute the variance in Q metric as reported by Severson et al. from the
        2019 Nature Energy paper.

        Use the discharge capacity data from the 1C discharges during cycling

        Metric is computed as Var (Delta Q (V)) _ (cyc1 -> cyc0)
        Args:
          cyc1 (int): final cycle
          cyc0 (int): initial cycle

        Returns:
          a Dictionary containing:
            - voltage (vector)
            - delta q (vector)
            - var q (scalar)
        """

        assert cyc1 > cyc0, 'Final cycle must be greater than initial cycle'

        df1 = self.get_aging_data_discharge_curve(cyc1)
        df0 = self.get_aging_data_discharge_curve(cyc0)

        v0 = df0['Potential (V)']
        v1 = df1['Potential (V)']

        q0 = df0['Discharge Capacity (Ah)']
        q1 = df1['Discharge Capacity (Ah)']

        f0 = interpolate.interp1d(v0, q0, fill_value='extrapolate')
        f1 = interpolate.interp1d(v1, q1, fill_value='extrapolate')

        v_shared = np.linspace(4.2, 3.0, 250)

        q0_interp = f0(v_shared)
        q1_interp = f1(v_shared)

        delta_q = q0_interp - q1_interp
        var_q = np.var(delta_q)

        var_q_dict = dict()

        var_q_dict[f'var_q_1c_c{cyc1}_c{cyc0}_ah'] = var_q
        var_q_dict[f'var_q_1c_c{cyc1}_c{cyc0}_delta_q'] = delta_q
        var_q_dict[f'var_q_1c_c{cyc1}_c{cyc0}_voltage_v'] = v_shared

        return var_q_dict


    def calculate_var_q_c20_discharge(self, to_plot=False):
        """
        Compute the variance in Q metric as reported by Seversen et al. from the
        2019 Nature Energy paper.

        Use the C/20 discharge capacity from the RPTs during cycling

        Returns:
            a Dictionary containing:
              - voltage (vector)
              - delta q (vector)
              - var q (scalar)
        """

        result_list = self.process_diagnostic_c20_data()

        var_q_dict = dict()

        for result in result_list[1::]:

            q0 = result_list[0]['dch_capacity']
            v0 = result_list[0]['dch_voltage']
            cyc0 = result_list[0]['cycle_index']

            q1 = result['dch_capacity']
            v1 = result['dch_voltage']
            cyc1 = result['cycle_index']

            if q1.empty:
                continue

            f0 = interpolate.interp1d(v0, q0, fill_value='extrapolate')
            f1 = interpolate.interp1d(v1, q1, fill_value='extrapolate')

            v_shared = np.linspace(4.2, 3.0, 250)
            q0_interp = f0(v_shared)
            q1_interp = f1(v_shared)

            delta_q = q0_interp - q1_interp
            var_q = np.var(delta_q)

            var_q_dict[f'var_q_c20_c{cyc1}_c{cyc0}_ah'] = var_q
            var_q_dict[f'var_q_c20_c{cyc1}_c{cyc0}_delta_q'] = delta_q
            var_q_dict[f'var_q_c20_c{cyc1}_c{cyc0}_voltage_v'] = v_shared

            if to_plot:
                plt.figure()
                plt.plot(delta_q, v_shared)
                plt.xlabel('Capacity (Ah)')
                plt.ylabel('Voltage (V)')
                plt.title(f'Cell {self.cellid}')

                plt.savefig(f'output/debug/var_q_cell_{self.cellid}_{var_name}')

                print('VarQ figure has been exported.')

        return var_q_dict


    def get_aging_test_summary_statistics(self):
        """
        Return summary statistics from the aging test
        """

        # indices representing initial cell capacity
        IDX_INIT_CAPACITY = np.arange(3, 8)
        stats = dict()

        df = self.get_aging_data_cycles()

        dch_capacity = df['Discharge Capacity (Ah)']
        cyc_number = df['Cycle Number']
        ahah       = df['Cumulative Discharge Capacity (Ah)'] / NOM_CAP_AH

        (hppc_stats, dcr_soc_targets) = self.summarize_hppc_pulse_statistics()
        (hppc_stats_chg, dcr_soc_targets_chg) = self.summarize_hppc_pulse_statistics('charge')

        initial_capacity = np.mean(dch_capacity[IDX_INIT_CAPACITY])
        capacity_retention = dch_capacity/initial_capacity

        np.interp(0.5, capacity_retention, dch_capacity)

        stats['initial_capacity'] = np.mean(dch_capacity[IDX_INIT_CAPACITY])
        stats['initial_capacity_std'] = np.std(dch_capacity[IDX_INIT_CAPACITY])

        # Filter the capacity retention vs cycle number data to get a clean
        # interp here

        # Method 1
        # idx_bad = []

        # for idx in range(len(capacity_retention) - 1):

        #     curr_capacity = capacity_retention[idx]
        #     next_capacity = capacity_retention[idx + 1]
        #     if next_capacity - curr_capacity > 0.2:

        #         idx_bad.append(idx)

        #         # Subsequent 3 cycles also belong to diagnostic tests
        #         for jdx in [1, 2, 3]:
        #             if idx + jdx < len(capacity_retention) - 1:
        #                 idx_bad.append(idx + jdx)

        # capacity_retention[idx_bad] = np.nan

        # Method 2
        idx = np.where((df['Total Charge Time (s)'] > 8500) |
                   (df['Total Charge Time (s)'] < 100))[0]
        df = df.copy()
        capacity_retention[idx] = np.nan

        df_ret = pd.Series(capacity_retention)

        capacity_retention = df_ret.interpolate(method='linear').bfill().to_numpy()

        # EOL metrics
        stats['cycles_to_50_pct'] = find_cycles_to_target_retention(capacity_retention, cyc_number, 0.5)
        stats['cycles_to_60_pct'] = find_cycles_to_target_retention(capacity_retention, cyc_number, 0.6)
        stats['cycles_to_70_pct'] = find_cycles_to_target_retention(capacity_retention, cyc_number, 0.7)
        stats['cycles_to_80_pct'] = find_cycles_to_target_retention(capacity_retention, cyc_number, 0.8)

        stats['ahah_to_50_pct'] = find_cycles_to_target_retention(capacity_retention, ahah, 0.5)
        stats['ahah_to_60_pct'] = find_cycles_to_target_retention(capacity_retention, ahah, 0.6)
        stats['ahah_to_70_pct'] = find_cycles_to_target_retention(capacity_retention, ahah, 0.7)
        stats['ahah_to_80_pct'] = find_cycles_to_target_retention(capacity_retention, ahah, 0.8)

        # VarQ metrics
        var_q_dict = self.calculate_var_q_c20_discharge()
        for key in var_q_dict:
            stats[key] = var_q_dict[key]

        var_q_dict = self.calculate_var_q_from_cycling(100, 10)
        for key in var_q_dict:
            stats[key] = var_q_dict[key]

        # Metrics having to do with C/3 and C/20 discharge capacities from the
        # RPTs

        # The C/3 capacities
        result_list_c3 = self.process_diagnostic_c3_data()
        for idx, result in enumerate(result_list_c3):

            cycle_number = result['cycle_index']

            if result['dch_capacity'].empty:
                continue

            stats[f'c3_dch_cap_at_c{cycle_number}_ah'] = result['dch_capacity'].iloc[-1]

        # The C/20 capacities
        result_list_c20 = self.process_diagnostic_c20_data()
        for idx, result in enumerate(result_list_c20):
            cycle_number = result['cycle_index']

            if result['dch_capacity'].empty:
                continue

            stats[f'c20_dch_cap_at_c{cycle_number}_ah'] = result['dch_capacity'].iloc[-1]

            # If there is a corresponding C/3 capacity, then calculate the
            # difference and ratios
            if len(result_list_c20) >= idx + 1:

                assert result_list_c3[idx]['cycle_index'] == cycle_number - 1

                if result_list_c3[idx]['dch_capacity'].empty:
                    continue

                stats[f'c20_minus_c3_dch_cap_at_c{cycle_number}_ah'] = result['dch_capacity'].iloc[-1] - \
                    result_list_c3[idx]['dch_capacity'].iloc[-1]

                stats[f'c20_over_c3_dch_cap_at_c{cycle_number}_ah'] = result['dch_capacity'].iloc[-1] / \
                    result_list_c3[idx]['dch_capacity'].iloc[-1]


        # Capacity retention and cell resistance at different cycle numbers
        # Cycle #3 corresponds to the first available cycle
        cycle_target_list = [3, 50, 56, 100, 150, 159, 200, 250, 262, 300, 350, 365, 400, 450]

        for cycle_target in cycle_target_list:

            curr_retention = np.interp(cycle_target, cyc_number, capacity_retention)
            stats[f'retention_at_c{cycle_target}'] = curr_retention

            # Loop through the different SOCs for DCRs on discharge
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

            # Loop through the different SOCs for DCRs on charge
            for dcr_soc_target in dcr_soc_targets_chg:

                dcr_soc_target_int = int(dcr_soc_target*100)
                curr_dcr_10s_soc = np.interp(cycle_target, hppc_stats_chg['cycle_index'],
                                         hppc_stats_chg[f'dcr_10s_soc_{dcr_soc_target_int}'])
                curr_dcr_3s_soc = np.interp(cycle_target, hppc_stats_chg['cycle_index'],
                                         hppc_stats_chg[f'dcr_3s_soc_{dcr_soc_target_int}'])
                curr_dcr_1s_soc = np.interp(cycle_target, hppc_stats_chg['cycle_index'],
                                         hppc_stats_chg[f'dcr_1s_soc_{dcr_soc_target_int}'])

                stats[f'dcr_10s_{dcr_soc_target_int}_soc_at_c{cycle_target}_chg'] = curr_dcr_10s_soc
                stats[f'dcr_3s_{dcr_soc_target_int}_soc_at_c{cycle_target}_chg'] = curr_dcr_3s_soc
                stats[f'dcr_1s_{dcr_soc_target_int}_soc_at_c{cycle_target}_chg'] = curr_dcr_1s_soc


        cycles_to_70_pct = stats['cycles_to_70_pct']

        # DCR interpolated at the cycle number corresponding to 70% capacity retention
        # On discharge pulses
        for dcr_soc_target in dcr_soc_targets:

            dcr_soc_target_int = int(dcr_soc_target*100)

            curr_dcr_10s_soc = np.interp(cycles_to_70_pct, hppc_stats['cycle_index'],
                                    hppc_stats[f'dcr_10s_soc_{dcr_soc_target_int}'])
            curr_dcr_3s_soc = np.interp(cycles_to_70_pct, hppc_stats['cycle_index'],
                                    hppc_stats[f'dcr_3s_soc_{dcr_soc_target_int}'])
            curr_dcr_1s_soc = np.interp(cycles_to_70_pct, hppc_stats['cycle_index'],
                                    hppc_stats[f'dcr_1s_soc_{dcr_soc_target_int}'])

            stats[f'dcr_10s_{dcr_soc_target_int}_soc_at_70_pct'] = curr_dcr_10s_soc
            stats[f'dcr_3s_{dcr_soc_target_int}_soc_at_70_pct'] = curr_dcr_3s_soc
            stats[f'dcr_1s_{dcr_soc_target_int}_soc_at_70_pct'] = curr_dcr_1s_soc

        # DCR interpolated at the cycle number corresponding to 70% capacity retention
        # On charge pulses
        for dcr_soc_target in dcr_soc_targets_chg:

            dcr_soc_target_int = int(dcr_soc_target*100)

            curr_dcr_10s_soc = np.interp(cycles_to_70_pct, hppc_stats_chg['cycle_index'],
                                    hppc_stats_chg[f'dcr_10s_soc_{dcr_soc_target_int}'])
            curr_dcr_3s_soc = np.interp(cycles_to_70_pct, hppc_stats_chg['cycle_index'],
                                    hppc_stats_chg[f'dcr_3s_soc_{dcr_soc_target_int}'])
            curr_dcr_1s_soc = np.interp(cycles_to_70_pct, hppc_stats_chg['cycle_index'],
                                    hppc_stats_chg[f'dcr_1s_soc_{dcr_soc_target_int}'])

            stats[f'dcr_10s_{dcr_soc_target_int}_soc_at_70_pct_chg'] = curr_dcr_10s_soc
            stats[f'dcr_3s_{dcr_soc_target_int}_soc_at_70_pct_chg'] = curr_dcr_3s_soc
            stats[f'dcr_1s_{dcr_soc_target_int}_soc_at_70_pct_chg'] = curr_dcr_1s_soc


        return stats


    def summarize_hppc_pulse_statistics(self, direction='discharge'):
        """
        Returns a summary table of only the most relevant HPPC metrics,
        including DCR at 0%, 50% and 100% SOC

        Returns a tuple of (DataFrame, list of SOC targets)

        Parameters
        ---------
        direction (default='discharge'): either 'charge' or 'discharge' pulses
        """

        if direction == 'discharge':
            results_list = self.process_diagnostic_hppc_discharge_data()
        elif direction == 'charge':
            results_list = self.process_diagnostic_hppc_charge_data()
        else:
            assert 'Direction must be either "charge" or "discharge"'

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


    def process_diagnostic_4p2v_voltage_decay(self):
        """
        Takes in raw data and returns summary statistics of the
        1-hour voltage decay starting from 4.2V, following the C/20 charge cycle
        in each RPT.

        Returns a list of dictionaries. Each dictionary holds:
          - cycle_index: cycle index containing the voltage decay data
          - voltage decay: measured 1-hour voltage decay from 4.2V
        """

        df = self.get_aging_data_timeseries()

        df_voltage_decay = df[df['Step Index'] == 15]

        cycle_indices = np.unique(df_voltage_decay['Cycle Number'])

        results_list = list()

        VOLTAGE_MAXIMUM = 4.2

        for curr_cyc in cycle_indices:

            curr_df = df[df['Cycle Number'] == curr_cyc]

            voltage = curr_df['Potential (V)']

            voltage_smoothed = savgol_filter(voltage, 41, 3)
            voltage_final = voltage_smoothed[-1]
            delta_voltage = VOLTAGE_MAXIMUM - voltage_final

            curr_result = dict()
            curr_result['cycle_index'] = curr_cyc
            curr_result['delta_voltage'] = delta_voltage

            results_list.append(curr_result)

        return results_list


    def process_diagnostic_hppc_charge_data(self):
        """
        Takes in raw data and returns a data structure holding processed
        HPPC discharge pulse information; uses step indices to infer start
        and end of each pulse.

        Outputs:
        ---------
        A list of dictionaries. Each dictionary holds:
          - key: cycle index containing the HPPC cycle
          - value: a Pandas DataFrame
        """

        df = self.get_aging_data_timeseries()

        df_hppc = df[df['Step Index'] == STEP_INDEX_HPPC_CHARGE]
        hppc_cycle_indices = np.unique(df_hppc['Cycle Number'])

        results_list = list()

        # Loop through each diagnostic test
        for curr_cyc in hppc_cycle_indices:

            curr_df = df[df['Cycle Number'] == curr_cyc]

            # Initialize a bunch of variables for exporting raw outputs
            voltage_vec_all = []
            capacity_0_vec_all = []
            voltage_0_vec_all = []
            current_vec_all = []
            time_vec_all = []
            df_raw_list = []

            # Process each pulse
            pulse_list = []
            for idx, point in enumerate(curr_df['Step Index'].values):

                if idx == 0:
                    continue

                # Detect pulse start
                if point == STEP_INDEX_HPPC_CHARGE \
                    and curr_df['Step Index'].iloc[idx-1] != STEP_INDEX_HPPC_CHARGE:

                    capacity_0 = curr_df['Charge Capacity (Ah)'].iloc[idx-1]
                    voltage_0 = curr_df['Potential (V)'].iloc[idx-1]

                    # Detect index corresponding to end of pulse
                    jdx = idx + 1
                    while True:
                        jdx += 1
                        if curr_df['Step Index'].iloc[jdx] != STEP_INDEX_HPPC_CHARGE:
                            break

                    # Extract, voltage-current-time vector for this pulse
                    voltage_vec = curr_df['Potential (V)'].iloc[idx:jdx]
                    current_vec = curr_df['Current (A)'].iloc[idx:jdx]
                    time_vec = curr_df['Test Time (s)'].iloc[idx:jdx] - \
                               curr_df['Test Time (s)'].iloc[idx]

                    voltage_0_vec = voltage_0 * np.ones(np.size(voltage_vec))
                    capacity_0_vec = capacity_0 * np.ones(np.size(voltage_vec))

                    curr_dict = dict()
                    curr_dict['voltage_v'] = voltage_vec
                    curr_dict['current_a'] = current_vec
                    curr_dict['time_s'] = time_vec
                    curr_dict['voltage_0_v'] = voltage_0_vec
                    curr_dict['capacity_0_ah'] = capacity_0_vec
                    curr_df_raw = pd.DataFrame(curr_dict)
                    df_raw_list.append(curr_df_raw)

                    # Pulses that did not last 10 seconds could indicate a fault
                    # in the test. We want to code to pass at this point
                    is_pulse_completed = np.abs(time_vec.iloc[-1] - 10) < 0.1

                    if not is_pulse_completed:
                        continue

                    voltage_at_1_sec  = np.interp(1, time_vec, voltage_vec)
                    voltage_at_3_sec  = np.interp(3, time_vec, voltage_vec)
                    voltage_at_10_sec = np.interp(10, time_vec, voltage_vec, right=voltage_vec.iloc[-1])

                    # Use the mean current throughout the pulse to reduce noise
                    current_mean = np.abs(np.mean(current_vec))

                    result = dict()
                    result['capacity'] = capacity_0
                    result['voltage'] = voltage_0
                    result['resistance_1s_ohm']  = (voltage_at_1_sec - voltage_0) / current_mean
                    result['resistance_3s_ohm']  = (voltage_at_3_sec - voltage_0) / current_mean
                    result['resistance_10s_ohm'] = (voltage_at_10_sec - voltage_0) / current_mean
                    result['current'] = current_mean

                    pulse_list.append(result)


            df_raw_all = pd.concat(df_raw_list)

            curr_result = dict()
            curr_result['cycle_index'] = curr_cyc
            curr_result['data'] = pd.DataFrame(pulse_list)
            curr_result['raw_pulses'] = df_raw_all
            curr_result['raw_all'] = curr_df
            results_list.append(curr_result)

        return results_list

    def process_diagnostic_hppc_discharge_data(self):
        """
        Takes in raw data and returns a data structure holding processed
        HPPC discharge pulse information; uses step indices to infer start
        and end of each pulse.

        Outputs:
        ---------
        A list of dictionaries. Each dictionary holds:
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

            # Initialize a bunch of variables for exporting raw outputs
            voltage_vec_all = []
            capacity_0_vec_all = []
            voltage_0_vec_all = []
            current_vec_all = []
            time_vec_all = []
            df_raw_list = []

            # Process each pulse
            pulse_list = []
            for idx, point in enumerate(curr_df['Step Index'].values):

                if idx == 0:
                    continue

                # Detect pulse start
                if point == STEP_INDEX_HPPC_DISCHARGE \
                    and curr_df['Step Index'].iloc[idx-1] != STEP_INDEX_HPPC_DISCHARGE:

                    capacity_0 = curr_df['Charge Capacity (Ah)'].iloc[idx-1]
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

                    voltage_0_vec = voltage_0 * np.ones(np.size(voltage_vec))
                    capacity_0_vec = capacity_0 * np.ones(np.size(voltage_vec))

                    curr_dict = dict()
                    curr_dict['voltage_v'] = voltage_vec
                    curr_dict['current_a'] = current_vec
                    curr_dict['time_s'] = time_vec
                    curr_dict['voltage_0_v'] = voltage_0_vec
                    curr_dict['capacity_0_ah'] = capacity_0_vec
                    curr_df_raw = pd.DataFrame(curr_dict)
                    df_raw_list.append(curr_df_raw)

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
                    result['capacity'] = capacity_0
                    result['voltage'] = voltage_0
                    result['resistance_1s_ohm']  = (voltage_0 - voltage_at_1_sec) / current_mean
                    result['resistance_3s_ohm']  = (voltage_0 - voltage_at_3_sec) / current_mean
                    result['resistance_10s_ohm'] = (voltage_0 - voltage_at_10_sec) / current_mean
                    result['current'] = current_mean

                    pulse_list.append(result)

            df_raw_all = pd.concat(df_raw_list)

            curr_result = dict()
            curr_result['cycle_index'] = curr_cyc
            curr_result['data'] = pd.DataFrame(pulse_list)
            curr_result['raw_pulses'] = df_raw_all
            curr_result['raw_all'] = curr_df
            results_list.append(curr_result)

        return results_list


    def __str__(self):

        return f'Formation Cell {self.cellid}'


"""
Helper Functions
"""

def export_all_c20_data():
    """
    Dumps all C/20 charge and discharge data from the RPTs into the current
    directory.
    """

    for cellid in range(1, NUM_TOTAL_CELLS + 1):
        print(f'Working on cell {cellid}...')
        cell = FormationCell(cellid)
        cell.export_diagnostic_c20_data()


def find_cycles_to_target_retention(retention, cyc_number, target_retention):
    """
    Returns first cycle to go below target retention

    Args:
      retention (0-1), capacity retention (capacity / initial capacity)
      cyc_number (integer), cycle numbers corresponding to the retentions
      target_retention (0-1)

    Returns:
      returns a cycle number (integer)
    """

    if min(retention) > target_retention:
        return np.max(cyc_number)

    return cyc_number[np.where(retention < target_retention)[0][0]]


if __name__ == "__main__":

    # Simple test cases

    for cellid in list(range(1, 41)):
        cell = FormationCell(cellid)
        cell.get_formation_test_final_c20_charge_qpp()

    cell = FormationCell(1)
    cell.get_esoh_fitting_data()
    cell.get_aging_data_discharge_curve(5)
    cell.calculate_var_q_from_cycling(100, 10)
    cell.summarize_hppc_pulse_statistics()
    cell.get_aging_data_cycles()
    cell.get_aging_test_summary_statistics()
    cell.get_formation_test_summary_statistics()
    cell.process_diagnostic_4p2v_voltage_decay()
    cell.get_formation_test_final_c20_charge_qpp()
    cell.get_metadata()
