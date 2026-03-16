source(file.path(getwd(), "src", "02_equilibrium_objects.R"))

simulate_baseline_path <- function(params = default_parameters(), save_outputs = TRUE) {
  agents <- initial_agent_state(params)
  targets <- build_cycle_targets(params$n_agents)
  honest_ids <- which(agents$forced_honest)
  honest_id <- honest_ids[1]
  predecessor_id <- if (honest_id == 1L) params$n_agents else honest_id - 1L
  successor_id <- if (honest_id == params$n_agents) 1L else honest_id + 1L

  agent_records <- vector("list", params$baseline_periods + 1L)
  edge_records <- list()
  metric_records <- vector("list", params$baseline_periods + 1L)

  initial_group <- rep("Other agents", params$n_agents)
  initial_group[honest_id] <- "Honest agent"
  initial_group[predecessor_id] <- "Predecessor"
  initial_group[successor_id] <- "Successor"
  agents$role <- ifelse(agents$forced_honest, "honest", "freelance_thief")
  agent_records[[1]] <- transform(
    agents,
    time = 0L,
    group = initial_group
  )

  rc <- role_counts(agents$role)
  metrics0 <- welfare_components(
    wealth = agents$wealth,
    role_counts = rc,
    cost_totals = list(
      theft_costs = 0,
      contracting_costs = 0,
      guarding_costs = 0,
      punishment_losses = 0
    ),
    params = params
  )
  metrics0$time <- 0L
  metrics0$n_agents <- params$n_agents
  metrics0$regime <- "Balanced cycle"
  metric_records[[1]] <- metrics0

  for (t in seq_len(params$baseline_periods)) {
    action <- ifelse(
      agents$forced_honest,
      "stay",
      ifelse(baseline_steal_rule(agents$wealth, params), "steal", "stay")
    )
    occupied <- action != "steal"
    delta <- rep(0, nrow(agents))

    for (i in seq_len(nrow(agents))) {
      if (action[i] != "steal" || agents$wealth[i] <= 0) {
        next
      }
      victim <- targets[i]
      success <- !occupied[victim]
      amount <- if (success) loot_unit(agents$wealth[victim], params) else 0
      if (amount > 0) {
        delta[i] <- delta[i] + amount
        delta[victim] <- delta[victim] - amount
      }
      edge_records[[length(edge_records) + 1L]] <- data.frame(
        time = t,
        from = i,
        to = victim,
        amount = amount,
        success = success,
        kind = "baseline_theft",
        stringsAsFactors = FALSE
      )
    }

    agents$wealth <- pmax(0, agents$wealth + delta)
    agents$role <- ifelse(
      agents$forced_honest,
      "honest",
      ifelse(action == "steal", "freelance_thief", "stay")
    )

    agent_records[[t + 1L]] <- transform(
      agents,
      time = t,
      group = initial_group
    )

    rc <- role_counts(agents$role)
    metrics <- welfare_components(
      wealth = agents$wealth,
      role_counts = rc,
      cost_totals = list(
        theft_costs = sum(action == "steal") * params$theft_cost,
        contracting_costs = 0,
        guarding_costs = 0,
        punishment_losses = 0
      ),
      params = params
    )
    metrics$time <- t
    metrics$n_agents <- params$n_agents
    metrics$regime <- if (t == 0) "Balanced cycle" else "Transition"
    metric_records[[t + 1L]] <- metrics
  }

  agents_df <- do.call(rbind, agent_records)
  metrics_df <- do.call(rbind, metric_records)
  edges_df <- if (length(edge_records)) do.call(rbind, edge_records) else data.frame()

  if (save_outputs) {
    ensure_dir(project_path("data", "processed"))
    write.csv(agents_df, project_path("data", "processed", "baseline_agents.csv"), row.names = FALSE)
    write.csv(metrics_df, project_path("data", "processed", "baseline_metrics.csv"), row.names = FALSE)
    write.csv(edges_df, project_path("data", "processed", "baseline_edges.csv"), row.names = FALSE)
  }

  list(agents = agents_df, metrics = metrics_df, edges = edges_df)
}

if (sys.nframe() == 0L) {
  invisible(simulate_baseline_path())
}
