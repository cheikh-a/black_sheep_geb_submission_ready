source(file.path(getwd(), "src", "03_simulate_baseline.R"))

sample_target <- function(attacker_id, agents, allowed_ids, params, rich_cut, patron_norm_active) {
  pool <- allowed_ids[allowed_ids != attacker_id & agents$wealth[allowed_ids] > 0]
  if (!length(pool)) {
    return(NA_integer_)
  }

  weights <- numeric(length(pool))
  for (k in seq_along(pool)) {
    target_id <- pool[k]
    target_role <- agents$role[target_id]
    guarded <- !is.na(agents$guarded_by[target_id])
    success_prob <- if (guarded) {
      params$guard_success_prob
    } else if (target_role %in% c("stay", "patron", "elite")) {
      params$occupancy_success_prob
    } else if (target_role == "honest") {
      1
    } else {
      1
    }
    norm_penalty <- if (patron_norm_active && target_role %in% c("patron", "elite")) 0.20 else 1
    weights[k] <- max(1e-6, success_prob * agents$wealth[target_id] * norm_penalty)
  }

  pool[sample.int(length(pool), size = 1L, prob = weights)]
}

record_period_state <- function(agents, time) {
  transform(
    agents,
    time = time,
    guarded = !is.na(guarded_by)
  )
}

simulate_patronage_path <- function(
    params = default_parameters(),
    periods = params$patronage_periods,
    allow_guards = FALSE,
    save_outputs = TRUE,
    seed = params$seed + if (allow_guards) 200L else 100L,
    prefix = if (allow_guards) "enforcement" else "patronage") {
  set.seed(seed)

  agents <- initial_agent_state(params)
  if (!"honest_ids" %in% names(params)) {
    params$honest_ids <- which(agents$forced_honest)
  }
  agents$role <- ifelse(agents$forced_honest, "honest", "freelance_thief")
  agents$guarded_by <- NA_integer_
  targets <- build_cycle_targets(params$n_agents)

  agent_records <- list(record_period_state(agents, 0L))
  edge_records <- list()
  metric_records <- list()

  metrics0 <- welfare_components(
    wealth = agents$wealth,
    role_counts = role_counts(agents$role),
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
  metrics0$rich_threshold <- rich_threshold(agents$wealth, params)
  metrics0$elite_threshold <- elite_threshold(agents$wealth, params)
  metrics0$regime <- "Balanced cycle"
  metric_records[[1]] <- metrics0

  for (t in seq_len(periods)) {
    period_costs <- list(
      theft_costs = 0,
      contracting_costs = 0,
      guarding_costs = 0,
      punishment_losses = 0
    )
    agents$guarded_by <- NA_integer_

    if (t == 1L) {
      action <- ifelse(agents$forced_honest, "stay", "steal")
      delta <- rep(0, nrow(agents))
      agents$role <- ifelse(agents$forced_honest, "honest", "freelance_thief")

      for (i in seq_len(nrow(agents))) {
        if (action[i] != "steal" || agents$wealth[i] <= 0) {
          next
        }
        victim <- targets[i]
        success <- !agents$forced_honest[victim]
        amount <- if (success) loot_unit(agents$wealth[victim], params) else 0
        if (amount > 0) {
          delta[i] <- delta[i] + amount
          delta[victim] <- delta[victim] - amount
        }
        period_costs$theft_costs <- period_costs$theft_costs + params$theft_cost
        delta[i] <- delta[i] - params$theft_cost
        edge_records[[length(edge_records) + 1L]] <- data.frame(
          time = t,
          from = i,
          to = victim,
          amount = amount,
          kind = "baseline_theft",
          stringsAsFactors = FALSE
        )
      }

      agents$wealth <- pmax(0, agents$wealth + delta)
    } else {
      rich_cut <- rich_threshold(agents$wealth, params)
      elite_cut <- elite_threshold(agents$wealth, params)
      poor_ids <- agents$id[!agents$forced_honest & agents$wealth > 0 & agents$wealth < rich_cut]
      rich_ids <- agents$id[!agents$forced_honest & agents$wealth >= rich_cut]

      agents$role <- ifelse(agents$forced_honest, "honest", "inactive")

      available_workers <- poor_ids[order(agents$wealth[poor_ids], decreasing = FALSE)]
      patron_assignments <- integer(0)
      guard_assignments <- integer(0)
      contract_details <- list()
      raid_prob <- raid_pressure(agents, params)
      poor_wealth <- agents$wealth[poor_ids]
      contract <- compute_contract_terms(poor_wealth, params)

      if (length(rich_ids)) {
        rich_sorted <- rich_ids[order(agents$wealth[rich_ids], decreasing = TRUE)]
        for (i in rich_sorted) {
          self_value <- expected_personal_payoff(agents$wealth[i], poor_wealth, params)
          hire_value <- contract$patron_profit
          guard_value <- expected_guard_value(agents$wealth[i], raid_prob, params)

          can_guard <- allow_guards &&
            agents$wealth[i] > elite_cut &&
            length(available_workers) > 0L &&
            guard_value > max(0, params$guard_profit_ratio * max(hire_value, 0), self_value)

          if (can_guard) {
            worker <- available_workers[1]
            available_workers <- available_workers[-1]
            agents$role[i] <- "elite"
            agents$role[worker] <- "guard"
            agents$guarded_by[i] <- worker
            guard_assignments <- c(guard_assignments, worker)
            agents$wealth[i] <- pmax(0, agents$wealth[i] - params$guard_wage)
            agents$wealth[worker] <- agents$wealth[worker] + params$guard_wage
            period_costs$guarding_costs <- period_costs$guarding_costs + params$guard_wage
            edge_records[[length(edge_records) + 1L]] <- data.frame(
              time = t,
              from = i,
              to = worker,
              amount = params$guard_wage,
              kind = "guard_contract",
              stringsAsFactors = FALSE
            )
            next
          }

          can_hire <- length(available_workers) > 0L &&
            agents$wealth[i] > (contract$wage + params$contract_cost) &&
            hire_value > max(0, self_value)

          if (can_hire) {
            worker <- available_workers[1]
            available_workers <- available_workers[-1]
            agents$role[i] <- "patron"
            agents$role[worker] <- "hired_thief"
            patron_assignments <- c(patron_assignments, worker)
            contract_details[[as.character(worker)]] <- list(
              patron = i,
              wage = contract$wage,
              alpha = contract$alpha
            )
            agents$wealth[i] <- pmax(0, agents$wealth[i] - contract$wage - params$contract_cost)
            agents$wealth[worker] <- agents$wealth[worker] + contract$wage
            period_costs$contracting_costs <- period_costs$contracting_costs + params$contract_cost
            edge_records[[length(edge_records) + 1L]] <- data.frame(
              time = t,
              from = i,
              to = worker,
              amount = contract$wage,
              kind = "patron_contract",
              stringsAsFactors = FALSE
            )
            next
          }

          agents$role[i] <- "stay"
        }
      }

      remaining_poor <- agents$id[agents$role == "inactive" & !agents$forced_honest & agents$wealth > 0]
      if (length(remaining_poor)) {
        for (i in remaining_poor) {
          if (agents$wealth[i] < rich_cut || raid_prob > 0.25) {
            agents$role[i] <- "freelance_thief"
          } else {
            agents$role[i] <- "stay"
          }
        }
      }

      attackers <- agents$id[agents$role %in% c("hired_thief", "freelance_thief") & agents$wealth > 0]
      attackers <- sample(attackers, length(attackers))
      patron_norm_active <- any(agents$role == "patron")

      for (attacker in attackers) {
        if (agents$wealth[attacker] <= 0) {
          next
        }
        is_hired <- agents$role[attacker] == "hired_thief"
        allowed_ids <- if (is_hired) {
          agents$id[!agents$forced_honest & agents$wealth > 0 & agents$wealth < rich_cut]
        } else {
          agents$id[agents$wealth > 0]
        }
        target <- sample_target(attacker, agents, allowed_ids, params, rich_cut, patron_norm_active)
        if (is.na(target)) {
          next
        }

        guarded <- !is.na(agents$guarded_by[target])
        target_role <- agents$role[target]
        success_prob <- if (guarded) {
          params$guard_success_prob
        } else if (target_role %in% c("stay", "patron", "elite")) {
          params$occupancy_success_prob
        } else if (target_role == "honest") {
          1
        } else {
          1
        }

        period_costs$theft_costs <- period_costs$theft_costs + params$theft_cost
        agents$wealth[attacker] <- pmax(0, agents$wealth[attacker] - params$theft_cost)

        if (stats::runif(1) < success_prob) {
          amount <- loot_proportional(agents$wealth[target], params)
          amount <- min(amount, agents$wealth[target])
          agents$wealth[target] <- pmax(0, agents$wealth[target] - amount)

          if (is_hired) {
            details <- contract_details[[as.character(attacker)]]
            patron <- details$patron
            alpha <- details$alpha
            agents$wealth[attacker] <- agents$wealth[attacker] + alpha * amount
            agents$wealth[patron] <- agents$wealth[patron] + (1 - alpha) * amount
          } else {
            agents$wealth[attacker] <- agents$wealth[attacker] + amount
          }

          edge_records[[length(edge_records) + 1L]] <- data.frame(
            time = t,
            from = attacker,
            to = target,
            amount = amount,
            kind = if (is_hired) "delegated_theft" else "freelance_theft",
            stringsAsFactors = FALSE
          )
        } else if (guarded && stats::runif(1) < params$punishment_prob) {
          loss <- params$punishment_severity * agents$wealth[attacker]
          agents$wealth[attacker] <- pmax(0, agents$wealth[attacker] - loss)
          period_costs$punishment_losses <- period_costs$punishment_losses + loss
          edge_records[[length(edge_records) + 1L]] <- data.frame(
            time = t,
            from = attacker,
            to = target,
            amount = loss,
            kind = "punishment",
            stringsAsFactors = FALSE
          )
        }
      }
    }

    agents$wealth <- pmax(0, agents$wealth)

    rc <- role_counts(agents$role)
    metrics <- welfare_components(
      wealth = agents$wealth,
      role_counts = rc,
      cost_totals = period_costs,
      params = params
    )
    metrics$time <- t
    metrics$n_agents <- params$n_agents
    metrics$rich_threshold <- rich_threshold(agents$wealth, params)
    metrics$elite_threshold <- elite_threshold(agents$wealth, params)
    metrics$regime <- classify_regime(metrics)

    agent_records[[length(agent_records) + 1L]] <- record_period_state(agents, t)
    metric_records[[length(metric_records) + 1L]] <- metrics
  }

  agents_df <- do.call(rbind, agent_records)
  metrics_df <- do.call(rbind, metric_records)
  edges_df <- if (length(edge_records)) do.call(rbind, edge_records) else data.frame()

  if (save_outputs) {
    ensure_dir(project_path("data", "processed"))
    write.csv(agents_df, project_path("data", "processed", paste0(prefix, "_agents.csv")), row.names = FALSE)
    write.csv(metrics_df, project_path("data", "processed", paste0(prefix, "_metrics.csv")), row.names = FALSE)
    write.csv(edges_df, project_path("data", "processed", paste0(prefix, "_edges.csv")), row.names = FALSE)
  }

  list(agents = agents_df, metrics = metrics_df, edges = edges_df)
}

if (sys.nframe() == 0L) {
  invisible(simulate_patronage_path())
}
