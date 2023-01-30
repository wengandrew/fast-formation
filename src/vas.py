"""
Helper utilities for Voltaiq Analytic Studio (VAS).

Used to fetch and format data from VAS.

Andrew Weng
1/30/2023
"""


import voltaiq_studio as vs
import pandas as pd
import time


class VasHelper:
    """ 
    Voltaiq Analytic Studio Helper Class.
    
    Wraps around the voltaiq_stuido package to provide
    some convenient methods to get data
    """
    
    
    def __init__(self):
        
        print('Initializing Voltaiq Analytic Studio Helper...')
        
        print('Initializing test records...')
        self.trs = vs.get_test_records()
        
        print('Initializing devices...')
        self.devices = vs.get_devices()
        
        print('Done.')
        
    
    def filter_devices(self, keyword):
        """
        Return a filtered list of device names based on keyword
        """
    
        device_list = []
        
        for device in self.devices:        
            if keyword in device.name:
                device_list.append(device.name)
                
        return device_list
    
    
    def get_test_records_for_device(self, device_name):
        """
        Retrieve the test records for a given device name.
        
        Returns:
          - 'cycler_list' : from cycler
          - 'aux_list'    : aux data
        """
                
        cycler_list = []
        aux_list = []

        for test_record in self.trs:

            if device_name in test_record.name:

                if 'AuxDat' in test_record.name:
                    cycler_list.append(test_record)
                else:
                    aux_list.append(test_record)

        return cycler_list, aux_list
    
        
    def get_cycler_data(self, test_name):
        """
        Return a Pandas DataFrame from a test name corresponding with cycler data
        """
            
        test_record = self._get_test_record(test_name)

        reader = test_record.make_time_series_reader()
        reader.add_trace_keys('h_test_time',
                              'h_datapoint_time',
                              'h_current', 
                              'h_potential', 
                              'h_step_index',
                              'h_step_time')
        reader.add_info_keys('i_cycle_num')

        df = reader.read_pandas()
        df['h_datapoint_datetime'] = pd.to_datetime(df['h_datapoint_time'], unit='ms')\
                                       .dt.tz_localize('UTC')\
                                       .dt.tz_convert('US/Eastern')

        df = df.rename(columns={'h_current':'current'})
        df = df.rename(columns={'h_step_time':'step_time'})
        df = df.rename(columns={'h_test_time':'test_time'})
        df = df.rename(columns={'h_step_index':'step_index'})
        df = df.rename(columns={'h_datapoint_datetime':'datetime'})
        df = df.rename(columns={'i_cycle_num':'cycle_index'})
        df = df.rename(columns={'h_potential':'voltage'})
        df = df.drop(columns=['h_datapoint_time'])

        return df
    
        
    def get_aux_data(self, test_name):
        """
        Return a Pandas DataFrame from a file containing 'aux'iliary data, which includes
        the LDC expansion sensor data, temperature sensor data, and others.
        """

        test_record = self._get_test_record(test_name)

        reader = test_record.make_time_series_reader()

        reader.add_trace_keys('h_test_time',
                              'h_datapoint_time',
                              'aux_vdf_ldcref_none_0',
                              'aux_vdf_ambientrh_percent_0',
                              'aux_vdf_ldcsensor_none_0',
                              'aux_vdf_temperature_celsius_0',
                              'aux_vdf_ambienttemperature_celsius_0'
                              )

        df = reader.read_pandas()
        df['h_datapoint_datetime'] = pd.to_datetime(df['h_datapoint_time'], unit='ms')\
                                       .dt.tz_localize('UTC')\
                                       .dt.tz_convert('US/Eastern')

        df = df.rename(columns={'h_test_time':'test_time'})
        df = df.rename(columns={'h_datapoint_datetime':'datetime'})
        df = df.rename(columns={'aux_vdf_temperature_celsius_0':'temperature'})
        df = df.rename(columns={'aux_vdf_ambienttemperature_celsius_0':'temperature_amb'})
        df = df.rename(columns={'aux_vdf_ldcsensor_none_0':'ldc'})
        df = df.rename(columns={'aux_vdf_ldcref_none_0':'ldc_ref'})
        df = df.drop(columns=['h_datapoint_time'])

        # df['file_name'] = test_name

        return df
    
    
    def get_aux_data_compiled(self, device_name):
        """
        Returns a single DataFrame holding the AuxData for a device,
        stitched together and sorted by time
        """
        
        _, aux_list = self.get_test_records_for_device(device_name)
        
        df = pd.DataFrame()
        
        for test_record in aux_list:
            
            print(f'Processing {test_record.name}')
            
            df = pd.concat([df, self.get_aux_data(test_record.name)])
            
            time.sleep(5)
            
        # Sort and trim values
        df = df.sort_vaules(by=['datetime'])
        df = df[df['datetime'].between('2020', '2040')]
                              
        return df
                              
                              
        
    def _get_test_record(self, test_name):
        """
        Retrieve a test record object matching a test name
        """

        tr_target = 0

        for tr in self.trs:
            if tr.name == test_name:
                tr_target = tr

        assert not tr_target == 0, 'Test record not found!'

        return tr_target
    