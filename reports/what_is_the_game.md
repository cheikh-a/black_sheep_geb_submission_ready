# What Is the Game?

This note strips the project down to the smallest game that can carry its main intuition. It does not try to summarize the paper. It states the primitives, the timing, the action sets, the collision rule, the payoffs, and the equilibrium objects. If the next draft cannot be written from this note, then the model is still not sharp enough.

## 1. Players, state, and observables

There are `N >= 3` agents indexed by `i = 1, ..., N`. Time is discrete, with dates `t = 0, 1, 2, ...`. At the start of period `t`, each agent has publicly observed wealth `w_{it} >= 0`. The period state is the wealth vector

`w_t = (w_{1t}, ..., w_{Nt})`.

The baseline game is a repeated raiding game. Every later extension has to preserve the same state variable, the same occupancy logic, and an explicit rule for how several raiders interact when they choose the same target.

## 2. Baseline action set

In the unit transfer benchmark, each agent chooses exactly one action in each period:

`a_{it} in A_i = {H} union ({1, ..., N} \ {i})`.

`H` means that agent `i` stays home. Choosing `j != i` means that agent `i` leaves home and attempts to raid household `j`.

This action set has two implications that need to remain visible throughout the paper.

First, raiding and leaving home are the same decision in the baseline. An agent cannot both raid and protect his own house in the same period. Second, a target choice is part of the action itself. The game is not a reduced-form choice between “steal” and “stay” with an implicit target selection step hidden in the prose.

## 3. Occupancy and vulnerability

Occupancy determines whether a household can be raided successfully in the baseline game.

- If `a_{jt} = H`, household `j` is occupied and no raid on `j` succeeds in period `t`.
- If `a_{jt} != H`, household `j` is unoccupied and vulnerable in period `t`.

This rule is deterministic in the unit transfer benchmark. The first honest night is therefore deterministic as well. If the honest agent stays home, that house is protected on that date.

## 4. Collision rule

For each household `j`, let

`M_{jt} = { i != j : a_{it} = j }`

be the set of raiders who target `j` in period `t`, and let `m_{jt} = |M_{jt}|`.

If `a_{jt} = H`, then every attempted raid on `j` fails and each raider in `M_{jt}` receives zero loot from that target.

If `a_{jt} != H` and `m_{jt} >= 1`, then at most one unit can be stolen from `j` in that period. That unit is allocated by fair lottery across the `m_{jt}` raiders. Equivalently, each raider in `M_{jt}` receives expected loot `1 / m_{jt}` and household `j` loses one unit.

If `a_{jt} != H` and `m_{jt} = 0`, then household `j` is unraided and loses nothing.

This is the key completion rule missing from the submitted draft. It makes loot rival, generates congestion immediately, rules out the idea that several raiders can independently extract the same unit, and prevents accidental windfalls from appearing without being defined.

## 5. Period payoffs in the unit transfer benchmark

Let `c > 0` denote the effort cost of leaving home to raid. Let current utility be linear in end-of-period wealth net of effort cost. Define the random period payoff of agent `i` by

`u_i(a_t, w_t) = w_{it} - loss_{it}(a_t) + gain_{it}(a_t) - c * 1{a_{it} != H}`.

Here:

- `loss_{it}(a_t) = 1` if household `i` is unoccupied and receives at least one incoming raid, and `0` otherwise;
- `gain_{it}(a_t)` is the lottery payoff from the target chosen by `i`, equal to `0` if `a_{it} = H`, equal to `0` if the chosen target is occupied, and equal to `1 / m_{jt}` in expectation if `i` targets an unoccupied household `j` that is also targeted by `m_{jt} - 1` other raiders.

The next-period wealth is then given by

`w_{i,t+1} = u_i(a_t, w_t)`.

The benchmark does not need a separate production sector or consumption decision. Wealth updating is already explicit once losses, gains, and effort costs are defined.

## 6. Balanced reciprocity as an explicit outcome

A balanced reciprocity profile in the stage game is a permutation `sigma` of `{1, ..., N}` with no fixed points such that each agent `i` chooses `a_i = sigma(i)`. Every household is unoccupied, every household is targeted by exactly one raider, every raid succeeds, and each agent loses one unit and gains one unit.

Under that profile:

- `m_j = 1` for every `j`;
- each agent's expected gain is `1`;
- each agent's loss is `1`;
- each agent's end-of-period wealth is `w_i - c`.

If one wants the benchmark to preserve wealth exactly, the costless case `c = 0` delivers that result. If one wants positive raiding cost, then the relevant claim is weaker: the profile preserves equality, even though it dissipates resources. The next draft has to choose one version and keep it throughout. The cleanest route is to let the benchmark theorem work with `c = 0` and to reintroduce resource costs only in the extension and welfare section.

## 7. Repeated game and restricted equilibrium object

The repeated environment is infinite horizon with common discount factor `delta in (0,1)`. A strategy for agent `i` maps the current wealth vector into an action:

`s_i : R_+^N -> A_i`.

The full repeated game is too large to characterize in general, so the paper should say immediately that it studies a restricted equilibrium class. The natural restriction is stationary Markov behavior. A stationary Markov profile is a tuple `s = (s_1, ..., s_N)` such that each `s_i` depends only on current wealth `w_t`.

The appropriate equilibrium object for the benchmark is then:

`s` is a stationary Markov equilibrium if, for every state `w_t` and every agent `i`, action `s_i(w_t)` maximizes agent `i`'s expected discounted payoff given the other agents' stationary Markov strategies.

This restriction does real work. It prevents the analysis from sliding between a one-shot deviation argument and an unrestricted folk theorem style repeated-game claim.

## 8. The honest perturbation

Fix one agent `h` who is permanently committed to honesty. Formally,

`s_h(w) = H` for every state `w`.

All other agents remain strategic. Let the pre-perturbation benchmark be the permutation profile `sigma`, and let `p = sigma^{-1}(h)` denote the predecessor of `h` in the cycle, while `q = sigma(h)` denotes the successor.

On the first perturbed date:

- `h` stays home and is therefore unraidable;
- `p` still targets `h` if he follows the old cycle, so his raid fails;
- `q` is no longer raided by `h` because `h` has stopped leaving home;
- every other link in the old cycle remains as before if the other players have not yet adjusted.

The first-period wealth update is then:

- `w_{h,1} = w_{h,0}`;
- `w_{p,1} = w_{p,0} - 1 - c` if raiding cost is included, or `w_{p,1} = w_{p,0} - 1` if the baseline is costless;
- `w_{q,1} = w_{q,0} + 1`;
- all other agents remain at their previous wealth, net of any benchmark raiding cost.

This is the local asymmetry that the paper needs later. It no longer has to be narrated informally because it follows from the action profile and the collision rule.

## 9. Exposure-based withdrawal from personal raiding

The benchmark by itself can establish that one honest deviation breaks the exact reciprocal accounting. To study why some agents then stop raiding personally, the repeated game needs one extra ingredient: leaving home becomes more costly when one is wealthy.

Let the expected exposure loss from leaving home with wealth `w` be `rho w`, where `rho in (0,1)`. Then the expected one-period payoff from personal raiding for an agent who expects a successful, uncongested raid is

`pi^R(w) = 1 - c - rho w`,

while the normalized payoff from staying home is

`pi^H(w) = 0`.

This yields a threshold

`w^* = (1 - c) / rho`.

Agents with `w <= w^*` weakly prefer to continue personal raiding, while agents with `w > w^*` prefer to stay home. The submitted paper used this logic informally. The next draft has to present it as a stated auxiliary margin in the repeated game.

## 10. The extension to delegated predation

The richer environment begins only after the baseline game has done its job. The extension keeps the same population, the same public wealth state, and the same occupancy logic, but enlarges the action set for wealthy agents.

In the extension, a rich agent can choose among:

- personal raiding;
- staying home without hiring anyone;
- hiring one thief;
- hiring one guard.

A poor agent can choose among:

- personal raiding;
- staying home;
- accepting thief employment;
- accepting guard employment.

The proportional loot technology should then be written as a new primitive, not as a silent replacement of the unit transfer rule. If thief `j` is sent against target `k`, successful loot is `gamma w_{kt}` for `gamma in (0,1)`. If several thieves or freelancers target the same household in the extension, the paper still needs a collision rule. The easiest consistent choice is to preserve rivalry: total stealable loot from one target is capped at `gamma w_{kt}`, and concurrent raiders divide that amount by lottery or equal sharing.

The extension therefore does not abandon the baseline game. It adds occupational choice and proportional loot while preserving explicit target choice, occupancy, and rivalry in extraction.

## 11. Contracting

The contracting environment also needs to be fully explicit.

If patron `i` hires thief `j`, the contract specifies:

- the target rule or target class;
- a fixed payment `s_{ijt}`;
- a loot share `alpha_{ijt}` for the thief;
- any contracting cost `k > 0` borne by the patron.

The thief accepts only if the contract beats his outside option. The patron hires only if expected retained loot net of the wage and contracting cost beats both personal raiding and abstention.

No later draft should use the phrase “the patron hires a thief” without having already stated these objects.

## 12. Guarding

If patron `i` hires a guard, the guard remains attached to `i`'s household during that period. Guarding should therefore be modeled as a direct reduction in the probability or success rate of incoming raids on `i`. If several raiders still target a guarded household, the paper should specify whether guarding blocks all raids with probability `q`, reduces stealable loot to zero with probability `q`, or reduces the expected loss multiplicatively. Any of those routes can work. What cannot remain implicit is the mechanism by which guards alter the stage game.

## 13. What the next paper can safely claim

Once the game is written this way, the next draft can safely pursue four analytical claims.

First, balanced reciprocity exists as an explicit benchmark profile in the unit transfer stage game. Second, one permanently honest household destroys the exact balanced accounting immediately. Third, exposure can make newly advantaged households stop personal raiding in stationary Markov continuation. Fourth, delegated predation and later guarding can be studied as occupational choices in an extension that preserves the same core game logic.

What the next draft should not do is slide from this game into a simulation process that silently changes targeting, congestion, occupancy, or payoff aggregation. Every simulation rule has to be legible as either a direct implementation of this game or a clearly labeled extension of it.

## 14. Bottom line

The project has a viable game at its core, but only if the draft is willing to become narrower and more explicit. The central repair is simple to state. Every player must have a defined action. Every target conflict must have a defined resolution. Every wealth update must come from those two ingredients. Every equilibrium claim must name the equilibrium class it belongs to. Once those elements are fixed, the paper can argue about honesty, inequality, patronage, and enforcement on firmer ground.
