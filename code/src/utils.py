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

if __name__ == "__main__":
    append_esoh_metrics_to_correlations_table()
