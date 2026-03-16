# Revision Plan: `No Country for Honest Men`

## 1. Core contribution of the current draft

- The paper isolates a striking benchmark: a society of symmetric thieves can sustain a balanced reciprocity arrangement in which theft is universal yet net wealth remains equal.
- It uses Calvino's fable not as decoration but as a structured thought experiment about equilibrium fragility: a single honest deviation can destroy a convention that looks stable from within.
- It links the breakdown of reciprocal theft to endogenous wealth dispersion rather than treating inequality as exogenous.
- It argues that inequality changes incentives: once some agents accumulate surplus, protecting wealth dominates direct predation.
- It identifies a second transition from decentralized theft to delegated theft, with rich agents acting as patrons and poor agents acting as thieves for hire.
- It interprets the final transition to policing as endogenous institution formation: enforcement appears when elite protection becomes more valuable than additional predation.
- The paper's best idea is therefore a sequence of regimes, not a single equilibrium object: balanced reciprocity, honest perturbation, patronage, and enforcement.

## 2. Reviewer comments mapped to concrete fixes

| Reviewer comment | Concrete fix |
| --- | --- |
| Unify the one-unit and proportional-theft formulations. | Make the one-unit cycle the baseline benchmark and state explicitly that the proportional-transfer model is the dynamic extension used to study persistent inequality, contracting, and policing. Add a transition paragraph that explains why the baseline is analytically sharp while the extension is necessary once wealth becomes heterogeneous. |
| TTC analogy is currently too literal. | Recast TTC as a limited analogy about permutation cycles and balanced reciprocity. Replace claims of literal TTC implementation with a precise statement that the benchmark shares the graph structure of a TTC allocation but differs because transfers are coercive and impose externalities. |
| Proposition 2 mixes static and dynamic reasoning. | Rewrite Proposition 2 as a repeated-game / stationary Markov statement with an explicit state variable and horizon. Prove the impossibility of a stationary one-honest regime without using unstated future deviations. Then explain that the simulation implements the same wealth-dependent best-response logic in reduced form. |
| Patron's incentive to hire is knife-edge. | Derive a patron's menu of options: self-theft, abstention, hire a thief, hire a guard. Make strict patron surplus come from two explicit forces: target-selection/productivity advantage in delegated theft and low thief outside options due to congestion among poor freelancers. |
| Simulation section is under-specified. | Build a fully reproducible R pipeline with documented primitives, parameter file, explicit seed control, victim-selection rules, contract rules, role transitions, and one-click figure/table generation. Add a simulation appendix. |
| Rich agents' security if they abstain is inconsistent. | Separate three regimes: first-night honesty shock, patronage regime, and guard regime. State clearly that occupancy plus patronage norms protects rich property in the middle regime, but this protection weakens once patronage is withdrawn and desperate poor re-target the rich. |
| Honest agent robbery timeline is contradictory. | Write an explicit event timeline. On the first honest night the honest agent stays home and deters burglary; in later periods he may become poor because he forgoes loot while others reoptimize. Distinguish first-night realized outcomes from later transition dynamics. |
| Contract-market language attributes the outside option to the wrong side. | Rewrite the contract discussion so that competition among poor thieves, not among patrons, disciplines wages toward the outside option, subject to participation and incentive constraints. |
| Simulation results are hard to reconcile with the earlier deterministic cycle. | Make the baseline perturbation simulation deterministic and cycle-based, then distinguish it from the richer stochastic patronage simulation where independent victim draws and multiple hits per house are allowed. |
| "Theft from poor to rich" is directionally ambiguous. | State explicitly that the physical act of theft is poor-on-poor in the patronage regime, while the net transfer is poor-to-rich through remittances to patrons. |
| Steady-state wealth equations are ambiguous. | Add "in expectation" everywhere those equations are used, and keep realized simulation laws separate from expectation statements in the theory. |

## 3. Current contradictions and soft spots

- The draft contains two partially incompatible papers: Sections 2-7 develop a unit-transfer benchmark, then Section 8 rebuilds the model with proportional theft, thresholds, contracts, and policing.
- The equilibrium object changes without warning across sections: one-shot Nash, repeated-game stationarity, behavioral dynamics, and simulation heuristics are currently blended together.
- The honest-man timeline is inconsistent: in some passages he is robbed immediately, in others his occupied house deters theft.
- The TTC analogy is overclaimed. The paper productively sees a cyclic allocation, but coercive theft is not voluntary exchange and does not satisfy the same incentive structure.
- The patronage model has an unresolved zero-profit problem: the current participation condition for thieves leaves no clear source of strict patron surplus.
- The role of occupancy is unstable. Rich homes are said to be safe because they are occupied, yet guards later become necessary without a clean explanation of what changed.
- Welfare language is underdefined. Aggregate wealth is mostly redistributed, yet the draft sometimes speaks as if aggregate welfare falls without specifying whether the welfare loss comes from effort, guarding, punishment, or inequality.
- The simulation is not reproducible from the text: role thresholds, matching, targeting, and parameter values are incomplete, and the reported path is impossible to parse against the earlier deterministic cycle.
- The references are too sparse for the claims being made, and at least one citation currently looks misplaced for the argument being supported.

## 4. Revised paper architecture

1. Introduction
2. Related literature
3. Model primitives and notation
4. Baseline benchmark: balanced reciprocal theft
5. Honest perturbation and the instability of the balanced regime
6. Dynamic extension with heterogeneous wealth and proportional theft
7. Patron-thief contracting
8. Endogenous enforcement and the guard regime
9. Welfare and comparative statics
10. Simulation design
11. Simulation results
12. Discussion
13. Conclusion

Appendix:

- Omitted proofs
- Alternative assumptions and edge cases
- Simulation algorithm
- Robustness figures
- Parameter tables

## 5. Revised model architecture

### 5.1 Primitive choice

I will adopt **Option 1**.

- The **baseline benchmark** is a unit-transfer cycle. This preserves the paper's original identity and cleanly formalizes Calvino's equal-wealth reciprocity.
- The **dynamic extension** switches to proportional transfer, with loot equal to `gamma * victim wealth`, because persistent inequality, patronage, and guarding cannot be studied seriously in a one-unit world once wealth diverges.
- The manuscript will say explicitly that the two formulations are related but serve different purposes:
  - the unit-transfer model isolates the reciprocal-balance logic;
  - the proportional model is the richer environment needed once wealth heterogeneity matters.

### 5.2 State variables and notation block

Early in the paper, add a notation block covering:

- Agents `i = 1, ..., N`
- Wealth `w_it`
- Personal action `a_it in {steal, stay, hire thief, hire guard}`
- Victim choice `v_it`
- Loot function `ell(w_jt)`, with `ell(w_jt) = 1` in the baseline and `ell(w_jt) = gamma w_jt` in the extension
- Moral / action cost `m_i`
- Exposure loss from leaving home unprotected
- Contract wage `s_it` and loot share `alpha_it`
- Guard effectiveness `q_t`
- Regime labels: balanced, transition, patronage, guard

### 5.3 Baseline benchmark

- Keep the cyclical theft arrangement as a **balanced reciprocity benchmark** rather than overselling it as TTC.
- Proposition 1 will show that, under the benchmark's simplified stage game, a permutation cycle is a weak Nash equilibrium and preserves equality.
- The text will say that the TTC connection is analogical: the benchmark shares a cycle structure and a core-like no-blocking logic under symmetric endowments, but it is not voluntary exchange.

### 5.4 Honest perturbation

- Define the horizon explicitly as an infinite-horizon repeated game with wealth as the state.
- Honest agent `h` is exogenously committed to `stay`.
- Richer agents choose whether to keep stealing or remain home based on a derived comparison between expected loot and exposure risk.
- Proposition 2 will be reframed as: **there is no stationary Markov equilibrium that preserves the original balanced regime once one agent is permanently honest.**
- The proof will not rely on smuggled period-2 logic; it will rely on the state transition generated by one permanent abstainer and the induced best-response inequality for newly advantaged agents.

### 5.5 Patron-thief contracting

- Rich agent `i` compares:
  - personal theft,
  - abstention,
  - hiring thief `j`,
  - hiring guard `g`.
- Patron value of personal theft:
  - expected loot from direct theft
  - minus exposure from leaving home
  - minus own effort / risk cost.
- Patron value of hiring:
  - retained loot share from delegated theft
  - minus wage
  - minus contracting cost
  - plus avoided home exposure.
- Thief participation:
  - contract payoff must exceed freelance outside option.
- Strict patron surplus comes from:
  - **better targeting** by patrons, who can direct thieves toward relatively wealthy and weakly defended poor households;
  - **labour-market slack** among poor thieves, which drives the required compensation below gross expected delegated loot.
- This eliminates the zero-profit contradiction.

### 5.6 Guard regime

- The move from patronage to guards is a separate choice problem, not an informal narrative leap.
- Rich agents switch from hiring thieves to hiring guards when:
  - expected net loot from delegated theft falls because poor targets have been depleted, and
  - expected loss from raids on elite wealth rises if patronage is withdrawn.
- The guard condition will therefore compare:
  - expected profit from one more period of delegated theft,
  - with expected loss avoided by protection.

### 5.7 Welfare

- Distinguish clearly between:
  - aggregate wealth,
  - expected utility,
  - inequality-adjusted welfare.
- Welfare measure for the paper:
  - utilitarian welfare with concave utility over wealth,
  - minus theft effort costs,
  - minus contracting costs,
  - minus guarding / punishment costs.
- This lets the paper say precisely how honesty can reduce welfare even when gross resources are mostly redistributed: the honest shock triggers persistent inequality and resource-burning protective activity.

## 6. Simulation architecture

### 6.1 Languages and workflow

- Use **R throughout** for simulation, figures, and tables.
- Use a single build pipeline driven by `Makefile` and `Rscript`.
- Use deterministic seed handling with a top-level seed file / parameter object.

### 6.2 Core simulation modules

- `01_model_primitives.R`: parameters, utility, loot, exposure, contract, and welfare functions
- `02_equilibrium_objects.R`: helpers for balanced cycle construction, regime classification, and analytical summary objects
- `03_simulate_baseline.R`: deterministic cycle perturbation simulation
- `04_simulate_patronage.R`: stochastic patron-thief simulation
- `05_simulate_enforcement.R`: guard-regime extension
- `06_parameter_sweeps.R`: comparative statics and regime maps
- `07_make_figures.R`: figure generation
- `08_make_tables.R`: tables and manuscript-ready summary outputs

### 6.3 Baseline perturbation simulation

- Deterministic cycle with one permanent honest agent
- Event-time wealth path by role
- Direct correspondence to Proposition 2

### 6.4 Patronage simulation

- Role classification rule documented explicitly
- Patron-thief matching rule documented explicitly
- Contract rule documented explicitly
- Victim selection among poor households documented explicitly
- Wealth update equations stored both realized and expected where relevant

### 6.5 Enforcement simulation

- Guard hiring triggered by a threshold comparison of marginal predation profit versus expected protected wealth
- Detection and punishment probabilities explicit
- Regime label recorded period by period

### 6.6 Parameter sweeps

- `gamma`: theft intensity
- `m_i` / honesty share
- exposure risk from leaving home
- contracting cost
- patron bargaining power / wage floor
- enforcement effectiveness
- punishment severity
- outside option of poor thieves
- number of initial honest agents

## 7. New figures and what each figure proves

1. **Balanced cycle event study**
   - Shows that the equal-wealth theft cycle is stationary before the shock and breaks immediately after one permanent honest deviation.

2. **First-night accounting diagram**
   - Shows exactly who gains and loses on the first honest night, fixing the timeline confusion in the draft.

3. **Event-time wealth trajectories by role**
   - Shows how honest agent, future patrons, future thieves, and future guards separate over time.

4. **Wealth-distribution evolution**
   - Density-over-time / heatmap figure showing the transition from equality to stratification.

5. **Inequality dynamics**
   - Gini, top-decile share, and key Lorenz curves showing that the honest shock has persistent distributional consequences.

6. **Contracting comparative statics**
   - Shows how patron surplus, thief pay, and contract incidence vary with targeting advantage, outside options, and contracting cost.

7. **Regime phase diagram**
   - Maps parameter regions into balanced theft, unstable transition, patronage, guard regime, coexistence, and collapse.

8. **Role-share transition figure**
   - Shows the fractions of agents who are personal thieves, patrons, hired thieves, guards, and inactive over time.

9. **Guard transition timing**
   - Shows the distribution of time to first patronage and time to first guard regime across parameter draws.

10. **Network snapshots**
    - Shows the theft network, patronage network, and guard network at selected dates in a clean layout.

11. **Welfare decomposition**
    - Separates aggregate wealth, expected utility, theft costs, guarding costs, and inequality-adjusted welfare.

12. **Robustness panel**
    - Shows that the mechanism is not a one-parameter artifact.

## 8. Editorial decisions to implement

- Keep the Calvino opening and closing cadence, but cut essay-like repetition once the model begins.
- Replace duplicated prose with one formal sequence of results.
- Move most storytelling interpretation out of the theorem sections and into the introduction and discussion.
- Use theorem / proposition / lemma labels only when the claim is genuinely analytical.
- Label simulation findings explicitly as computational.

## 9. Immediate execution order

1. Create the repo skeleton and build pipeline.
2. Build the revised analytical model in LaTeX section files.
3. Implement the R simulation framework and parameter sweeps.
4. Generate all manuscript figures and tables from code.
5. Write the response memo as a reviewer table tied to exact file locations.
6. Compile, audit, and clean the final package.
