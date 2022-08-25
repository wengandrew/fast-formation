"""
Utility functions for dV/dQ analysis
"""

import numpy as np
from matplotlib import pyplot as plt
from scipy import interpolate
from scipy.optimize import fsolve


def f_pos_ocv(sto):
    """
    Nickel Managanese Cobalt Oxide (NMC) Open Circuit Potential (OCP) as a
    function of the stochiometry. The fit is taken from Peyman MPM.
    References
    ----------
    Peyman MPM manuscript (to be submitted)
    Parameters
    ----------
    sto : :class:`pybamm.Symbol`
       Stochiometry of material (li-fraction)
    """

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


def f_neg_ocv(sto):
    """
    Graphite Open Circuit Potential (OCP) as a function of the
    stochiometry. The fit is taken from Peyman MPM [1].
    References
    ----------
    .. [1] Peyman Mohtat et al, MPM (to be submitted)
    """

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


def esoh_to_voc(x100, y100, Cn, Cp, q):
    """
    Convert (x100, y100, Cn, Cp, C) to Voc(q), Un(x), Up(y)

    Parameters:
    ---------
    x100: negative electrode stoichiometry at 100% SOC
    y100: positive electrode stoichiometry at 100% SOC
    Cn:   negative electrode capacity (Ah)
    Cp:   positive electrode capacity (Ah)
    q:    full cell capacity vector (Ah)

    Outputs:
    ---------
    Voc(q):
    Un(x):
    Up(y):

    """

    # Map full cell capacity to pos. (y) and neg. (x) stoichiometries
    y = y100 + (np.max(q) - q) / Cp
    x = x100 - (np.max(q) - q) / Cn

    # Alternate method if x0 and y0 are given
    # y = y0 - q / Cp
    # x = x0 + q / Cn

    # Calculate the full cell open circuit potential
    Voc = f_pos_ocv(y) - f_neg_ocv(x)

    return (Voc, f_pos_ocv(y), f_neg_ocv(x))


def deg_to_esoh(Cn, Cp, nlli, Vmax):
    """
    Convert degradation parameters (Cn, Cp, nlli) to esoh parameters
    (x100, y100, Cn, Cp)

    Parameters:
    ---------
    Cn: positive active material (Ah)
    Cp: negative active material (Ah)
    nlli: moles of lithium consumed
    Vmax: maximum full cell voltage constraint

    Outputs:
    ---------
    x100
    y100
    """

    F = 96485.33212 # Coulombs per mole

    x100_init = 0.9

    f_to_solve = lambda x100 : Vmax \
                              - f_pos_ocv( (1 / Cp) * ( (F * nlli / 3600) - x100 * Cp ) ) \
                              + f_neg_ocv( x100 )

    x100 = fsolve(f_to_solve, x100_init)

    y100 = (1 / Cp) * (F * nlli / 3600 - x100 * Cn)

    return (x100, y100)


def deg_to_voc_graphical(lam_pe, lam_ne, lli, Cp, Cn):
    """
    Convert degradation vector (LAM_PE, LAM_NE, LLI) to Voc

    Parameters:
    ---------
    lam_pe  : loss of active material in the positive electrode (%)
    lam_ne  : loss of active material in the negative electrode (%)
    lli     : loss of lithium inventory (Ah)
    Cp      : initial positive electrode capacity (Ah)
    Cn      : initial negative electrode capacity (Ah)

    Outputs:
    ---------
    Voc(Q)   : full cell open circuit potential
    Un(Q)    : negative electrode open circuit potential
    Up(Q)    : positive electrode open circuit potential
    capacity : shared capacity basis (Ah)
    """

    # Initial positive and negative stoic curves
    y_vec = np.linspace(0, 1, 1000)
    Up_vec = f_pos_ocv(1 - y_vec) # Cathode stoic is flipped!

    x_vec = np.linspace(0, 1, 1000)
    Un_vec = f_neg_ocv(x_vec)

    # Convert the stoic curves to capacity curves
    Cp_vec = np.linspace(0, Cp * (1 - lam_pe), 1000) - lli
    Cn_vec = np.linspace(0, Cn * (1 - lam_ne), 1000)

    # Expanded capacity vector
    capacity = np.linspace(np.min([np.min(Cp_vec), np.min(Cn_vec)]),
                           np.max([np.max(Cp_vec), np.max(Cn_vec)]), 1000)

    # Expanded voltage vectors
    fp = interpolate.interp1d(Cp_vec, Up_vec, bounds_error=False)
    Up_vec_interp = fp(capacity)

    fn = interpolate.interp1d(Cn_vec, Un_vec, bounds_error=False)
    Un_vec_interp = fn(capacity)

    Voc = Up_vec_interp - Un_vec_interp

    return (Voc, Un_vec_interp, Up_vec_interp, capacity)

    # Extract theta values
    # VMIN = 3.0
    # VMAX = 4.2

    # q0_ref = np.interp(VMIN, U, C)
    # q100_ref = np.interp(VMAX, U, C)

    # theta_p_0 = 1 - (np.interp(q0_ref, Cp_vec, Up_vec)) / Cp
    # theta_p_100 = 1 - (np.interp(q100_ref, Cp_vec, Up_vec)) / Cp

    # theta_n_0 = q0_ref / Cn
    # theta_n_100 = q100_ref / Cn


def make_plot(q, Voc, Up, Un):
    """
    Standard plotter given a set of voltage vectors

    Parameters:
    ---------
    q:   shared capacity basis (Ah)
    Voc: full cell open circuit voltage
    Up:  positive electrode equilibrium potential
    Un:  negative electrode equilibrium potential
    """

    plt.figure(figsize=(6, 6))

    plt.subplot(211)
    plt.plot(q, Voc)
    plt.plot(q, Up)
    plt.plot(q, Un)
    plt.ylim((0, 5))
    plt.xlabel('Capacity (Ah)')
    plt.ylabel('Voltage (V)')
    plt.yticks([0, 0.2, 0.5, 1.0, 2.0, 3.0, 3.5, 4.0, 4.2, 4.4])
    plt.grid(axis='y', c=(0.9, 0.9, 0.9))

    plt.subplot(212)
    plt.plot(q, np.gradient(Voc)/np.gradient(q)*np.max(q))
    plt.plot(q, np.gradient(Up)/np.gradient(q)*np.max(q))
    plt.plot(q, -np.gradient(Un)/np.gradient(q)*np.max(q))
    plt.xlabel('Capacity (Ah)')
    plt.ylabel('dV/dQ (V/Ah)')
    plt.ylim((0, 2.5))
