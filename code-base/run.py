
from src.utils import *

export_correlation_table()


import ipdb; ipdb.set_trace()

from src.formation import FormationCell

F = FormationCell(1)

res_chg = F.process_diagnostic_hppc_charge_data()[0]['data']
res_dch = F.process_diagnostic_hppc_discharge_data()[0]['data']

stats = F.get_aging_test_summary_statistics()

import ipdb; ipdb.set_trace()


import matplotlib.pyplot as plt

plt.plot(res_chg['capacity'], res_chg['resistance_10s_ohm'])
plt.plot(res_dch['capacity'], res_dch['resistance_10s_ohm'])
plt.legend(['Charge', 'Discharge'])
plt.show()
