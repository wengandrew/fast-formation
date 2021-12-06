# Meeting Notes

## 12/06/2021

Topics covered today:

- EIS


## 11/29/2021

Announcements:

- Requirements for report due on Dec 10th will be relaxed due to time constraints. More details will be shared in person.

Topics covered today:

- Review of sources of battery resistance
- Derive OCV-R-RC model
- A brief look into electrochemical impedance spectroscopy (EIS)


## 11/15/2021

Announcements:

- Four weeks remaining until reports are due (Dec 10th)
  - Suggestion: finalize figures over next two weeks
- All meetings this week will be held via Zoom

Topics covered today:

1. Feedback: what's going well, what's not going well
2. Inserting figures and references in Overleaf
3. Introduction to kinetic processes in lithium batteries
  - Thermodynamics vs kinetics: where does battery 'resistance' come from?
    - Contribution from different battery components
      - inactive components (current collectors, tabs), electrolyte, active material (cathode, anode)
    - Separation of time scales: ohmic, charge transfer, diffusion
    - A closer look at the voltage response to a unit current step
  - Crash course on electrochemical impedance spectroscopy (EIS)
    - Separation of timescales: slow, fast
4. HPPC data parsing
  - Scaling capacity from a coin cell to a full cell

## 11/8/2021

Today, we will discuss work assignment for the rest of the semester.

By the end of the semester, you will deliver two products:

1. A report in the style of a journal paper
2. The accompanying code that you wrote (`.py` files, `.ipynb` files)

You will submit the work in the form of a Pull Request on Github. Details of the submission will be covered in a future week.

We will spend the rest of this hour discussing some details of the content that is expected from the report and the tools you will use to generate it.

The bulk of your work for the remaining weeks will be:

1. Clearly defining the cell dataset and performance metrics you wish to analyze
2. Writing the code necessary to make the plots for (1)
3. Writing, editing, and submitting the report

### Report Writing

#### Overview

You will write a report summarizing the purpose of your study, the main results you've found, your interpretation of the results, and the next steps. The length and level of detail of your report is up to you and depends on your time availability over the next four weeks. At a minimum, a Pull Request with a report and the accompanying code must be submitted via GitHub by **December 10th**. 

For the content of the report, we will continue to work together on an individual basis to define what are the interesting results to report. During the one-on-one sessions for the upcoming weeks, we will keep in tight communication to define clearly what is reasonable to get done and what is beyond the scope for this semester.

The following content is recommended as a bare minimum:

1. All common sections of the report are included (see 'Report Sections').
2. At least 5 figures
3. At least 5 references
4. The report addresses at least two research questions relating to your data
5. Under *results*, you present the data clearly (in a figure or a table)
6. Under *discussion*, you provide a reasonable interpretation of what the data means and discuss implications
7. Under *discussion*, you provide at least two next steps which logically follow from the analysis


#### Style

The report will be in the style of a journal paper. Due to time limitations, you are recommended to focus on the *results* and *discussion* sections first. A literature review is recommended but not expected due to the limited time we have. You should still survey and cite at least 5 papers that are relevant to your work. This can be accomplished with a quick Google Search.

Here are some reference papers that you can model your report from. Download these.
- [ ] An article on coin cells: https://iopscience.iop.org/article/10.1149/2.0691614jes
- [ ] An article on battery characterization: https://onlinelibrary.wiley.com/doi/full/10.1002/er.7445
- [ ] Another article on battery characterization: https://www.mdpi.com/2313-0105/7/3/51

Aside: how did I pick these papers? The topics for the papers are somewhat similar to the subject matter we are dealing with. The papers are also written in a way that I felt was approachable given the topics we covered. You will *not* find a perfect match between the topics covered in these papers and the topics we are writing about (otherwise what's the point of us writing about our papers?) The main purpose of providing these references is for you to get a general sense of the main sections in a paper, what do published figures look like, and the writing style for academic papers. You can also include these papers in your references if you feel they are relevant to your report.

Instructions for downloading the papers:
- Use the library: https://search.lib.umich.edu/onlinejournals
- Save them locally as PDFs.

Recommendation:
- [ ] Download Mendeley, a popular reference manager. 
- You will need Mendeley later to export a `.bib` file that will help you automate citations tracking in your report.
- For every paper that you find, download the paper (PDF) onto your computer, then add it to your Mendeley library.

#### Sections 

- Summary or Abstract
  - **Do this last**. As you start writing, the most important question to keep in mind is "what are the main questions you are trying to answer with this report?"

- Introduction 
  - **Do this last**. 
  - The introduction generally includes a background (for a 'skilled' reader) and a literature review of what was done in the past.
  - Introduce the main knowledge gaps that you will address in this work. Why are they important questions to answer.
  
- Experimental Methods
  - **Do this after Results and Discussion are completed.**
  - Write down what you know about what was done experimentally. Cite other papers where relevant. Since you entered the project mid-way through, you are not expected to know every little detail about how the cells were prepared. I can help fill in the details if you ask.
  
- Results
  - **This should take up at least 50% of your time.**
  - The main plots you generate should go into this section.
  - In the text, describe what you observe.
  
- Discussion 
  - **Do this after you complete a draft of the results section**. 
  - Due to time constraints, you are not expected to provide a super insightful analysis (though you are obviously encouraged to do so). The expectation is that you think about the results you present and share your thoughts in this section.
  - Limitations
  - Assumptions
  - Future Work
  
- Conclusion 
  - Summarize your main findings. Stick to facts, not speculation. Briefly outline the next steps.      

#### Editing

Editing your writing is important. There are three stages of writing:
1. Write for yourself
2. Revise your message for people who care
3. Proof for clarity

Normally, steps (2) and (3) will take a significant amount of time to complete. While we are time-constrained on this project, you should go through steps (1-3) at least once. I am here to help with steps (2) and (3) if you ask for help.

Reference: https://medium.com/creators-hub/how-to-use-writing-to-improve-your-thinking-22e09fa01e04


#### Formatting

You will use **Overleaf** to write the report. Overleaf is an online LaTeX editor. LaTeX is a common typesetting system used for scientific documentation. LaTeX is useful when you have to write a lot of mathematical formulas. We will not spend time learning about how to write formulas in LaTeX (and for your reports, there will not be many, if any, equations for you to worry about). 

I will provide you a document template in the coming weeks. We may also review the basics to get started with writing the report.

For now:

- [ ] Create an Overleaf account using your University of Michigan email.

### Getting back to the data

Let's take the remaining time to discuss the main questions we want to answer from the data and what are the relevant metrics that will help us answer these questions.

### For future meetings

- [ ] Overleaf tutorial: getting started with the project report
- [ ] Strategies for effective data parsing using Python and Pandas
- [ ] Equivalent circuit modeling for batteries
- [ ] Electrode-specific state of health metrics


## 10/25/2021

We discussed a few topics together:

1. "Static vs dynamic" view of knowledge; finding and understanding papers
2. Review of battery components and the idea of lithium stoichiometry
3. Breaking apart the full cell OCV curve into positive and negative curves

Logistics:

- No meeting next week
- Start making progress with plotting the raw data
- In future weeks, start sharing some results during the group meetings

## 10/6/2021

Topics:
1. Assign projects
2. Review battery key performance metrics
3. Assign tasks for the coming weeks

## Project Assignments

Project 1: Fast Formation Cells at End-of-Life
- Assigned to Roger

Project 2: Coin Cell Characterization
- Assigned to Iaroslav

Project-specific next steps will be reviewed in person during office hours.


## Battery Performance Metrics

Let's divide battery metrics into three broad categories: (1) performance, (2) lifetime, (3) safety.


### Performance

| User (e.g. phone) | User (e.g. car) | Battery |
| ----------------- | --------------- | ------- |
| 'charge'          | range (miles)   | capacity / energy |
| recharge speed    | recharge speed  | resistance / it's complicated |
| -                 | max acceleration | resistance / it's complicated | 

#### Capacity

- The open circuit voltage (OCV) curve
- Voltage limits
- Capacity vs gravimetric capacity vs volumetric capacity
- Going from capacity to energy using integral method vs average voltage


#### Resistance

- Consider the most basic battery model: OCV-R
- Ohm's law
- Impact of current (C-rate) on measured capacity



### Lifetime

| User (e.g. phone) | User (e.g. car) | Battery | 
| ----------------- | --------------- | ------- |
| 'Battery life'    | 'Battery life ' | cycle number to x% of initial capacity / it's complicated |


#### Cycle Life

- Charge/discharge cycling
- Capacity (or energy) over cycles
- Capacity fade mechanisms
- Resistance growth


### Safety

(Did not cover)

| User (e.g. phone) | User (e.g. car) | Battery |
| ----------------- | --------------- | ------- |
| Will not catch on fire | will not catch on fire | it's complicated |

#### Safety Characterization

- Common battery failure modes
- Methods for inducing battery failure and characterizing the thermal event

### More Advanced Topics

(Did not cover)

- Take everything we just discussed and now consider the battery as a system comprising multiple electrochemically active components: (1) cathode, (2) anode, (3) electrolyte


### For Next Week

- Get started on working with the datasets



### Knowledge Checks

- What conventional units for capacity and energy?
- What is the relationship between capacity and energy?
- How do you convert from vehicle range to energy?
- Some common plots you will see in literature
  - Ragone plot: comparing energy and power of different battery systems
  - Cycle life plots: usually capacity versus cycle number


## 10/4/2021


### Discussion

### Notes

- We met up in GGB and got introduced to each other
- Reviewed the contents of the project homepage (GitHub repository)
- Discussed the list of TODO's for next week
  - Most important:
    - watch the YouTube lecture on batteries and attempt to answer the 'Battery Knowledge Check' questions
    - read through the project list description and try to make sense of what would be the next steps
    - set up your GitHub account and try to get the code running locally on your machine

#### Milestones

Looking ahead, here's where we're going:

1. Get oriented
2. Pick a project
3. Make progress on project
4. Present your work


### TODO's

#### Tools

- [ ] Get access to the Dropbox raw data path 
- [ ] Set up your GitHub account 
- [ ] Clone this repository: https://github.com/wengandrew/fast-formation 
- [ ] Set up your paths and local environment and get the code running 
- [ ] You will need to download the raw data files from here: https://doi.org/10.7302/pa3f-4w30
- [ ] Do all of the tests pass? (`python -m pytest`)


#### Social

- [ ] Join our Slack workspace and introduce yourself in #general 
- [ ] Get your profile picture added to our website


#### Research

- [ ] Set up a Mendeley account 
- [ ] Get access to the shared Mendeley Group (ask Andrew)


#### Battery Knowledge Check

- [ ] Watch this video: https://www.youtube.com/watch?v=DBLHaLhyo2w

- [ ] What is the chemistry of the pouch cells that we built at the University of
    Michigan? (Hint:
    https://iopscience.iop.org/article/10.1149/MA2021-015271mtgabs)

- [ ] When a battery is charged, does lithium go from the cathode or the anode?

- [ ] If you discharge a 5 Ah battery at 0.5 Amps, what is the equivalent C-rate?
  - [ ] Approximately how long will it take for this battery to fully discharge?
 
- [ ] What is there relation between a battery's energy, capacity, and voltage?

- [ ] What is the typical unit used to express a battery's capacity and energy?


(More advanced)

- [ ] What is the role of the separator in a battery? 
  - [ ] What is the separator typically made of?

- [ ] What is the role of the electrolyte in a battery?

- [ ] How is SOC defined for the full cell? 
  - [ ] What is the equivalent concept for "SOC" for a half cell?

- [ ] How is the cell capacity measured? What are some factors that determine this
value?

- [ ] When is battery voltage a reflection of the thermodynamics of a system
   versus the kinetics of the system? 
  - [ ] What are some factors that determine the kinetics of a battery system?

- [ ] What is the relationship between the measured full cell voltage and the
individual electrode-specific potentials?

- [ ] What are some of the basic performance metrics of batteries? How are these
properties measured? Which one of them are temperature-dependent? Which one of
them are SOC-dependent?


## Future Meetings

### TODO's

- [ ] Lab tour
- [ ] Share Joule paper
