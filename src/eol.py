import pandas as pd
from collections import defaultdict
import json, yaml
import re
import os
import glob
import csv
import numpy as np
import math
from formation import FormationCell
import matplotlib.pyplot as plt

# configure paths
paths = yaml.load(open('../paths.yaml', 'r'), Loader=yaml.FullLoader)

DATAPATH = paths["data"] + "2021-08-post-mortem-biologic-pc"

# for printing full df
pd.set_option("display.max_rows", None, "display.max_columns", None)

# plotting options
plt.rcParams["font.family"] = "serif"
plt.rcParams["font.serif"] = "Times New Roman"

plt.rcParams["mathtext.rm"] = "serif"
plt.rcParams["mathtext.it"] = "serif:italic"
plt.rcParams["mathtext.bf"] = "serif:bold"
plt.rcParams["mathtext.fontset"] = "custom"

class EndOfLifeCell:
    def __init__(self, cellid, channel, ff_in, ocv_in):
        # cell id
        self.cellid = cellid

        # channel
        self.channel = channel

        # fast formation boolean (false = baseline formation)
        self.fast_formation = ff_in
        
        # measured ocv before tests
        self.ocv = ocv_in

        # test dataframes
        self.voltage_monitoring_test = pd.DataFrame()

    def __str__(self):
        if self.fast_formation:
            formation_type = "fast formation"
        else:
            formation_type = "baseline"

        return (f"cell id: {self.cellid} formation type: {formation_type}\n\t\
                post cycling capacity: {self.post_cycling_capacity}\n\t\
                post-mortem c/20 capacity: {self.c20_capacity}\n\t\
                post-mortem 1c capacity: {self.c_capacity}\n\t\
                ambient age: {self.ambient_age}\n")

    def extract_capacity(self, filename):
        with open(filename, 'rb') as f:
            lines = f.readlines()

            headerlines = int(lines[1].decode('ASCII').split()[-1])
            df = pd.read_csv(filename, skiprows=headerlines-1, encoding="ISO-8859-1", sep='\t')
            
            if "1c" in filename:
                self.capacity_1c_df = df
            elif "c20" in filename:
                self.capacity_c20_df = df
            else:
                print('Foreign capacity diagnostic test file found: ', filename)
                exit()
            
            # if only one full cycle ran, it should contain cycle numbers [0, 1] or just [0]
            assert(len(df["cycle number"].unique()) <= 2)
            
            # fig, ax = plt.subplots()
            # ax.plot(df['Capacity/mA.h']/1000)
            # ax.plot(df['cycle number'])
            # plt.title(filename)
            # plt.show()

            capacity = np.max(df.iloc[-2000:-1]["Capacity/mA.h"]) / 1000
            return capacity

    def load_tests(self):
        # voltage monitoring
        vm_re = f"20210731_voltage_monitoring_CA{self.channel}.mpt"
        volt_monitor = glob.glob(f"{DATAPATH}/{vm_re}")
        assert len(volt_monitor) == 1, f'Either missing/multiple file with filename: {vm_re}'
        self.self_discharge_rate = self.extract_self_discharge_rate(volt_monitor[0])

        # hppc
        hppc_re = f"20210712_hppc_eis_CA{self.channel}.txt"
        hppc_tests = glob.glob(f"{DATAPATH}/{hppc_re}")
        assert len(hppc_tests) == 1, f'Either missing/multiple file with filename: {hpp_re}'
        self.process_hppc_test(hppc_tests[0])

        # capacity diagnostic (c/20 or 1c)
        c_re = f"20210708_capacity_diagnostic_1c_CA{self.channel}.txt"
        c = glob.glob(f"{DATAPATH}/{c_re}")
        assert len(c) == 1, f'Either missing/multiple file with filename: {c_re}'
        self.c_capacity = self.extract_capacity(c[0]) # save capacity (mAh)

        # capacity diagnostic (c/20)
        c20_re = f"20210708_capacity_diagnostic_c20_CA{self.channel}.txt"
        c20 = glob.glob(f"{DATAPATH}/{c20_re}")
        assert len(c20) == 1, f'Either missing/multiple file with filename: {c20_re}'
        self.c20_capacity = self.extract_capacity(c20[0]) # save capacity (mAh)

    def get_post_cycling_capacity(self):
        # use FormationCell to get post cycling capacity
        formation_cell = FormationCell(self.cellid)
        df = formation_cell.get_aging_data_cycles() # get formation data

        # cycle_numbers = np.unique(df['Cycle Number'])
        
        # for cycle in cycle_numbers:
        #     cycle_df = df[df['Cycle Number'] == cycle]
        #     print(cycle_df['Discharge Capacity (Ah)'])
            
        #     fig, ax = plt.subplots()
        #     ax.plot(cycle_df['Cycle Net Capacity (Ah)'])
        #     plt.show()
            
        # index for cycle containing the final discharge capacity
        CYCLE_INDEX_LAST = np.max(df['Cycle Number'])

        # save last N measured capacities to list
        N = 8 
            # 8 is min number to prune away 2 anomalies 
        last_N_capacities = list()

        # get capacities of last 5 cycles # TODO: plot cycles and see whats going
        for i in range(CYCLE_INDEX_LAST - N + 1, CYCLE_INDEX_LAST + 1):
            cycle_discharge_capacity = np.max(df[df['Cycle Number'] == i]['Discharge Capacity (Ah)'])
            # only append if not nan (empty dfs give nan)
            if not math.isnan(cycle_discharge_capacity):
                last_N_capacities.append(cycle_discharge_capacity)

        # check for c/20 tests using coefficient of variation
        CV = np.std(last_N_capacities) / np.mean(last_N_capacities)
        if CV > 0.1: # significant
            # calculate IQR
            q75,q25 = np.percentile(last_N_capacities,[75,25])
            intr_qr = q75-q25
            
            qmax = q75+(1.5*intr_qr)
            qmin = q25-(1.5*intr_qr)
            
            # prune using IQE
            last_N_capacities = [cap for cap in last_N_capacities if cap < qmax]
            
            print(f'{N - len(last_N_capacities)} entries pruned when getting post cycling capacity')
        
        CV = np.std(last_N_capacities) / np.mean(last_N_capacities)
        if CV > 0.1: # this shouldn't come up after IQR pruning
            print(f'WARNING: high variance of capacities, coefficient of variation is ', CV)
            
        
        # final capacity is last of the list
        final_discharge_capacity = last_N_capacities[-1]

        # save and return
        self.post_cycling_capacity = final_discharge_capacity
        return final_discharge_capacity

    def extract_self_discharge_rate(self, filename): # TODO: write about the cell relaxation / self discharge
        with open(filename, 'rb') as f:
            lines = f.readlines()

            headerlines = int(lines[1].decode('ASCII').split()[-1])
            df = pd.read_csv(filename, skiprows=headerlines-1, encoding="ISO-8859-1", sep='\t')
            self.voltage_monitor_df = df[df['time/s'] < 1.4540e6]
            # plt.figure(self.cellid)
            # plt.plot(df['time/s'], df['Ecell/V'])

    def get_ambient_age(self):
        end_of_cycling = np.datetime64("2020-10-15")
        start_of_eol = np.datetime64("2021-07-08")

        # save ambient age
        self.ambient_age = start_of_eol - end_of_cycling

    def process_hppc_test(self, filename): # TODO: separate EIC and HPPC, save as member resistance df
        resistance_df = pd.DataFrame()
        resistance_df['time'] = 0 # s
        resistance_df['res'] = 0 # ohms
        
        with open(filename, 'rb') as f:
            lines = f.readlines()

            headerlines = int(lines[1].decode('ASCII').split()[-1])
            df = pd.read_csv(filename, skiprows=headerlines-1, encoding="ISO-8859-1", sep='\t')
            
            cycles = np.unique(df['cycle number'])
            
            for c in cycles:
                cycle_df = df[df['cycle number'] == c]
                hppc = cycle_df[cycle_df['I/mA'] < -500]

                if len(hppc) > 0:
                    hppc_start_idx = hppc.index[0]
                    hppc_end_idx = hppc.index[-1] + 1
                else:
                    # print('skipping cycle ', c)
                    continue
                
                discharge_cycle_df = df.iloc[hppc_start_idx:hppc_end_idx]
                
                current_resistance = discharge_cycle_df['R/Ohm'].mean()
                
                resistance_df.loc[len(resistance_df)] = {'time':discharge_cycle_df.iloc[0]['time/s'], 'res':current_resistance}
                
                # fig, ax1 = plt.subplots()
                # ax1.plot(discharge_cycle_df['time/s'], discharge_cycle_df['Ecell/V'], label='voltage')
                
                # ax2 = ax1.twinx()
                # ax2.plot(discharge_cycle_df['time/s'], discharge_cycle_df['I/mA']/1000, 'r', label='current')
                # fig.legend()
                # plt.show()

        fig, ax1 = plt.subplots()
        ax1.scatter(resistance_df['time'], resistance_df['res'], s=10, )
        ax1.plot(resistance_df['time'], resistance_df['res'])

        # fig.legend()
        ax1.set_ylabel('Cell resistance (ohms)')
        ax1.set_xlabel('Time (s)')
        fig.savefig(f'figures/hppc_id_{self.cellid}_ff_{self.fast_formation}.png', format='png')
        # fig.canvas.set_window_title(f'hppc resistance vs time, cell number: {self.cellid}, ff: {self.fast_formation}')
        

    def list_all_tests(self):
        pass

    def plot_c20_data(self):
        df = self.capacity_c20_df
        
        ax.plot(df['time/s'], df['Ecell/V'])
        ax.set_ylabel('cell potential (V)')
        ax.set_xlabel('time (s)')
        ax.set_title(f'1c capacity diagnostic test, cell number: {self.cellid}, ff: {self.fast_formation}')

    def plot_1c_data(self):
        df = self.capacity_1c_df
        
        ax.plot(df['time/s'], df['Ecell/V'])
        ax.set_ylabel('cell potential (V)')
        ax.set_xlabel('time (s)')
        ax.set_title(f'c/20 capacity diagnostic test, cell number: {self.cellid}, ff: {self.fast_formation}')
    
    def plot_voltage_monitoring(self):
        fig, ax = plt.subplots()
        
        df = self.voltage_monitor_df
        
        ax.plot(df['time/s'], df['Ecell/V'])
        ax.scatter(df['time/s'], df['Ecell/V'], s=10)
        ax.set_ylabel('Cell potential (V)')
        ax.set_xlabel('Time (s)')
        #ax.set_title(f'voltage monitoring graph, cell number: {self.cellid}, ff: {self.fast_formation}')
        #fig.canvas.set_window_title(f'voltage monitoring graph, cell number: {self.cellid}, ff: {self.fast_formation}')
        fig.savefig(f'figures/voltage monitoring graph_id_{self.cellid}_ff_{self.fast_formation}.png', format="png")
        
        # ax1 = ax.twinx()
        # ax1.plot(df['Unnamed: 10'])


if __name__ == "__main__":
    # master cell array
    cell_array = defaultdict(int)

    # read json file for cell/channel data
    with open("../notebooks/cell_channel_pair.json", 'r') as f:
        cell_channel_pairs = json.load(f)["cell_channel_pair"]
        
        # process all cells and save to array
        for cell in cell_channel_pairs:
            eol_cell = EndOfLifeCell(cell["cell"], cell["channel"], cell["fast_formation"], cell["OCV"])
            eol_cell.load_tests()
            eol_cell.get_post_cycling_capacity()
            eol_cell.get_ambient_age()
            eol_cell.plot_voltage_monitoring()

            cell_array[cell["cell"]] = eol_cell

            # print cell __repr__
            print(eol_cell)
            print('=========================================================')
    
    #plt.show()

