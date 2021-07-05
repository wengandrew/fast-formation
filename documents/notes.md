# Fast Formation Meeting Notes





# 2021-06-14

- Add the CV plots as a supplementary; explain the statistical tests done on this.
- Remake Figure S6

# 2021-06-11

- ~~Plot x axis: retention, y axis: CV~~

# 2021-06-08

"finishing touches"

**
Results: aging variability**

\- ~~Include a discussion on the statistical significance of the aging variability.~~

**Results: R_10s**
\- ~~Include a discussion on "is R correlated to CE_f or Q_d?" (The answer is yes but it's weak because the signal to noise for the CE_f and Q_d are poor. This result is encouraging because it supports my theory that R is a more sensitive proxy for lithium lost during formation.~~)(not worth doing because the correlation is very weak; it's not any better than two dots; could be because discharge capacity measurement is just not that accurate.)

Anna: Some analysis of the voltage versus current accuracy, drifts etc might be needed here (signal to noise ratio issues). Are the cyclers that we need to use too expensive, to consider for all cell formation slots? Is it going to be again a quality control procedure where some cells are sampled but the check-process is very fast?

 \- Analyse and report the signal-to-noise of R vs CE_f



**Discussion overview:**
\- Discussion section will have the following structure: "we found a sensitive feature that shows significant difference in initial cell state due to formation protocol. We propose three possible links between this feature and physical changes in the initial cell state: more SEI consumption, lower cathode max lithiation, higher cathode potential at 100% SOC. We speculate how each of these links provide possible explanations to why fast formation improves cycle life but increases gas generation."

**Discussion Section 1: more SEI consumption**
\- Discuss takeaways from Peter's latest paper: the SEI that forms initially at low SOCs is a porous polymer involving reduction of ethylene carbonate; it is not passivating and pretty much useless while consuming lots of lithium (ref 11, 62-65). Better quality SEI can be formed with more time spent at high SOCs. Maybe we can control film quality through tailoring C-rate of "low" and "high" SOC region. 
\- Discuss "time" vs "C-rate" contribution to SEI quality by comparing these two factors baseline and fast. Which one could be more dominant? 
\- Discuss why the *quality* of the SEI must be changing because otherwise the fast formation cells would just be slightly further ahead in aging and would thus knee earlier.
\- Discuss linkage between initial SEI quality and prevention of pore clogging knee mechanism. Better quality SEI --> delayed onset of knees. Why do we not see this in the differences in CE over life? Maybe the lithium consumption rate is the same but the quality of the film is different.This is speculative but plausible.
**Section 2: cathode protection from overlithiation**
\- Include a supplementary figure showing that the cell resistance growth is slightly lower for the fast formation cells throughout the entire test. Speculate that this resistance growth is reflecting the cathode (cite at least Abraham2005, if not some more recent work).
**Section 3: increased cathode potential at 100% SOC**
\- Expand on gassing discussion: we find a large variability at high temperatures. This result is surprising given that X0 is not more variable between baseline and fast formation. We tried correlating the parameters to thickness with no success. TODO: Investigate the thickness versus final discharge capacity at the end of the test. The variation could be due to gas generation as well as gas consumption. (Elis 2017). It's possible that the consumption process is being modified too. This will get really complicated. More work is needed to fully elucidate the mechanism.





- Change "Reuse, Recycling, Second-life" to "End of Life"
- Cycle life testing; fast formation as previous papers alluded, last longer. 
- 179: break it out into sub-topics with bold sentence.
- Refer to (C)
- Change signal to noise





## 2021-05-19 Discussion with Anna

- Maybe skip Slide 2
- Try to improve Slide 3
- Insert Slide 9 a picture of the battery lab
- Insert Slide 11 $CE_f = Q_d / Q_c$
  - Say that the result is statistically significant
- Slide 15: read up about the authors previous and next
  - This is at the end of life. We don't know when the gas was generated. We did check several of them; the swelling hasn't changed.
- Slide 16: put the mechanism as the back-up or in the previous slide.
  - My talk is more about the data and the statistics



## 2021-05-14 Group Discussion

Tino, Peter, Peyman, Anna

~~"We found signals to distinguish between manufacturing process A or B"~~



### "Paper 2" - fast formation is complicated

**"Fast formation improves lifetime but higher variability and gas generation"**



**"We found diagnostic signals that help distinguish the impact of manufacturing process A vs B on the electrode-specific initial cell state"**



"Encapsulating the impact of manufacturing on initial cell state"

"Manufacturing signal --> cycle life" --> "Manufacturing --> $X_0$ --> cycle life"



### "Paper 1" - prediction

- With 70% retention target, dummy regressor is ~15%.

- Need to target lowering the model error from ~7-8% to ~5%. 

**"Very early in life identification of predictive features"**

- life prediction using <24 hours data versus life prediction using c56



**"Predicting lifetime due to process changes with constant operating conditions"**

- harder problem because of manufacturing variability instead of use case variability
- 'everyone drives their cars the same'

**"Assessing the risk for warranty"**



**Design of Experiments**

- What questions are left to answer?
- Explore different use cases
  - Too much loss in $C_n$ will eventually be bad for lithium plating. If you use your battery differently, it might make things worse



Can we use the predictive method to evaluate warranty?

TODO:

[ ] Change how the variability grows as a function of SOH



## 2021-05-14 Fast Formation Paper Draft Discussion

With Anna, Tino



- Figure: switch figures e) and f)
- Consider showing delta Q between c4 and c3

----



### Maccor accuracy

- Current accuracy: 0.05% of FSR (10A)
- Current accuracy: 0.02% of FSR (5A) --> 1mA --> 1mAh
- Voltage accuracy: 0.02% of FSR (xV)

### NB From Greg

- The other cells cycled at UMBL lasted 440 to 560 cycles

### Some formulae for PeakFind

Calculating $x_{100}$ from charge curves:
$$
x_{100} = SOC_1 + \frac{\mathrm{max}(q) - q_1}{C_n}
$$

$$
x_{100} = SOC_1 + (SOC_1 - SOC_2)\times\frac{\mathrm{max}(q)-q_1}{q_2-q_1}
$$

$$
C_n = \frac{q_1 - q_2}{SOC_1 - SOC_2}
$$



----

## 2021-05-07 Weekly Meeting

Some topics to discuss:

- Discuss how the correlations change over life
  - [ ] Calculate the expected error bar on R_10s based on voltage and current accuracy of Maccor
  - [x] Check Cn/Cp correlation over life
- Discuss how to tie "gas generation" mechanism from Paper 2 to the mechanisms proposed in Paper 1
- Discuss de-emphasis of "signals during formation"
- Discuss de-emphasis of "Delta V rest"

Feedback from Anna:

- Okay to publish with hypotheses

Feedback from Peyman:

- After knee Cn may limit cell capacity; lithium plating blocking access to graphite; you have apparent Cn loss
- Start outlining your observations into a new set of figure outlines
- Try plotting dV/dQ vs V instead of Q

Feedback from Peter:

- Do the draft now if only to check the story line by line

----

## 2021-05-01 Meeting with Anna

- Remove $\Delta$V metric
- Plot $C_n$ and $R_{10s}$ over cycle number
- Provide evidence of increased cathode strain at low SOCs
  - Read Peyman's paper
  - Check out cathode strain maps. Is the strain really higher at lower SOCs?

## 2021-03-23 - Fast Formation Paper Outline

### Paper 1: Using signals from formation improve lifetime prediction

Key contributions:

- We found beginning-of-life features that correlate to lifetime
  - $C_n$, DCR at low SOC, and Delta V_rest
- We discover that fast formation is decreasing Cn, which decreases the cathode utilization and helps life.
  - $C_n$ induces shifts in the relative stoic alignment of the two electrodes, creating the differences in DCR at low SOC and Delta V_rest, which explains why these signals are correlated to lifetime

Discussion:

- It's possible that these "lower $C_n$" cells could perform worse at higher C-rates due to plating. We didn't see this because we didn't go any higher than 1C charge.
- Supporting point for losing $C_n$: they are lithiated.
- Goldilocks: too much $C_n$ is bad (exposes cathode), too little $C_n$ is bad (lithium plating)
- Dashed lines -> correlation, solid lines --> casusation
- Use 70% cycle retention for "capacity at end of life"
- Why include room temperature? Correlations stronger at higher temperatures. Given no performance impact of high temperatures, maybe you'd want to do the characterization at high temps.

### Figure Outline

### Paper 1: Leveraging formation signals to quickly understand lifetime

Figure 1: graphical abstract

- Peter's idea: 
  - 1a) how to extract features from formation and RPTs (purple to red)
  - 2b) going from extracted features to end of life results

Figure 2: cycle life results plus the correlations to capacity retention

Figure 3: show how everything links together:

- mechanism explanation involving voltage and DCR alignment shifts
- include the correlation diagram

Figure 4: simplify the message / have a cartoon of the mechanism



**TODO:**

- [] Review digital twin paper (Alejandro Franco); it discussed why higher C-rates might be worst for particle stress
- MFG --> (BOL --> EOL)

### Paper 2: Fast formation degradation diagnostics

Key contributions:

- We discover that fast formation _can_ improve lifetime, but at a cost
  - Higher gas generation
  - Higher performance variability at end of life (can affect reuse)

Discussion:

- Choose 70% as end of life















----

## 2021-01-17 - Responses to Anna's comments

### Re: "All the cells were allowed to fully wet for 24 hours prior to beginning the formation process"

Greg noted that this is the standard procedure at battery lab. Other papers, including David Wood's papers, do not exceed more than a few hours at most for this step. 

The concern for this step is that the cell is at 0V for the entire 24 hours. At these potentials, dissolution of the copper (negative electrode) current collector is possible which could have a performance impact of cells. This is why manufacturers typically do a "tap charge" immediately after electrolyte fill to bring the cell voltage up to >1.5V as soon as possible. In our cells, no tap charge was performed, so the cells are ineeded at 0V for 24 hours. It is unclear how this could affect the interpretation of our results.

### Re: "driven by local non-uniformities in current density"

Question: does this refer to gradients? Yes.

### Re: change swelling/thickness plot to be less quantitative

I have thought about this and think it is better to keep it quantitative, because:

- It is impactful to make a statement about variatibility in gas generation. It supports the idea that increased variability in DCR is bad news. This conclusion can only be obtained from a plot of distributions.
- I trust that the variation in measured thickness is real because it is consistent with the pictures Greg took recently and it is consistent with Greg's original report.



----

## 2021-01-16 - Meeting with Anna

Notes on paper:
- Lithium plating and dendrites
  - Look at Jeff Sakamoto's group about lithium plating penetrating the separator
  - Wei Lu: paper on stopping dendrites; look at EIS
  - Neil: track lithium metal evolution and track with EIS
- Jing Sun and Hoffman: end of charge sinusoidal signals; better estimation of parameters
- Degradation model --> get an EIS signal
- Change the thickness plot to make it less quantitative
- Close with a positive. Understanding more early signals. Future work in Conclusions. There is a lot more to learn because of the cost of manufacturing.

Next steps:
- Potentially: more experiments; some uncertainty on if this will happen pending NSF
  - need to expand the different space of formation patterns
- Potentially: computational
- Path: EIS based diagnostics
- Drilling into SEI formation modeling; send the paper and put it in ArXiv

----

# 2021-01-xx - Theoretical capacity calculation

Positive electrode:

- double-sided loading: 34.45 mg/cm2 
- area: 7.2 cm x 11 cm = 76.2 cm2
- active ratio: 0.94
- number of layers: 8
- theoretical capacity: 160 mAh/g

Total capacity: 3.28 Ah



Negative electrode:

- double-sided loading: 15.7 mg/cm2
- Area: 7.2cm x 11 cm = 79.2 cm2
- active ratio: 0.97
- number of layers: 8
- theoretical capacity: 372 mAh/g

Total capacity: 3.59 Ah



N-P ratio: 3.59 Ah / 3.28 Ah = 1.095 (calculated)

N-P ratio: 1.07 (actual / reported by G. Less)



Measured first-cycle charge capacity: 2.75 Ah







## 2021-01-16 - Stack pressure estimation

Cell cycle life for pouch cells is typically considered to be a function of stack pressure. Reviewers may look for this information in the paper. The stack pressure for our cells is controlled by a spring-loaded fixture. The pressure is set by making sure the springs are at full compression prior to cycling.

Peyman and I went into the lab to estimate how much pressure this corresponds to. We tried a few approaches.

### Approach 1: Measure force using load cells

Load cells were attached to each spring. We measured a range of forces from the DAQ, including 93 lbf and 112 lbf. These values were averaged to be 100 lbf. Since there are four springs, the total force on the pouch is 400 lbf = 1779.3 Newtons. The area of the pouch cell is 107 mm x 70 mm = 0.00749 m^3. The corresponding pressure if 237.5 kPa.

### Approach 2: Measure spring constant.

We used a block of (stainless steel?) to compress four springs to estimate spring constant. We didn't know the mass of the block but estimated it to be 8.4 kg based on a density of 7,800 kg/m^3, height of 103.6mm and a dismeter of 115.3mm. The block is a cylinder. The measured deflection of the spring is estimated to be 12 mm (uncompressed) - 8.5 mm (compressed) = 3.5 mm. The spring constant is estimated to be equal to (m * g) / (4 * delta x), where m is the mass, g is the
gravitational constant, and delta x is the spring deflection. This number works out to be ~6000 N/m. 

The pressure on the cell is calculated to be 4 * k * delta x / A, where A is the area of the cell. This works out to be 23 kPa, one order of magnitude lower than the estimate from the force measurement.

Overall, we believe approach 1 gives a more accurate measure of the stack pressure so we will use this number.