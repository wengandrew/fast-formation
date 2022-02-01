"""
Equivalent circuit models for batteries
"""

import numpy as np
from matplotlib import pyplot as plt

def initialize_sim_vec(time_vec, initial_val=np.NaN):
    """
    Initialize a vector to store simulation results.
    Allows a user to specify the initial value.
    Set the remaining values to NaN.

    NaN is preferred to indicate 'no value present'

    Parameters
    ---------
    time_vec:    a Numpy array of dimension n
    initial_val: the initial value

    Returns
    ---------
    output_vec: a Numpy array of dimension n
    """

    output_vec = np.empty(len(time_vec))
    output_vec[:] = np.NaN
    output_vec[0] = initial_val

    return output_vec


def initialize_plot_settings(plt):

    font = {'family' : 'times',
            'weight' : 'normal'
           }

    plt.rc('font', **font)

    SMALL_SIZE = 16
    MEDIUM_SIZE = 20
    BIGGER_SIZE = 30

    plt.rc('font', size=SMALL_SIZE)          # controls default text sizes
    plt.rc('axes', titlesize=MEDIUM_SIZE)     # fontsize of the axes title
    plt.rc('axes', labelsize=MEDIUM_SIZE)    # fontsize of the x and y labels
    plt.rc('xtick', labelsize=MEDIUM_SIZE)    # fontsize of the tick labels
    plt.rc('ytick', labelsize=MEDIUM_SIZE)    # fontsize of the tick labels
    plt.rc('legend', fontsize=SMALL_SIZE)    # legend fontsize
    plt.rc('figure', titlesize=BIGGER_SIZE)  # fontsize of the figure title

def Up(sto):
    """
    Nickel Managanese Cobalt Oxide (NMC) Open Circuit Potential (OCP) as a
    function of the stochiometry. The fit is taken from Peyman MPM.
    References
    ----------
    Peyman MPM manuscript (to be submitted)

    Parameters
    ----------
    sto : Stochiometry of material (lithium fraction)
    """

    if sto < 0:
        raise ValueError('stoichiometry cannot be less than zero.')

    if sto > 1:
        raise ValueError('Stoichiometry cannot be greater than one.')

    u_eq = (
        4.3452
        - 1.6518 * sto
        + 1.6225 * (sto ** 2)
        - 2.0843 * (sto ** 3)
        + 3.5146 * (sto ** 4)
        - 2.2166 * (sto ** 5)
        - 0.5623e-4 * np.exp(109.451 * sto - 100.006)
    )

    return u_eq


def Un(sto):
    """
    Graphite Open Circuit Potential (OCP) as a function of the
    stochiometry. The fit is taken from Peyman MPM [1].
    References
    ----------
    .. [1] Peyman Mohtat et al, MPM (to be submitted)

    Parameters
    ---------
    sto : Stoichiometry of material (lithium fraction0)
    """

    if sto < 0:
        raise ValueError('stoichiometry cannot be less than zero.')

    if sto > 1:
        raise ValueError('Stoichiometry cannot be greater than one.')

    u_eq = (
        0.063
        + 0.8 * np.exp(-75 * (sto + 0.001))
        - 0.0120 * np.tanh((sto - 0.127) / 0.016)
        - 0.0118 * np.tanh((sto - 0.155) / 0.016)
        - 0.0035 * np.tanh((sto - 0.220) / 0.020)
        - 0.0095 * np.tanh((sto - 0.190) / 0.013)
        - 0.0145 * np.tanh((sto - 0.490) / 0.020)
        - 0.0800 * np.tanh((sto - 1.030) / 0.055)
    )

    return u_eq


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


def update_esoh(z, q_max, x100, y100, Cn, Cp):
    """
    OCV update equations for the eSOH OCV model

    Parameters:
    ---------
    z     : input state of charge
    q_max : maximum battery capacity in Ah
    x100  : neg. electrode stoichiometry at z = 1
    y100  : pos. electrode stoichiometry at z = 1
    Cn    : neg. electrode capacity
    Cp    : pos. electrode capacity

    Returns:
    ---------
    x     : updated neg. electrode stoichiometry
    y     : updated pos. electrode stoichiometry
    un    : updated neg. electrode potential
    up    : updated pos. electrode potential
    ocv   : updated full cell potential
    """

    Qd = (1 - z) * q_max
    y = y100 + Qd / Cp
    x = x100 - Qd / Cn
    up = Up(y)
    un = Un(x)
    ocv = up - un

    return (x, y, un, up, ocv)


def update_ocv(z):
    """
    OCV upate equation for the basic OCV model

    Parameters:
    ---------
    z: input state of charge

    Returns:
    ---------
    OCV at z
    """

    return ocv(z)


# Global settings
vmax = 4.2

# Configure model parameters

# R-RC parameters
R0 = 0.082
R1 = 0.158
C1 = 38000
q_max_ah = 5 # Cell capacity in amp-hours

# eSOH parameters
Cn = 5
Cp = 6
x100 = 0.9
y100 = 0.2

# Simulation parameters
z0               = 0.95    # Starting SOC
dt               = 1.0
sim_time_seconds = 30*3600 # Total simulation time
t_vec            = np.arange(0, sim_time_seconds, dt)

# Initialize simulation input vector
I_vec    = np.zeros(len(t_vec))
I_vec[t_vec > 3600] = 1.0
I_vec[t_vec > 6400] = 2.0
I_vec[t_vec > 9600] = -0.5
I_vec[t_vec > 20000] = 0
I_vec[t_vec > 30000] = 0.5
I_vec[t_vec > 14 * 3600] = -0.25

res = update_esoh(z0, q_max_ah, x100, y100, Cn, Cp)
ocv0 = res[4]

# Initialize simulation output vectors
z_vec    = initialize_sim_vec(t_vec, z0)
vt_vec   = initialize_sim_vec(t_vec, ocv0)
ocv_vec  = initialize_sim_vec(t_vec, ocv0)
I_r1_vec = initialize_sim_vec(t_vec, 0);
x_vec    = initialize_sim_vec(t_vec, x100 - (1 - z0) * q_max_ah / Cn)
y_vec    = initialize_sim_vec(t_vec, y100 + (1 - z0) * q_max_ah / Cp)
un_vec   = initialize_sim_vec(t_vec, Un(x_vec[0]))
up_vec   = initialize_sim_vec(t_vec, Up(y_vec[0]))


# Run the simulation
for k in range(0, len(t_vec) - 1):

    # SOC update
    z_vec[k+1] = z_vec[k] - dt/(q_max_ah * 3600) * I_vec[k]

    # Branch current update
    I_r1_vec[k+1] =      np.exp(-dt/(R1*C1))  * I_r1_vec[k] + \
                    (1 - np.exp(-dt/(R1*C1))) * I_vec[k]

    # OCV update
    try:
        # OCV model update
        # ocv_vec[k+1] = update_ocv(z_vec[k])

        # eSOH model update
        res = update_esoh(z_vec[k+1], q_max_ah, x100, y100, Cn, Cp)
        x_vec[k+1]   = res[0]
        y_vec[k+1]   = res[1]
        un_vec[k+1]  = res[2]
        up_vec[k+1]  = res[3]
        ocv_vec[k+1] = res[4]

    except ValueError:
        break

    # Terminal voltage update
    vt_vec[k+1] = ocv_vec[k+1] - R1 * I_r1_vec[k] - R0 * I_vec[k]

    print(f'k = {k}, t = {t_vec[k]}s, ' +
          f'Vt = {vt_vec[k]:.5f}V, ' +
          f'SOC = {z_vec[k]:.5f}')

# Visualize the results
initialize_plot_settings(plt)

fig, axs = plt.subplots(3, figsize=(12, 10), sharex=True)

# Voltages and Potentials
axs[0].plot(t_vec/3600, vt_vec,
            linestyle='--',
            color='k')
axs[0].plot(t_vec/3600, ocv_vec,
            marker='o', markersize=1,
            color='k')
axs[0].plot(t_vec/3600, up_vec,
            marker='o', markersize=1,
            color='b')
axs[0].plot(np.NaN, np.NaN, color='r') # dummy, for legend

ax_neg = axs[0].twinx()

ax_neg.plot(t_vec/3600, un_vec,
            marker='o', markersize=1,
            color='r')

ax_neg.tick_params(axis='y', colors='r')
ax_neg.set_ylabel('$U_n$ (V vs $Li/Li^+$)')
ax_neg.yaxis.label.set_color('red')

axs[0].set_ylabel('Voltage (V)')
axs[0].legend(['$V_t$', '$V_{oc}$', '$U_p$', '$U_n$'])

# Currents
axs[1].plot(t_vec/3600, I_vec,
            color='k',
            marker='o', markersize=1)
axs[1].plot(t_vec/3600, I_r1_vec,
            color='b',
            marker='o', markersize=1)

axs[1].set_ylabel('Current (A)')
axs[1].legend(['$I_{applied}$', '$I_{R_1}$'])

# SOC and Lithium Stoichiometries
axs[2].plot(t_vec/3600, z_vec,
            marker='o', markersize=1,
            color='k')

axs[2].plot(np.NaN, np.NaN, color='r') # dummy, for legend
axs[2].plot(np.NaN, np.NaN, color='b') # dummy

axs[2].set_xlabel('Time (hr)')
axs[2].set_ylim((0, 1))
axs[2].set_ylabel('SOC')

ax_stoic = axs[2].twinx()

ax_stoic.plot(t_vec/3600, x_vec,
              color='r',
              marker='o', markersize=1)

ax_stoic.plot(t_vec/3600, y_vec,
              color='b',
              marker='o', markersize=1)

ax_stoic.set_ylabel(r'$\theta$')
ax_stoic.set_ylim((0, 1))
ax_neg.set_xlim(axs[0].get_xlim())

axs[2].legend(['SOC', r'$\theta_n$', r'$\theta_p$'])

plt.tight_layout()
plt.savefig('res.png', dpi=300)
