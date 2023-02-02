"""
A collection of utility classes and methods for parsing raw timeseries data.

Written to handle specifically data from the project 'UMBL2022FEB'.

Andrew Weng
2023/01/31
"""

import numpy as np
import pandas as pd
import src.vas as vas
from scipy import signal

CYC_STEP_INDEX_CHARGE_CC      = 3
CYC_STEP_INDEX_CHARGE_CV      = 4
CYC_STEP_INDEX_CHARGE_REST    = 5
CYC_STEP_INDEX_DISCHARGE_CC   = 6
CYC_STEP_INDEX_DISCHARGE_REST = 7

RPT_STEP_INDEX_START          = 12
RPT_STEP_INDEX_END            = 31
RPT_STEP_INDEX_C20_CHARGE     = 26
RPT_STEP_INDEX_C20_DISCHARGE  = 23

# Voltage decay after CV hold at 4.2V and 12 hours
RPT_STEP_INDEX_VOLTAGE_RELAX_TOP_12HR = 27 

# Voltage rebound after CC discharge to 3.0V and 2.5 hours
RPT_STEP_INDEX_VOLTAGE_RELAX_BOT_2P5HR = 13 
RPT_STEP_INDEX_END_OF_HPPC             = 21

HPPC_STEP_INDEX_PULSE_DISCHARGE        = 15
HPPC_STEP_INDEX_PULSE_DISCHARGE_REST   = 16
HPPC_STEP_INDEX_PULSE_CHARGE           = 17
HPPC_STEP_INDEX_PULSE_CHARGE_REST      = 18
HPPC_STEP_INDEX_CHARGE_UP              = 19
HPPC_STEP_INDEX_CHARGE_UP_REST         = 13
HPPC_PULSE_DURATION_TARGET_S           = 10


class CyclingDataParser:
    
    def __init__(self, device_name, vas_helper):
        """
        Use VAS to initialize a parser object
        """
        
        test_list, _ = vas_helper.get_test_names(device_name)
        
        cycle_test_list = []
        
        for test_name in test_list:
            if 'CYC' in test_name:
                cycle_test_list.append(test_name)
                
        assert not len(cycle_test_list) == 0, 'No cycling test found.'
        assert not len(cycle_test_list) > 1, 'More than one cycling test found.'

        cycle_test_name = cycle_test_list[0]
        
        self.cycle_test_name = cycle_test_name
        
        print(f'Working on "{cycle_test_name}"...')
        
        self.df = vas_helper.get_cycler_data(cycle_test_name)
        self.df_cyc = self.df[self.df['step_index'] < RPT_STEP_INDEX_START]
        self.df_rpt = self.df[(self.df['step_index'] >= RPT_STEP_INDEX_START) & \
                              (self.df['step_index'] <= RPT_STEP_INDEX_END)]       
        
        self.df_agg = self.df.groupby('cycle_index').agg('max')
        
        print(f'Initialization complete.')
        
    
    def get_cycling_info(self):
        """
        Returns a DataFrame summarizing info from cycling
        """
        
        df_by_cyc = pd.DataFrame()
        df_by_cyc.index = self.df_agg.index

        df_by_cyc['charge_capacity_ah'] = self.df_agg['charge_capacity_ah']
        df_by_cyc['charge_energy_wh'] = self.df_agg['charge_energy_wh']
        df_by_cyc['discharge_capacity_ah'] = self.df_agg['discharge_capacity_ah']
        df_by_cyc['discharge_energy_wh'] = self.df_agg['discharge_energy_wh']
        df_by_cyc['tot_charge_capacity_ah'] = self.df_agg['charge_capacity_ah'].cumsum()
        df_by_cyc['tot_charge_energy_wh'] = self.df_agg['charge_energy_wh'].cumsum()
        df_by_cyc['tot_discharge_capacity_ah'] = self.df_agg['discharge_capacity_ah'].cumsum()
        df_by_cyc['tot_discharge_energy_wh'] = self.df_agg['discharge_energy_wh'].cumsum()

        # Hide the data during RPTs
        df_by_cyc['charge_capacity_ah'].loc[self.df_rpt['cycle_index'].unique()] = np.NaN
        df_by_cyc['charge_energy_wh'].loc[self.df_rpt['cycle_index'].unique()] = np.NaN
        df_by_cyc['discharge_capacity_ah'].loc[self.df_rpt['cycle_index'].unique()] = np.NaN
        df_by_cyc['discharge_energy_wh'].loc[self.df_rpt['cycle_index'].unique()] = np.NaN


        # Parse metrics by step type
        charge_cc_time_s = []
        charge_cv_time_s = []
        charge_rest_delta_voltage_v = []
        discharge_cc_time_s = []
        discharge_rest_delta_voltage_v = []

        for row in df_by_cyc.iterrows():

            this_df = self.df[self.df['cycle_index'] == row[0]]

            # Charge CC
            df_chgcc = this_df[this_df['step_index'] == CYC_STEP_INDEX_CHARGE_CC]

            if df_chgcc.empty:
                charge_cc_time_s.append(np.NaN)
            else:
                charge_cc_time_s.append(df_chgcc['test_time_s'].tail(1).item() - \
                                        df_chgcc['test_time_s'].head(1).item())

            # Charge CV
            df_chgcv = this_df[this_df['step_index'] == CYC_STEP_INDEX_CHARGE_CV]

            if df_chgcv.empty:
                charge_cv_time_s.append(np.NaN)
            else:
                charge_cv_time_s.append(df_chgcv['test_time_s'].tail(1).item() - \
                                        df_chgcv['test_time_s'].head(1).item())

            # Charge Rest
            df_chgrest = this_df[this_df['step_index'] == CYC_STEP_INDEX_CHARGE_REST]

            if df_chgrest.empty:
                charge_rest_delta_voltage_v.append(np.NaN)
            else:
                charge_rest_delta_voltage_v.append(df_chgrest['voltage_v'].tail(1).item() - \
                                                   df_chgrest['voltage_v'].head(1).item())

            # Discharge CC
            df_dchcc = this_df[this_df['step_index'] == CYC_STEP_INDEX_DISCHARGE_CC]

            if df_dchcc.empty:
                discharge_cc_time_s.append(np.NaN)
            else:
                discharge_cc_time_s.append(df_dchcc['test_time_s'].tail(1).item() - \
                                           df_dchcc['test_time_s'].head(1).item())


            # Discharge Rest
            df_dchrest = this_df[this_df['step_index'] == CYC_STEP_INDEX_DISCHARGE_REST]

            if df_dchrest.empty:
                discharge_rest_delta_voltage_v.append(np.NaN)
            else:
                discharge_rest_delta_voltage_v.append(df_dchrest['voltage_v'].tail(1).item() - \
                                                      df_dchrest['voltage_v'].head(1).item())


        # Assign back to the DataFrame    
        df_by_cyc['charge_cc_time_s'] = charge_cc_time_s
        df_by_cyc['charge_cv_time_s'] = charge_cv_time_s
        df_by_cyc['charge_rest_delta_voltage_v'] = charge_rest_delta_voltage_v
        df_by_cyc['discharge_cc_time_s'] = discharge_cc_time_s
        df_by_cyc['discharge_rest_delta_voltage_v'] = discharge_rest_delta_voltage_v

        return df_by_cyc
        

    def get_rpt_start_cycles(self):
        """
        Returns a list of cycle indices corresponding to RPT starts
        """
    
        rpt_start_cycle_list = []

        unique_cycles = self.df['cycle_index'].unique()

        for cycle in unique_cycles:

            this_df = self.df[self.df['cycle_index'] == cycle]

            if this_df['step_index'].isin([RPT_STEP_INDEX_START]).any():
                rpt_start_cycle_list.append(cycle)
                
        return rpt_start_cycle_list
    
        
    def get_rpt_info(self):
        """
        Return a DataFrame containing summarized info from the RPT.
        
        Includes processing C/20 charge and discharge curves for dV/dQ analysis
        
        Excludes HPPC parsing; that is handled elsewhere.
        """
        
        rpt_start_cycle_list = self.get_rpt_start_cycles()
                
        # Compile information at each RPT
        cycle_index_list = []
        c20_discharge_capacity_ah_list = []
        c20_charge_capacity_ah_list = []
        throughput_ah_list = []
        dvdq_data_list = []
        voltage_decay_at_top_list = []
        voltage_decay_at_bot_list = []

        for rpt_start_cycle in rpt_start_cycle_list:

            # Create a DataFrame to hold the current RPT data only
            this_rpt = self.df_rpt[(self.df_rpt['cycle_index'] >= rpt_start_cycle)]
            this_rpt = this_rpt[this_rpt['cycle_index'] <= rpt_start_cycle + 80]
            this_rpt['time_s'] = this_rpt['test_time_s'] - this_rpt['test_time_s'].iloc[0]

            # Extract the charge and discharge C/20 curves
            c20_charge_capacity_ah = this_rpt[this_rpt['step_index'] == \
                                              RPT_STEP_INDEX_C20_CHARGE]['charge_capacity_ah']
            c20_charge_voltage_v   = this_rpt[this_rpt['step_index'] == \
                                              RPT_STEP_INDEX_C20_CHARGE]['voltage_v']
            c20_discharge_capacity_ah = this_rpt[this_rpt['step_index'] == \
                                                 RPT_STEP_INDEX_C20_DISCHARGE]['discharge_capacity_ah']
            c20_discharge_voltage_v   = this_rpt[this_rpt['step_index'] == \
                                                 RPT_STEP_INDEX_C20_DISCHARGE]['voltage_v']

            voltage_decay_at_top = this_rpt[this_rpt['step_index'] == \
                                            RPT_STEP_INDEX_VOLTAGE_RELAX_TOP_12HR]['voltage_v']
            voltage_decay_at_bot = this_rpt[this_rpt['step_index'] == \
                                            RPT_STEP_INDEX_VOLTAGE_RELAX_BOT_2P5HR]['voltage_v']

            # Calculate the filtered dV/dQ outputs
            window_length = 101
            polyorder = 2
            Qf_d = signal.savgol_filter(c20_discharge_capacity_ah,window_length,polyorder)
            dQ_d = signal.savgol_filter(c20_discharge_capacity_ah,window_length,polyorder,1)
            Vf_d = signal.savgol_filter(c20_discharge_voltage_v,window_length,polyorder)
            dV_d = signal.savgol_filter(c20_discharge_voltage_v,window_length,polyorder,1)
            dVdQ_d = dV_d / dQ_d    
            dQdV_d = dQ_d / dV_d

            Qf_c = signal.savgol_filter(c20_charge_capacity_ah,window_length,polyorder)
            dQ_c = signal.savgol_filter(c20_charge_capacity_ah,window_length,polyorder,1)
            Vf_c = signal.savgol_filter(c20_charge_voltage_v,window_length,polyorder)
            dV_c = signal.savgol_filter(c20_charge_voltage_v,window_length,polyorder,1)
            dVdQ_c = dV_c / dQ_c    
            dQdV_c = dQ_c / dV_c

            this_dvdq_data = dict()
            this_dvdq_data['dch_q'] = Qf_d
            this_dvdq_data['dch_v'] = Vf_d
            this_dvdq_data['dch_dvdq'] = dVdQ_d
            this_dvdq_data['chg_q'] = Qf_c
            this_dvdq_data['chg_v'] = Vf_c
            this_dvdq_data['chg_dvdq'] = dVdQ_c

            throughput_ah_list.append(self.df_agg['discharge_capacity_ah'].cumsum()\
                                      [self.df_agg.index == rpt_start_cycle].values[0])
            dvdq_data_list.append(this_dvdq_data)
            c20_discharge_capacity_ah_list.append(c20_discharge_capacity_ah.max())
            c20_charge_capacity_ah_list.append(c20_charge_capacity_ah.max())
            cycle_index_list.append(rpt_start_cycle)
            voltage_decay_at_top_list.append(voltage_decay_at_top.tail(1).item() - \
                                             voltage_decay_at_top.head(1).item())
            voltage_decay_at_bot_list.append(voltage_decay_at_bot.tail(1).item() - \
                                             voltage_decay_at_bot.head(1).item())

            
        # Assemble the final DataFrame from the lists
        df_by_rpt = pd.DataFrame(list(zip(cycle_index_list, 
                                          throughput_ah_list, 
                                          c20_discharge_capacity_ah_list, 
                                          c20_charge_capacity_ah_list,
                                          voltage_decay_at_top_list,
                                          voltage_decay_at_bot_list,
                                          dvdq_data_list)), columns=['cycle_index', 
                                                                     'tot_discharge_capacity_ah',
                                                                     'c20_discharge_capacity_ah',
                                                                     'c20_charge_capacity_ah',
                                                                     'deltav_4p2v_12hr',
                                                                     'deltav_3p0v_2p5hr',
                                                                     'dvdq_data'])

        
        return df_by_rpt
        
        
        
    def get_hppc_info(self):
        """
        Return a DataFrame containing HPPC info extracted from the RPT
        """
        
        rpt_start_cycle_list = self.get_rpt_start_cycles()
        
        resistance_charge_list = []
        resistance_discharge_list = []
        cycle_index_list = []
        throughput_ah_list = []
        capacity_ah_list = []

        for rpt_start_cycle in rpt_start_cycle_list:

            hppc_start_cycle = rpt_start_cycle + 1
            
            # Create a DataFrame to hold the current HPPC data only
            this_rpt = self.df_rpt[(self.df_rpt['cycle_index'] >= hppc_start_cycle)]

            # First overshoot a bit...
            this_rpt = this_rpt[this_rpt['cycle_index'] <= hppc_start_cycle + 80]

            # ...then trim
            hppc_end_cycle  = this_rpt[this_rpt['step_index'] == \
                                       RPT_STEP_INDEX_END_OF_HPPC]['cycle_index'].iloc[0]
            this_rpt = this_rpt[this_rpt['cycle_index'] <= hppc_end_cycle]

            # Reset the capacity counter for each RPT; use this to convert to SOC later
            capacity_ah_counter = 0

            # Break out each sequence by cycle index    
            for hppc_cycle_index in this_rpt['cycle_index'].unique():

                curr_hppc = this_rpt[this_rpt['cycle_index'] == hppc_cycle_index].copy()
                curr_hppc['time_s'] = curr_hppc['test_time_s'] - curr_hppc['test_time_s'].iloc[0]

                # Process the discharge pulse
                df_dch_pulse = curr_hppc[curr_hppc['step_index'] == HPPC_STEP_INDEX_PULSE_DISCHARGE]
                if df_dch_pulse.empty:
                    R_dch = np.NaN
                else:
                    V0 = self.df_rpt['voltage_v'].loc[np.arange(df_dch_pulse.index[0] - \
                                                                5, df_dch_pulse.index[0])].median()
                    V1 = np.interp(HPPC_PULSE_DURATION_TARGET_S, \
                                   df_dch_pulse['step_time_s'], df_dch_pulse['voltage_v'])
                    I = df_dch_pulse['current_a'].median()
                    R_dch = (V1 - V0)/I

                # Process the charge pulse
                df_chg_pulse = curr_hppc[curr_hppc['step_index'] == HPPC_STEP_INDEX_PULSE_CHARGE]
                if df_chg_pulse.empty:
                    R_chg = np.NaN
                else:
                    V0 = self.df_rpt['voltage_v'].loc[np.arange(df_chg_pulse.index[0] - \
                                                                5, df_chg_pulse.index[0])].median()
                    V1 = np.interp(HPPC_PULSE_DURATION_TARGET_S, \
                                   df_chg_pulse['step_time_s'], df_chg_pulse['voltage_v'])
                    I = df_chg_pulse['current_a'].median()
                    R_chg = (V1 - V0)/I

                resistance_discharge_list.append(R_dch)
                resistance_charge_list.append(R_chg)
                cycle_index_list.append(rpt_start_cycle)
                capacity_ah_list.append(capacity_ah_counter)
                throughput_ah_list.append(self.df_agg['discharge_capacity_ah'].cumsum()\
                                          [self.df_agg.index == rpt_start_cycle].values[0])

                # Update the amp-hours moved
                df_chg_up = curr_hppc[curr_hppc['step_index'] == HPPC_STEP_INDEX_CHARGE_UP]
                capacity_ah_counter += df_chg_up['charge_capacity_ah'].max() - \
                                       df_chg_up['charge_capacity_ah'].min()


        # Package the lists as a DataFrame
        df_hppc = pd.DataFrame(list(zip(cycle_index_list,
                              throughput_ah_list,
                              resistance_discharge_list,
                              resistance_charge_list,
                              capacity_ah_list)), columns=['cycle_index', 
                                                            'throughput_ah',
                                                            'resistance_discharge_ohms',
                                                            'resistance_charge_ohms',
                                                            'capacity_ah'])

    
        return df_hppc
    
    
class FormationParser:
    
    
    def __init__():
        
        pass