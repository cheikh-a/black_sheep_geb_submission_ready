source(file.path(getwd(), "src", "01_model_primitives.R"))

build_cycle_targets <- function(n_agents) {
  c(seq(2, n_agents), 1)
}

baseline_steal_rule <- function(wealth, params) {
  wealth <= params$initial_wealth + 1e-8
}

role_counts <- function(roles) {
  levels <- c("honest", "stay", "freelance_thief", "hired_thief", "patron", "guard", "elite", "inactive")
  counts <- setNames(integer(length(levels)), levels)
  tab <- table(factor(roles, levels = levels))
  counts[names(tab)] <- as.integer(tab)
  counts
}

classify_regime <- function(metrics_row) {
  n_agents <- if ("n_agents" %in% names(metrics_row)) metrics_row$n_agents else 60
  if (metrics_row$total_wealth < 0.30 * n_agents) {
    return("Collapse")
  }
  if (metrics_row$n_guards > 0) {
    if (metrics_row$n_patrons > 0) {
      return("Coexistence")
    }
    return("Guard regime")
  }
  if (metrics_row$n_patrons > 0) {
    return("Patronage")
  }
  if (metrics_row$gini > 0.08 || metrics_row$n_idle > metrics_row$n_honest) {
    return("Transition")
  }
  "Balanced cycle"
}

dominant_regime <- function(regime_series, tail_length = 20L) {
  if (!length(regime_series)) {
    return("Balanced cycle")
  }
  tail_length <- min(length(regime_series), tail_length)
  tail_series <- tail(regime_series, tail_length)
  names(sort(table(tail_series), decreasing = TRUE))[1]
}

first_period_with <- function(x, time = NULL) {
  idx <- which(x)
  if (!length(idx)) {
    return(NA_integer_)
  }
  if (is.null(time)) {
    return(idx[1])
  }
  time[idx[1]]
}

quantile_summary <- function(x, probs = c(0.1, 0.25, 0.5, 0.75, 0.9)) {
  if (!length(x)) {
    return(setNames(rep(0, length(probs)), paste0("q", probs * 100)))
  }
  values <- as.numeric(stats::quantile(x, probs = probs, names = FALSE))
  setNames(values, paste0("q", probs * 100))
}
