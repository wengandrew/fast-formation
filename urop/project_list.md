# Project List

Last updated 10/4/2021.


## Characterizing Fast Formation Cells at the Extreme End of Life

Last year, 40 prototype pouch cells were built at the University of Michigan
Battery Lab. The original purpose of the study was to evaluate the impact of
fast formation protocols on battery lifetime (see:
https://iopscience.iop.org/article/10.1149/MA2021-015271mtgabs ).

At the end of this study, all 40 cells had less than 50% of its initial capacity
and were archived in shelves. While the original study has concluded, the aged
cell samples generated from this study offers a rare opportunity to characterize
the behavior of aged cells at the 'extreme' end-of-life. (Under real
applications, the cells could take many years to reach this state, but since the
cells were aged using accelerated cycle life testing, the cells reached
end-of-life within months of testing.)

The goal of this work is to explore the cell performance characteristics of
these end-of-life cells. You will identify a set of relevant cell performance
characteristics and design characterization tests to measure them. Extracted
performance metrics will be compared against the same cells at the beginning of
life. The impact of the aging on these cell characteristics will be understood.
Since the cells were formed using two different formation protocols ('fast' and
'baseline'), you will also study if the formation protocol had any influence on
the aged cell characteristics.

There already exists a set of data collected on some of these cells. I suggest
you start by exploring this dataset. You will need to write parsers to extract
the relevant performance metrics out of this data.

There is also opportunity to run more characterization. Some of the aged cells
are still sitting on shelves in a cabinet. There is a general fire safety hazard
with cycling these very aged cells so we will need to take caution if we go in
this direction.


## Coin Cell Characterization: Unraveling Electrode-Specific Cell Properties

Battery state estimation over life is very challenging because the internal
state of each individual electrode evolves differently over a battery's life.
For example, the cathode could lose active material at a faster rate than the
anode. The evolution of these electrode-level state variables manifest in the
full cell level in ways that can be mathematically modeled. However, for our
models to be accurate, we need to understand exactly how the state parameters of
each individual electrode evolve over lifetime. Enter measurements.

Electrode-level state variables are generally not observable through full cell
measurements. However, through clever experimental techniques, there are ways to
directly measure electrode properties. One common way to study the properties of
an individual electrode (e.g. cathode or anode) is through the usage of half
cells. Half cells consists of a working electrode (the electrode you are trying
to study) and a counter-electrode. The counter electrode for lithium ion
batteries is typically lithium metal. The voltage you measure from a half-cell
with a lithium metal counter electrode is the potential of your working material
versus lithium. In literature, you will typically see this potential reported as
"V vs Li/Li+".

Last month, we worked with the University of Michigan Battery Lab to build nine
coin cells. These cells consists of three sets of graphite anodes, nickel
manganese cobalt (NMC) cathodes, and lithium iron phosphate (LFP) cathodes. The
presence of the three duplicate cells is because there is generally high
cell-to-cell variability in the coin cell form factor. We will want to
understand how the coin cell measurements deviate from cell to cell. Finally,
the lithium metal counter-electrode is a source of side reactions with the
electrolyte. This side reaction rate is typically not representative of the
environment in a full cell where there is no lithium metal reservoir. Therefore,
we are also interested in learning about how quickly the coin cells degrade
(e.g. through repeated capacity checks).

We have already been collecting various performance data on these cells. The
first step in this project would be to understand what data has already been
collected and continue running experiments to make sure we will collect all of
the data needed to answer the above questions. In parallel, parser scripts will
need to be written to extract meaningful metrics from the data. Only after the
parser scripts are written can we begin to interpet and analyze the datasets in
more detail. Eventually, this data will be used to build physical models of
battery performance.


## Non-Monotonic Current Decay During CV Hold: Measuring the Micro using the Macro

(This is an advanced project.)

The goal of this project is to develop a physical understanding of a candidate early-life
diagnostic signal that could indicate the presence of lithium plating inside
batteries. Lithium plating can lead to battery fires so the detection thereof is
a very hot topic (no pun intended). Methods to detect lithium plating exist, but
such methods typically rely on an excessive amount of lithium plating to
guarantee sufficiently large signal-to-noise. For small amounts of local lithium
plating, it is generally difficult for such signatures to be resolvable from
current-voltage traces. Yet, even small amounts of local lithium plating can be
consequential to battery pack safety.

Some theoretical foundations and physical insights will need to be established
to make progress on this project. In parallel, I am looking for help to
exhaustively search for the presence of this non-monotonic current decay signal
in all of our cells. This project could span multiple datasets, but it makes
sense to begin with the fast formation dataset. I have already seen at least one
instance of this signal for one of our cells.


## How Lithiated Are Cathode and Anode Particles During Active Material Loss?

(This is an advanced project.)

Electrode stoichiometry models must be precise since this model sets the
thermodynamic basis for all subsequent battery dynamics modeling. It is
impossible to achieve an accurate battery dynamics model without first making
sure the stoichiometry model is accurate.

There is an unresolved question in electrode stoichiometry models for aged
battery systems: when cathode and anode active material is lost, how much of the
particle is filled with lithium? The answer to this question is crucial since it
affects the accounting of lithium inventory loss in the stoichiometry model.
Different assumptions (i.e. if the particles are fully lithiated versus fully
delithiated) lead to different stoichiometry alignments. The resulting
dynamical battery state predictions depend on these alignments.

The first step of this project is to demonstrate that the impact of electrode lithiation
during active material loss does has a large impact on the electrode stoichiometries.
We will need to develop some mathematical relationships between active material loss types 
(e.g. while lithiated versus delithiated) and the translations and shifting of the 
electrode equilibrium potential curves. The Python Mathematical Modeling (PyMAMM) framework 
can be used to conduct the numerical simulations of battery dynamics.

We also seek experimental evidence to confirm possible states of
lithiation during the active material loss event. We may need to partner up with
some wet labs to design the right experiment for this work.
