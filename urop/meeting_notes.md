# Meeting Notes

## 10/19/2021

Topics: TBD

- More on cell aging characterization
- More on cell aging mechanisms
- Writing cell data parsers

## 10/12/2021

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
