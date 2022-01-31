"""
Equivalent circuit models for batteries
"""

import numpy as np
from matplotlib import pyplot as plt

def state_update_ocv_r_2rc(I, T, Rs, R1, R2, C1, C2):
    """
    State update equations for the OCV-R-RC model

    Parameters
    ---------
    I: input current (A), positive is discharge
    T: input temperature in Celsius
    Rs: series resistance in Ohms
    R1: R1 in Ohms
    R2: R2 in Ohms
    C1: C1 in Farads
    C2: C2 in Farads

    Outputs:
    x = [VT, z, V1, V2]^T

    """

    return None


def ocv(z):
    """
    Return the open circuit voltage at a specific SOC

    Parameters
    ---------
    z: state of charge (0-1) (float)

    Returns
    ---------
    V: open circuit voltage (V)

    """

    assert isinstance(z, float) or isinstance(z, int), \
           'Only floats or integers accepted for "z".'

    if z < 0:
        raise ValueError('SOC cannot be less than zero.')

    if z > 1:
        raise ValueError('SOC cannot be greater than one.')

    alpha   = 1.2
    V0      = 2
    beta    = 20
    gamma   = 0.6
    zeta    = 0.3
    epsilon = 0.01

    # Handle division-by-zero issue
    temp = 0 if z == 1 else np.exp(-epsilon/(1 - z))

    OCV = V0 + alpha * (1 - np.exp(-beta * z)) + gamma * z + \
               zeta * (1 - temp)

    return OCV


# Global settings
vmax = 4.2

# Configure model parameters
R0 = 0.082
R1 = 0.158
C1 = 38000
q_max_ah = 5 # Cell capacity in amp-hours

# Simulation parameters
z0 = 0.95
dt = 1.0
sim_time_seconds = 20*3600
t_vec    = np.arange(0, sim_time_seconds, dt)
input_current_a = 1.0

# Initialize state variable vectors
I_vec    = input_current_a*np.ones(len(t_vec))
I_vec[t_vec > 3600] = 0
I_vec[t_vec > 6400] = 2.0
I_vec[t_vec > 9600] = -0.5
I_vec[t_vec > 20000] = 0
I_vec[t_vec > 30000] = 0.5

z_vec = np.empty(len(t_vec))
z_vec[:] = np.NaN

ocv_vec  = np.empty(len(t_vec))
ocv_vec[:] = np.NaN

v_vec = np.empty(len(t_vec))
v_vec[:] = np.NaN

I_r1_vec = np.empty(len(t_vec))
I_r1_vec[:] = np.NaN

# Initialize state variable values
z_vec[0] = z0
ocv_vec[0] = ocv(z0)
v_vec[0] = ocv(z0)
I_r1_vec[0] = 0

# Run the simulation
for k in range(0, len(t_vec) - 1):

    # SOC update
    z_vec[k+1] = z_vec[k] - dt/(q_max_ah * 3600) * I_vec[k]

    # Branch current update
    I_r1_vec[k+1] =      np.exp(-dt/(R1*C1))  * I_r1_vec[k] + \
                    (1 - np.exp(-dt/(R1*C1))) * I_vec[k]

    # OCV update
    try:
        ocv_vec[k+1] = ocv(z_vec[k])
    except ValueError:
        break

    # Terminal voltage update
    v_vec[k+1] = ocv_vec[k+1] - R1 * I_r1_vec[k] - R0 * I_vec[k]

    print(f'k = {k}, t = {t_vec[k]}s, ' +
          f'Vt = {v_vec[k]:.5f}V, ' +
          f'SOC = {z_vec[k]:.5f}')


# Visualize the results
fig, axs = plt.subplots(3, figsize=(8, 10), sharex=True)

axs[0].plot(t_vec, v_vec,
            marker='o', markersize=1,
            color='k')
axs[0].plot(t_vec, ocv_vec,
            marker='o', markersize=1,
            color='b')
axs[0].set_ylabel('Voltage (V)')
axs[0].legend(['$V_t$', '$V_{oc}$'])

axs[1].plot(t_vec, I_vec,
            color='k',
            marker='o', markersize=1)
axs[1].plot(t_vec, I_r1_vec,
            color='b',
            marker='o', markersize=1)

axs[1].set_ylabel('Current (A)')
axs[1].legend(['I', '$I_{R_1}$'])

axs[2].plot(t_vec, z_vec,
            marker='o', markersize=1,
            color='k')
axs[2].set_xlabel('Time (s)')
axs[2].set_ylim((0, 1))
axs[2].set_ylabel('SOC')

plt.savefig('res.png', dpi=300)






