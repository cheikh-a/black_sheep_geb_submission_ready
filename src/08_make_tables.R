suppressPackageStartupMessages({
  library(dplyr)
})

source(file.path(getwd(), "src", "06_parameter_sweeps.R"))

load_or_build_tables_data <- function() {
  if (!file.exists(project_path("data", "processed", "enforcement_metrics.csv"))) {
    simulate_enforcement_path()
  }
  if (!file.exists(project_path("data", "processed", "regime_grid.csv"))) {
    run_parameter_sweeps()
  }
}

medium_run_dominant_regime <- function(metrics, params) {
  if (!"time" %in% names(metrics)) {
    return(dominant_regime(metrics$regime, params$phase_tail))
  }
  window_metrics <- metrics[metrics$time <= params$sweep_periods, , drop = FALSE]
  dominant_regime(window_metrics$regime, params$phase_tail)
}

format_parameter_value <- function(x) {
  if (isTRUE(all.equal(x, round(x)))) {
    return(format(round(x), trim = TRUE, scientific = FALSE))
  }
  sprintf("%.3f", x)
}

format_period <- function(x) {
  if (is.na(x)) {
    return("Not reached")
  }
  format(round(x), trim = TRUE, scientific = FALSE)
}

parameter_table_df <- function(params = default_parameters()) {
  data.frame(
    Symbol = c("$N$", "$\\gamma$", "$\\bar{w}$", "$\\theta_R$", "$\\theta_E$", "$s$", "$\\alpha$", "$\\kappa$", "$g$", "$q$"),
    Value = vapply(
      c(
        params$n_agents,
        params$gamma,
        params$initial_wealth,
        params$rich_multiplier,
        params$elite_multiplier,
        params$base_wage,
        params$alpha_target,
        params$contract_cost,
        params$guard_wage,
        1 - params$guard_success_prob
      ),
      format_parameter_value,
      character(1)
    ),
    Description = c(
      "Number of agents",
      "Proportional theft intensity",
      "Initial wealth per agent",
      "Rich threshold multiplier",
      "Elite threshold multiplier",
      "Base contract wage",
      "Thief loot share under contract",
      "Contracting cost",
      "Guard wage",
      "Guard effectiveness"
    ),
    stringsAsFactors = FALSE
  )
}

make_tables <- function() {
  load_or_build_tables_data()

  params <- default_parameters()
  baseline_metrics <- read.csv(project_path("data", "processed", "baseline_metrics.csv"))
  patronage_metrics <- read.csv(project_path("data", "processed", "patronage_metrics.csv"))
  enforcement_metrics <- read.csv(project_path("data", "processed", "enforcement_metrics.csv"))
  regime_grid <- read.csv(project_path("data", "processed", "regime_grid.csv"))

  params_df <- parameter_table_df(params)
  write_csv_outputs(params_df, "table_parameters")
  write_latex_table(params_df, "table_parameters", align = "lll", digits = 3)

  summary_df <- data.frame(
    Scenario = c("Baseline perturbation", "Patronage dynamics", "Enforcement dynamics"),
    `Gini` = c(
      tail(baseline_metrics$gini, 1),
      tail(patronage_metrics$gini, 1),
      tail(enforcement_metrics$gini, 1)
    ),
    `Top decile` = c(
      tail(baseline_metrics$top10_share, 1),
      tail(patronage_metrics$top10_share, 1),
      tail(enforcement_metrics$top10_share, 1)
    ),
    `First patron` = c(
      format_period(NA),
      format_period(first_period_with(patronage_metrics$n_patrons > 0, patronage_metrics$time)),
      format_period(first_period_with(enforcement_metrics$n_patrons > 0, enforcement_metrics$time))
    ),
    `First guard` = c(
      format_period(NA),
      format_period(NA),
      format_period(first_period_with(enforcement_metrics$n_guards > 0, enforcement_metrics$time))
    ),
    `Regime` = c(
      medium_run_dominant_regime(baseline_metrics, params),
      medium_run_dominant_regime(patronage_metrics, params),
      medium_run_dominant_regime(enforcement_metrics, params)
    ),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  write_csv_outputs(summary_df, "table_simulation_summary")
  write_latex_table(summary_df, "table_simulation_summary", align = "lcccll", digits = 3)

  regime_counts <- regime_grid |>
    count(dominant_regime, name = "Frequency") |>
    rename(`Dominant regime` = dominant_regime) |>
    arrange(desc(Frequency))
  write_csv_outputs(regime_counts, "table_regime_frequencies")
  write_latex_table(regime_counts, "table_regime_frequencies", align = "lr", digits = 0)
}

if (sys.nframe() == 0L) {
  make_tables()
}
