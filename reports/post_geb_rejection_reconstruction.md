# Post-GEB Reconstruction Memo

## Context

On April 8, 2026, *Games and Economic Behavior* rejected the paper at the desk stage on the recommendation of an Advisory Editor. The report is unusually useful because it is not dismissing the idea. The AE explicitly says that the paper is original, thought provoking, and enjoyable to read. The rejection turns on a more precise claim: the manuscript does not present a sufficiently well defined game with sufficiently sharp formal results for GEB. The report should therefore be treated as a model design memo from a skeptical but serious reader, not as a signal that the project itself is dead.

The decisive sentence in the report is the following: the AE is “left with the feeling that there is no proper game being played.” Everything else in the report flows from that diagnosis. The simulations then look too prominent because the game underneath them is not pinned down tightly enough. The formal results then look too modest because they are not clearly anchored in an explicit action space, an explicit aggregation rule, and an explicit equilibrium object. The next version has to fix that problem at the root.

## What the AE is actually saying

The report contains three substantive objections.

First, the paper does not tell the reader exactly what each player chooses in each period. Wealth is observable, but the action space remains blurry. The AE expects a clean answer to questions of the form: does each player choose whether to stay home, whom to raid, whether to hire someone else, whether to guard, and in what order those decisions are made. A paper can be stylized and still be precise. The AE's complaint is that stylization here drifts into under-specification.

Second, the paper never settles the interaction problem when several players target the same victim. That is not a side issue. It determines whether loot is rival, whether congestion appears, whether some targets become windfalls, and whether best responses are even well defined. Without a collision rule, there is no complete stage game.

Third, the formal section does not dominate the paper strongly enough to justify GEB placement. The AE is not objecting to simulations as such. The report is objecting to simulations that appear before the game is indisputable. For GEB, the paper needed a theorem-first architecture. What was submitted read more like a disciplined dynamic narrative with micro foundations than like a game theoretic paper whose later simulations extend clearly identified equilibrium objects.

## The actionable diagnosis

The next version must satisfy a simple test. A hostile but competent reader should be able to write the primitive game down without guessing. If that reader cannot reconstruct the period game and the equilibrium concept from the model section alone, the paper will keep failing in theory oriented venues.

That means the reconstruction should begin with the narrowest environment that can support one clean theorem and only then add the richer dynamics. The right question is no longer whether the current manuscript can be polished into acceptability. The right question is what minimal game can carry the core intuition that reciprocal predation can look balanced until one household exits permanently.

## The game that needs to exist on the page

The rebuilt paper should begin from one explicit repeated game and keep every later extension tied to it. A workable baseline is the following.

There are `N >= 3` agents indexed by `i = 1, ..., N`. In each period, agent `i` chooses one action from the set `A_i = {H} ∪ {1, ..., N} \ {i}`, where `H` means stay home and `j` means attempt to raid household `j`. Wealth at the start of period `t` is `w_{it}` and is publicly observed. A household that chooses `H` is occupied and cannot be raided successfully in that period. A household that leaves home is vulnerable. If `m_{jt}` raiders target household `j` while `j` is away, at most one stealable unit is available in the unit transfer benchmark. That unit is allocated by an explicit collision rule. The cleanest rule is equal expected sharing by lottery, so each raider targeting `j` receives expected loot `1 / m_{jt}`. Household `j` loses one unit if `m_{jt} >= 1` and zero otherwise. Every raid attempt carries effort cost `c > 0`.

That stage game is simple enough to state in one page and rich enough to answer the AE's main objection. It tells the reader what an action is, what happens under multiple raids, how congestion enters, and how realized or expected payoffs are defined. A permutation profile in which every agent leaves home and each household is targeted by exactly one other household is then an immediate benchmark object. It is no longer a metaphor. It is an explicit outcome of an explicit game.

The repeated game should then be defined with state `w_t = (w_{1t}, ..., w_{Nt})`, infinite horizon, common discount factor `delta`, and a restricted equilibrium object from the start. If the paper wants tractability rather than the full repeated game set, it should say so immediately and work with stationary Markov equilibria or with a stated subclass of stationary policy profiles. GEB was not rejecting restraint. It was rejecting restraint that had not been named.

## The minimum theorem program

The paper needs fewer claims and stronger claims.

The first result should be an existence proposition for a balanced reciprocal equilibrium in the unit transfer benchmark. This proposition can be modest. Under sufficiently low effort cost, a permutation profile in which each agent raids one distinct absent household and each absent household is raided once is a weak Nash equilibrium of the stage game and preserves equal wealth across agents. The point of the proposition is not depth. The point is to make the benchmark undeniable.

The second result should be the paper's central analytical claim. Once one agent is permanently committed to stay home, there is no stationary Markov continuation that preserves the original balanced reciprocal allocation. The proof should not reach for sophisticated repeated game machinery. The logic is local. The honest household becomes unraidable, the predecessor in the cycle loses expected loot, some other household becomes relatively advantaged, and equality cannot be preserved under the original transfer accounting. The theorem only has to establish non preservation of the balanced regime. It does not need to solve the entire transition.

The third result should concern delegated predation and should be written as an occupational choice theorem. A rich agent compares personal raiding, staying home, hiring a thief, and guarding. The paper should derive an explicit threshold under which hiring a poor thief is strictly better than personal predation. That threshold must rest on named forces: home exposure avoided by staying at home, expected delegated loot net of wage, and a low outside option for the poor thief generated by congestion in freelance raiding. Without those ingredients, the patron surplus problem returns.

The fourth result should derive the switch to protection. Once the wealth distribution is sufficiently skewed and the pool of vulnerable poor targets is depleted, the value of one more round of delegated predation falls below the expected loss avoided by protection. This can be stated as a guarding threshold proposition. If the exact threshold becomes too cumbersome, the theorem can be framed as monotone comparative statics under transparent assumptions.

That is enough. If the paper cannot prove these four statements cleanly, it should not add more. A shorter paper with four real results is stronger than a long paper with many interpretive claims.

## What has to be cut or demoted

Several features that were attractive in the submitted draft should move to the appendix or disappear.

The top trading cycles analogy should not appear in the title, abstract, or opening formal section. At most it can survive as a brief graph theoretic remark after the baseline equilibrium is already established. The AE did not mention TTC, but the broader complaint about fuzziness applies to any analogy that risks substituting for the actual game.

The simulation material should be reduced in status. The simulations can remain valuable, but they should start later and do less argumentative work. Their role is to quantify transition timing, map comparative statics, and display regime coexistence. They should not be asked to rescue missing theory.

The literary framing should also be tightened. Calvino is still the paper's intellectual spark and should remain in the opening paragraphs. But the model has to arrive faster, and once it arrives the prose should stop narrating the paper from outside. The desk rejection did not target style, yet the next version will benefit from making the formal object visible sooner.

## A concrete rewrite order

The most efficient way to rebuild the paper is not to edit the current draft line by line. It is to rewrite in layers.

First, write a three page technical note called `what_is_the_game.md` that contains only primitives, timing, collision rule, payoffs, and equilibrium concept. No literature, no welfare interpretation, no simulation discussion. If that note still leaves room for questions like the AE's congestion question, the model is not ready.

Second, rewrite the baseline section around the explicit unit transfer stage game and its repeated extension. The honest perturbation theorem should follow immediately.

Third, rebuild the patronage section as a clean extension rather than as a drift in notation. The extension should preserve the same logic of occupancy, collision, and wealth updating. The only new elements should be proportional loot, contracting, and richer occupational choice.

Fourth, only after the theorem program is stable should the simulation code and figures be reconsidered. The simulation architecture in the repo is already serviceable as a reproducibility package, but the paper should be selective about what remains in the main text. Three or four figures in the body would probably be enough for the next submission.

## What the next paper structure should look like

The current manuscript can be rebuilt into a tighter structure without abandoning the project's identity.

1. Introduction  
2. Related literature  
3. The unit transfer raiding game  
4. Balanced reciprocity  
5. A permanent honest household and the collapse of balance  
6. Extension: proportional loot and delegated predation  
7. From hiring thieves to hiring guards  
8. Welfare  
9. Simulations  
10. Discussion and conclusion

The main change is that the game now appears before the narrative interpretation expands. The extension sections then read as genuine extensions rather than as a second paper nested inside the first.

## Journal strategy after reconstruction

The paper should not be sent back out immediately in its current form. The GEB rejection has identified a genuine structural weakness, and another theory oriented journal would likely find the same thing.

If the theorem-first reconstruction succeeds and the simulations are reduced to a supporting role, the paper could still target a formal outlet, but GEB is no longer the obvious next move. A better strategy would be to submit the rebuilt version to a journal that welcomes theory with institutional or interdisciplinary reach, even when the contribution is not positioned as a frontier advance in general game theory. *Journal of Economic Behavior & Organization* is the strongest candidate in that category because its official scope explicitly includes economic behavior, organization, structural change, and institutional evolution, with work that crosses into neighboring disciplines especially welcome. [JEBO aims and scope](https://www.sciencedirect.com/journal/journal-of-economic-behavior-and-organization)

If the rewrite becomes more compact and more formally self contained, with the simulations pushed sharply into the background, *Mathematical Social Sciences* becomes a plausible destination because its stated scope explicitly includes game theory, economic theory, welfare and inequality, and dynamic models under a mathematically rigorous standard. [MSS aims and scope](https://www.sciencedirect.com/journal/mathematical-social-sciences)

If the revision leans harder into predation, selective protection, clientelism, and institutionalized coercion, then *Public Choice* becomes plausible, though that path would require a stronger political economy framing than the current manuscript provides. The journal is clearly open to formal work on rent seeking, government failure, clientelism, and related political economy themes. [Public Choice journal page](https://link.springer.com/journal/11127)

If the project remains broader in style and more conceptual in ambition, *Theory and Decision* is another realistic home, since its scope covers game theory, decision science, social choice, and interactive decision making across disciplines. [Theory and Decision overview](https://link.springer.com/journal/11238)

At this stage, the best publication strategy is conditional:

- if the next version remains theory plus simulation with institutional evolution in the foreground, target JEBO first;
- if the next version becomes shorter, more formal, and theorem dominant, target Mathematical Social Sciences first;
- if the next version becomes more explicitly political economy, target Public Choice first.

## Recommendation

The project is worth continuing. The desk rejection should not be read as a verdict on originality or promise. It should be read as a demand for one thing the next version must deliver without ambiguity: a proper game.

The immediate next step is therefore not another journal submission. It is a reconstruction sprint centered on one question: what exactly does each player choose, what exactly happens when choices collide, and what equilibrium object is the paper prepared to analyze. Once those answers exist on the page in a form that no careful reader could miss, the rest of the manuscript becomes much easier to judge and much easier to place.
