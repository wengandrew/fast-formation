import pytest
from src.formation import FormationCell as FormationCell

@pytest.fixture
def sample_baseline_formation_cell():

    cell = FormationCell(11)
    return cell

@pytest.fixture
def sample_fast_formation_cell():

    cell = FormationCell(33)
    return cell


"""
The tests below use two concepts:
1. Using fixtures as arguments in pytest parametrize
   - ref: https://miguendes.me/how-to-use-fixtures-as-arguments-in-pytestmarkparametrize
   - basically, wrap all of the functions that share the same fixture inside a class
2. Using shared parametrized arguments across multiple test functions
   ref: https://stackoverflow.com/questions/51739589/how-to-share-parametrized-arguments-across-multiple-test-functions
   - use the `request.getfixturevalue` construct
"""

@pytest.mark.parametrize(
    "cell",
    [
        "sample_baseline_formation_cell",
        "sample_fast_formation_cell"
    ],
)
class TestParametrized:


    def test_initialization(self, cell, request):

        this_cell = request.getfixturevalue(cell)

        assert isinstance(this_cell, FormationCell)


    def test_get_aging_data_timeseries(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        df = this_cell.get_aging_data_timeseries()

        assert not df.empty


    def test_get_aging_data_cycles(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        df = this_cell.get_aging_data_cycles()

        assert not df.empty


    def test_is_plating(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        assert this_cell.is_plating() in [0, 1]


    def test_swelling_severity(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        assert this_cell.get_swelling_severity() in [0, 1, 2, 3]


    def test_get_metadata(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        metadata_dict = this_cell.get_metadata()

        assert bool(metadata_dict)


    def test_get_formation_data(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        df = this_cell.get_formation_data()

        assert not df.empty


    def test_process_diagnostic_c20_data(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        results_list = this_cell.process_diagnostic_c20_data()

        # I want to assert more things
        # not empty
        # contains certain fields
        assert isinstance(results_list, list)


    def test_process_diagnostic_c3_data(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        results_list = this_cell.process_diagnostic_c3_data()

        # I want to assert more things
        # not empty
        # contains certain fields
        assert isinstance(results_list, list)


    def test_export_diagnostic_c20_data(self, cell, request):

        # How to handle i/o testing here
        this_cell = request.getfixturevalue(cell)
        this_cell.export_diagnostic_c20_data()

        pass

    def test_process_diagnostic_hppc_discharge_data(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        results_list = this_cell.process_diagnostic_hppc_discharge_data()

        assert results_list


    def test_get_aging_test_summary_statistics(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        stats = this_cell.get_aging_test_summary_statistics()

        assert stats


    def test_get_formation_test_summary_statistics(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        stats = this_cell.get_formation_test_summary_statistics()

        assert stats


    def test_get_esoh_fitting_results(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        fitting_results = this_cell.get_esoh_fitting_results()

        assert not fitting_results.empty


    def test_summarize_hppc_pulse_statistics(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        stats = this_cell.summarize_hppc_pulse_statistics()

        assert not stats[0].empty


    def test_process_diagnostic_4p2v_voltage_decay(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        stats = this_cell.process_diagnostic_4p2v_voltage_decay()

        assert stats[0]


    def test_get_formation_test_final_c20_discharge(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        df_dch = this_cell.get_formation_test_final_c20_discharge()

        assert not df_dch.empty


    def test_get_formation_test_final_c20_charge_qpp(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        capacity_peak_to_peak_ah = this_cell.get_formation_test_final_c20_charge_qpp()

        assert capacity_peak_to_peak_ah


    def test_get_formation_test_final_c20_charge(self, cell, request):

        this_cell = request.getfixturevalue(cell)
        df_chg = this_cell.get_formation_test_final_c20_charge()

        assert not df_chg.empty


    def test_get_esoh_fitting_data(self, cell, request):

        this_cell = request.getfixturevalue(cell)

        data_list = this_cell.get_esoh_fitting_data()

        assert len(data_list) >= 1
