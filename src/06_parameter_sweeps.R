source(file.path(getwd(), "src", "05_simulate_enforcement.R"))

run_summary <- function(result, params) {
  metrics <- result$metrics
  final_row <- metrics[nrow(metrics), , drop = FALSE]
  patron_complex_share <- (metrics$n_patrons + metrics$n_hired_thieves) / params$n_agents
  data.frame(
    dominant_regime = dominant_regime(metrics$regime, params$phase_tail),
    final_gini = final_row$gini,
    final_top10 = final_row$top10_share,
    final_welfare = final_row$utilitarian_welfare,
    first_patron = first_period_with(metrics$n_patrons > 0, metrics$time),
    first_guard = first_period_with(metrics$n_guards > 0, metrics$time),
    patron_complex_share_t3 = patron_complex_share[match(3L, metrics$time)],
    guard_share_5pct_time = first_period_with((metrics$n_guards / params$n_agents) >= 0.05, metrics$time),
    stringsAsFactors = FALSE
  )
}

run_parameter_sweeps <- function(params = default_parameters(), save_outputs = TRUE) {
  ensure_dir(project_path("data", "processed"))

  regime_grid <- expand.grid(
    gamma = seq(0.20, 0.55, by = 0.05),
    enforcement_effectiveness = c(0.80, 0.88, 0.94, 0.98),
    stringsAsFactors = FALSE
  )
  regime_rows <- vector("list", nrow(regime_grid))
  for (i in seq_len(nrow(regime_grid))) {
    pars <- default_parameters()
    pars$gamma <- regime_grid$gamma[i]
    pars$guard_success_prob <- 1 - regime_grid$enforcement_effectiveness[i]
    pars$seed <- 2000L + i
    res <- simulate_enforcement_path(pars, periods = pars$sweep_periods, save_outputs = FALSE, seed = pars$seed)
    regime_rows[[i]] <- cbind(regime_grid[i, , drop = FALSE], run_summary(res, pars))
  }
  regime_df <- do.call(rbind, regime_rows)

  contract_grid <- expand.grid(
    target_advantage = seq(1.05, 1.70, by = 0.05),
    slackness = seq(0.45, 0.90, by = 0.05),
    stringsAsFactors = FALSE
  )
  representative_poor <- seq(0.10, 1.25, length.out = 40)
  contract_rows <- vector("list", nrow(contract_grid))
  for (i in seq_len(nrow(contract_grid))) {
    pars <- default_parameters()
    pars$target_advantage <- contract_grid$target_advantage[i]
    pars$slackness <- contract_grid$slackness[i]
    terms <- compute_contract_terms(representative_poor, pars)
    contract_rows[[i]] <- data.frame(
      target_advantage = pars$target_advantage,
      slackness = pars$slackness,
      patron_surplus = terms$patron_profit,
      thief_compensation = terms$wage + terms$alpha * terms$gross_hired_loot,
      outside_option = terms$outside_option,
      gross_hired_loot = terms$gross_hired_loot,
      stringsAsFactors = FALSE
    )
  }
  contract_df <- do.call(rbind, contract_rows)

  timing_grid <- expand.grid(
    initial_honest = 1:5,
    rep = seq_len(params$sweep_reps),
    stringsAsFactors = FALSE
  )
  timing_rows <- vector("list", nrow(timing_grid))
  for (i in seq_len(nrow(timing_grid))) {
    pars <- default_parameters()
    pars$honest_ids <- seq_len(timing_grid$initial_honest[i])
    pars$seed <- 4000L + i
    res <- simulate_enforcement_path(pars, periods = pars$sweep_periods, save_outputs = FALSE, seed = pars$seed)
    timing_rows[[i]] <- cbind(
      timing_grid[i, , drop = FALSE],
      run_summary(res, pars)
    )
  }
  timing_df <- do.call(rbind, timing_rows)

  sensitivity_specs <- list(
    gamma = seq(0.20, 0.55, length.out = 6),
    contract_cost = seq(0.01, 0.07, length.out = 6),
    occupancy_success_prob = seq(0.02, 0.18, length.out = 6),
    target_advantage = seq(1.05, 1.65, length.out = 6)
  )
  sensitivity_rows <- list()
  counter <- 0L
  for (param_name in names(sensitivity_specs)) {
    for (value in sensitivity_specs[[param_name]]) {
      counter <- counter + 1L
      pars <- default_parameters()
      pars[[param_name]] <- value
      pars$seed <- 6000L + counter
      res <- simulate_enforcement_path(pars, periods = pars$sweep_periods, save_outputs = FALSE, seed = pars$seed)
      sensitivity_rows[[counter]] <- cbind(
        data.frame(parameter = param_name, value = value, stringsAsFactors = FALSE),
        run_summary(res, pars)
      )
    }
  }
  sensitivity_df <- do.call(rbind, sensitivity_rows)

  if (save_outputs) {
    write.csv(regime_df, project_path("data", "processed", "regime_grid.csv"), row.names = FALSE)
    write.csv(contract_df, project_path("data", "processed", "contract_grid.csv"), row.names = FALSE)
    write.csv(timing_df, project_path("data", "processed", "transition_timing.csv"), row.names = FALSE)
    write.csv(sensitivity_df, project_path("data", "processed", "sensitivity_metrics.csv"), row.names = FALSE)
  }

  list(
    regime_grid = regime_df,
    contract_grid = contract_df,
    transition_timing = timing_df,
    sensitivity = sensitivity_df
  )
}

if (sys.nframe() == 0L) {
  invisible(run_parameter_sweeps())
}
