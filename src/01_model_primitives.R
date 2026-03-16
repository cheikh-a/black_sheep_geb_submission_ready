source(file.path(getwd(), "src", "00_utils.R"))

default_parameters <- function() {
  list(
    seed = 613L,
    n_agents = 60L,
    initial_wealth = 1,
    baseline_honest_id = 1L,
    honest_ids = 1L,
    baseline_periods = 8L,
    patronage_periods = 45L,
    enforcement_periods = 70L,
    unit_loot = 1,
    gamma = 0.35,
    rich_multiplier = 1.15,
    elite_multiplier = 2.10,
    occupancy_success_prob = 0.08,
    guard_success_prob = 0.02,
    punishment_prob = 0.85,
    punishment_severity = 0.60,
    theft_cost = 0.02,
    contract_cost = 0.03,
    base_wage = 0.03,
    guard_wage = 0.08,
    alpha_target = 0.45,
    alpha_min = 0.25,
    alpha_max = 0.70,
    participation_buffer = 0.01,
    target_advantage = 1.35,
    slackness = 0.70,
    personal_target_quantile = 0.65,
    hired_target_quantile = 0.80,
    guard_profit_ratio = 1.05,
    utility_floor = 1e-6,
    sweep_reps = 8L,
    sweep_periods = 45L,
    phase_tail = 12L
  )
}

initial_agent_state <- function(params = default_parameters()) {
  honest_ids <- if ("honest_ids" %in% names(params)) params$honest_ids else params$baseline_honest_id
  data.frame(
    id = seq_len(params$n_agents),
    wealth = rep(params$initial_wealth, params$n_agents),
    role = rep("freelance_thief", params$n_agents),
    forced_honest = seq_len(params$n_agents) %in% honest_ids,
    stringsAsFactors = FALSE
  )
}

utility_of_wealth <- function(wealth, params) {
  log(pmax(wealth, params$utility_floor) + 1)
}

loot_unit <- function(victim_wealth, params) {
  pmin(params$unit_loot, pmax(victim_wealth, 0))
}

loot_proportional <- function(victim_wealth, params) {
  pmax(0, params$gamma * victim_wealth)
}

rich_threshold <- function(wealth, params) {
  params$rich_multiplier * safe_mean(wealth)
}

elite_threshold <- function(wealth, params) {
  params$elite_multiplier * safe_mean(wealth)
}

vulnerable_pool <- function(agents, exclude_ids = integer(), poor_only = FALSE) {
  out <- agents[agents$wealth > 0, , drop = FALSE]
  if (length(exclude_ids)) {
    out <- out[!out$id %in% exclude_ids, , drop = FALSE]
  }
  if (poor_only) {
    out <- out[out$role %in% c("freelance_thief", "hired_thief", "inactive", "stay"), , drop = FALSE]
  }
  out
}

target_pool_quantile <- function(wealth, q) {
  wealth <- wealth[is.finite(wealth) & wealth > 0]
  if (!length(wealth)) {
    return(0)
  }
  as.numeric(stats::quantile(wealth, probs = q, type = 7, names = FALSE))
}

expected_personal_payoff <- function(wealth_i, poor_wealth, params) {
  target_level <- target_pool_quantile(poor_wealth, params$personal_target_quantile)
  gross <- params$gamma * target_level
  exposure <- params$gamma * wealth_i
  gross - exposure - params$theft_cost
}

expected_freelance_outside_option <- function(poor_wealth, params) {
  if (!length(poor_wealth)) {
    return(0)
  }
  gross <- params$gamma * target_pool_quantile(poor_wealth, 0.50)
  max(0, params$slackness * gross - params$theft_cost)
}

compute_contract_terms <- function(poor_wealth, params) {
  if (!length(poor_wealth)) {
    return(list(
      wage = 0,
      alpha = params$alpha_target,
      outside_option = 0,
      gross_hired_loot = 0,
      patron_profit = 0
    ))
  }

  outside <- expected_freelance_outside_option(poor_wealth, params)
  target_wealth <- target_pool_quantile(poor_wealth, params$hired_target_quantile)
  gross_hired <- params$target_advantage * params$gamma * target_wealth
  alpha <- clamp(params$alpha_target, params$alpha_min, params$alpha_max)
  wage <- max(params$base_wage, outside + params$participation_buffer - alpha * gross_hired)
  patron_profit <- gross_hired - alpha * gross_hired - wage - params$contract_cost

  list(
    wage = wage,
    alpha = alpha,
    outside_option = outside,
    gross_hired_loot = gross_hired,
    patron_profit = patron_profit
  )
}

raid_pressure <- function(agents, params) {
  poor <- agents$wealth[!agents$forced_honest & agents$wealth > 0]
  if (!length(poor)) {
    return(0)
  }
  depleted <- 1 - safe_mean(poor) / params$initial_wealth
  active_share <- mean(agents$role %in% c("freelance_thief", "hired_thief"))
  clamp(0.10 + 0.50 * max(0, depleted) + 0.30 * active_share, 0, 1)
}

expected_guard_value <- function(wealth_i, raid_prob, params) {
  avoided_loss <- raid_prob * params$gamma * wealth_i * (1 - params$guard_success_prob)
  avoided_loss - params$guard_wage
}

welfare_components <- function(wealth, role_counts, cost_totals, params) {
  utilitarian <- sum(utility_of_wealth(wealth, params))
  data.frame(
    total_wealth = sum(wealth),
    utilitarian_welfare = utilitarian - safe_sum(unlist(cost_totals)),
    theft_costs = cost_totals$theft_costs,
    contracting_costs = cost_totals$contracting_costs,
    guarding_costs = cost_totals$guarding_costs,
    punishment_losses = cost_totals$punishment_losses,
    gini = gini_coefficient(wealth),
    top10_share = top_share(wealth, 0.10),
    n_honest = role_counts[["honest"]],
    n_patrons = role_counts[["patron"]],
    n_hired_thieves = role_counts[["hired_thief"]],
    n_freelance = role_counts[["freelance_thief"]],
    n_guards = role_counts[["guard"]],
    n_idle = role_counts[["inactive"]] + role_counts[["stay"]],
    stringsAsFactors = FALSE
  )
}
