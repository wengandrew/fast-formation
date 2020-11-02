import pytest
import ipdb
import pandas as pd
from src.formation import FormationCell as FormationCell

@pytest.fixture
def sample_timeseries_df():

    df = pd.DataFrame()
    return df


@pytest.fixture
def sample_formation_cell(sample_timeseries_df):

    cell = FormationCell(1)

    # Two options:
    # - manually type in some data
    # - read from a csv

    return cell


def test_initialization(sample_formation_cell):

    assert isinstance(sample_formation_cell, FormationCell)


def test_get_aging_data_timeseries(sample_formation_cell):

    df = sample_formation_cell.get_aging_data_timeseries()

    assert not df.empty


def test_get_aging_data_cycles(sample_formation_cell):

    df = sample_formation_cell.get_aging_data_cycles()

    assert not df.empty


def test_get_metadata(sample_formation_cell):

    df = sample_formation_cell.get_metadata()

    assert not df.empty


def test_get_formation_data(sample_formation_cell):

    df = sample_formation_cell.get_formation_data()

    assert not df.empty


def test_process_diagnostic_c20_data(sample_formation_cell):

    results_list = sample_formation_cell.process_diagnostic_c20_data()

    # I want to assert more things
    # not empty
    # contains certain fields
    assert isinstance(results_list, list)


def test_export_diagnostic_c20_data(sample_formation_cell):

    # How to handle i/o testing here
    sample_formation_cell.export_diagnostic_c20_data()

    pass

def test_process_diagnostic_hppc_data(sample_formation_cell):

    results_list = sample_formation_cell.process_diagnostic_hppc_data()

    assert results_list


def test_get_aging_test_summary_statistics(sample_formation_cell):

    stats = sample_formation_cell.get_aging_test_summary_statistics()

    assert stats


def test_get_formation_test_summary_statistics(sample_formation_cell):

    stats = sample_formation_cell.get_formation_test_summary_statistics()

    assert stats


def test_summarize_hppc_pulse_statistics(sample_formation_cell):

    # When crashing I want to inspect at the source directly

    stats = sample_formation_cell.summarize_hppc_pulse_statistics()

    assert not stats.empty
