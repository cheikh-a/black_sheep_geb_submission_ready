# Simulation Design

## Objective

The simulations are designed to do four distinct jobs:

1. reproduce the first honest-shock accounting exactly;
2. generate endogenous patron-thief contracting under wealth heterogeneity;
3. generate endogenous switching from patronage to guarding;
4. classify parameter regions into distinct regimes.

## Languages and build

- Language: R throughout
- Entry points:
  - `src/03_simulate_baseline.R`
  - `src/04_simulate_patronage.R`
  - `src/05_simulate_enforcement.R`
  - `src/06_parameter_sweeps.R`
- Figure build: `src/07_make_figures.R`
- Table build: `src/08_make_tables.R`
- Full build: `make all`

## State variables

- `id`: agent identifier
- `wealth`: current wealth
- `role`: one of `honest`, `stay`, `freelance_thief`, `hired_thief`, `patron`, `guard`, `elite`, `inactive`
- `forced_honest`: indicator for exogenously honest agents
- `guarded_by`: guard assigned to an elite if applicable
- `time`: period index

## Baseline perturbation algorithm

1. Initialize all agents with wealth `1`.
2. Fix the honest set exogenously.
3. Keep the original cycle structure intact for the active thieves.
4. On each date:
   - forced-honest agents stay home;
   - all others steal if their wealth is at or below the baseline threshold;
   - if a target is occupied, the theft fails;
   - otherwise one unit is transferred.
5. Record the realized first-night gain and loss pattern.

## Patronage algorithm

1. Run the deterministic first honest night to generate the initial asymmetry.
2. From period 2 onward:
   - compute the rich threshold `theta_R = rich_multiplier * mean wealth`;
   - compute the elite threshold `theta_E = elite_multiplier * mean wealth`;
   - classify poor and rich agents accordingly.
3. Rich agents are ordered by wealth and compare:
   - personal theft,
   - staying home,
   - hiring a thief,
   - and, when enabled, hiring a guard.
4. Available workers are drawn from the poorest currently poor agents.
5. Patron-thief contract terms are built from:
   - gross delegated loot,
   - a poor thief outside option,
   - a fixed wage floor,
   - a patron loot share,
   - and contracting cost.
6. Hired thieves target richer poor households than freelancers.
7. Freelancers target households according to expected loot and vulnerability.
8. Theft is sequential within the period, so multiple hits on the same house reduce remaining wealth for later attackers.

## Enforcement algorithm

1. Enable the guard action.
2. Elite agents hire guards when expected protected wealth exceeds expected net delegated theft income.
3. Guarded houses are much harder to rob.
4. Failed raids on guarded houses trigger punishment probabilistically.
5. Once guards appear, the regime is classified as either `Guard regime` or `Coexistence`, depending on whether patronage remains active.

## Parameter sweeps

### Regime map

- Parameters:
  - theft intensity `gamma`
  - enforcement effectiveness `1 - guard_success_prob`
- Outcome:
  - dominant regime in the tail of the simulated path

### Contract grid

- Parameters:
  - targeting advantage
  - slackness among poor thieves
- Outcomes:
  - patron surplus
  - thief compensation
  - outside option

### Transition timing

- Parameter:
  - number of initial honest agents
- Outcomes:
  - time to first patron
  - time to first guard

### Robustness panel

- Parameters varied one at a time:
  - `gamma`
  - `contract_cost`
  - `occupancy_success_prob`
  - `target_advantage`
- Outcomes:
  - final Gini
  - final utilitarian welfare

## Reproducibility guarantees

- deterministic seeds are set in `default_parameters()`;
- all processed outputs are written to `data/processed/`;
- all figures are generated from processed outputs and exported to both `output/figures/` and `paper/figures/`;
- all tables are generated from processed outputs and exported to both `output/tables/` and `paper/tables/`.

