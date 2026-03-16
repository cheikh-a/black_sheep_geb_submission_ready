suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(patchwork)
  library(scales)
  library(viridis)
  library(igraph)
  library(ggraph)
})

source(file.path(getwd(), "src", "06_parameter_sweeps.R"))

load_or_build_data <- function() {
  baseline_agents_file <- project_path("data", "processed", "baseline_agents.csv")
  patronage_agents_file <- project_path("data", "processed", "patronage_agents.csv")
  enforcement_agents_file <- project_path("data", "processed", "enforcement_agents.csv")
  regime_grid_file <- project_path("data", "processed", "regime_grid.csv")

  if (!file.exists(baseline_agents_file)) {
    simulate_baseline_path()
  }
  if (!file.exists(patronage_agents_file)) {
    simulate_patronage_path()
  }
  if (!file.exists(enforcement_agents_file)) {
    simulate_enforcement_path()
  }
  if (!file.exists(regime_grid_file)) {
    run_parameter_sweeps()
  }
}

selected_grid_levels <- function(x) {
  unique_values <- sort(unique(round(x, 2)))
  targets <- as.numeric(stats::quantile(unique_values, c(0.2, 0.5, 0.8), names = FALSE))
  sort(unique(vapply(targets, function(target) {
    unique_values[which.min(abs(unique_values - round(target, 2)))]
  }, numeric(1))))
}

make_figures <- function() {
  load_or_build_data()

  pretty_role_labels <- c(
    honest = "Honest",
    stay = "Stayers",
    freelance_thief = "Freelance thieves",
    hired_thief = "Hired thieves",
    patron = "Patrons",
    guard = "Guards",
    elite = "Elites",
    inactive = "Inactive"
  )
  pretty_series_labels <- c(
    total_wealth = "Total Wealth",
    utilitarian_welfare = "Expected Utility",
    theft_costs = "Theft Costs",
    contracting_costs = "Contracting Costs",
    guarding_costs = "Guarding Costs",
    punishment_losses = "Punishment Losses"
  )
  pretty_parameter_labels <- c(
    gamma = "Theft intensity",
    contract_cost = "Contracting cost",
    occupancy_success_prob = "Occupied-house vulnerability",
    target_advantage = "Targeting advantage"
  )

  baseline_agents <- read.csv(project_path("data", "processed", "baseline_agents.csv"))
  baseline_metrics <- read.csv(project_path("data", "processed", "baseline_metrics.csv"))
  patronage_agents <- read.csv(project_path("data", "processed", "patronage_agents.csv"))
  patronage_metrics <- read.csv(project_path("data", "processed", "patronage_metrics.csv"))
  enforcement_agents <- read.csv(project_path("data", "processed", "enforcement_agents.csv"))
  enforcement_metrics <- read.csv(project_path("data", "processed", "enforcement_metrics.csv"))
  enforcement_edges <- read.csv(project_path("data", "processed", "enforcement_edges.csv"))
  regime_grid <- read.csv(project_path("data", "processed", "regime_grid.csv"))
  contract_grid <- read.csv(project_path("data", "processed", "contract_grid.csv"))
  transition_timing <- read.csv(project_path("data", "processed", "transition_timing.csv"))
  sensitivity_metrics <- read.csv(project_path("data", "processed", "sensitivity_metrics.csv"))

  baseline_group_summary <- baseline_agents |>
    group_by(time, group) |>
    summarise(wealth = mean(wealth), .groups = "drop")

  fig01 <- ggplot(baseline_group_summary, aes(time, wealth, colour = group)) +
    geom_line(linewidth = 0.9) +
    geom_point(size = 1.6) +
    scale_colour_manual(values = c(
      "Honest agent" = "#2F6B5E",
      "Predecessor" = "#B24C63",
      "Successor" = "#6C4E97",
      "Other agents" = "#7A7A7A"
    )) +
    labs(
      title = "Balanced reciprocity breaks on the first honest night",
      subtitle = "The deterministic cycle shows the successor's windfall and the predecessor's immediate loss.",
      x = "Event time",
      y = "Mean wealth",
      colour = NULL,
      caption = "Figure 1 demonstrates that a single permanent honest deviation destroys the equal-wealth cycle immediately."
    ) +
    theme_black_sheep()
  save_figure_outputs(fig01, "fig01_balanced_cycle_event", 7.2, 4.6)

  first_night <- baseline_agents |>
    filter(time %in% c(0, 1)) |>
    select(id, time, wealth, group) |>
    tidyr::pivot_wider(names_from = time, values_from = wealth, names_prefix = "t") |>
    mutate(change = t1 - t0) |>
    group_by(group) |>
    summarise(change = mean(change), .groups = "drop")

  fig02 <- ggplot(first_night, aes(reorder(group, change), change, fill = group)) +
    geom_col(width = 0.7, colour = "white") +
    coord_flip() +
    scale_fill_manual(values = c(
      "Honest agent" = "#2F6B5E",
      "Predecessor" = "#B24C63",
      "Successor" = "#6C4E97",
      "Other agents" = "#7A7A7A"
    )) +
    labs(
      title = "First-night accounting is asymmetric and exact",
      subtitle = "Only the successor gains immediately; the honest agent is protected on the first night, then falls behind later.",
      x = NULL,
      y = "Change in wealth from $t=0$ to $t=1$",
      fill = NULL,
      caption = "Figure 2 fixes the timeline ambiguity by showing the realized first-night accounting implied by the deterministic perturbation."
    ) +
    theme_black_sheep()
  save_figure_outputs(fig02, "fig02_first_night_accounting", 7, 4.2)

  terminal_roles <- enforcement_agents |>
    filter(time >= max(time) - 10) |>
    count(id, role, sort = TRUE) |>
    group_by(id) |>
    slice_max(n, n = 1, with_ties = FALSE) |>
    ungroup() |>
    mutate(group = recode(
      role,
      honest = "Honest",
      patron = "Future patrons",
      elite = "Future patrons",
      hired_thief = "Hired thieves",
      guard = "Guards",
      freelance_thief = "Residual poor",
      stay = "Residual poor",
      inactive = "Residual poor"
    )) |>
    select(id, group)

  event_time_roles <- enforcement_agents |>
    left_join(terminal_roles, by = "id") |>
    group_by(time, group) |>
    summarise(mean_wealth = mean(wealth), median_wealth = median(wealth), .groups = "drop")

  fig03 <- ggplot(event_time_roles, aes(time, mean_wealth, colour = group)) +
    geom_line(linewidth = 0.9) +
    geom_point(size = 1.2) +
    scale_colour_manual(values = c(
      "Honest" = "#2F6B5E",
      "Future patrons" = "#6C4E97",
      "Hired thieves" = "#B24C63",
      "Guards" = "#356D9A",
      "Residual poor" = "#7A7A7A"
    )) +
    labs(
      title = "Wealth paths separate into durable social roles",
      subtitle = "Future patrons peel away from hired thieves, guards, and the residual poor soon after the perturbation.",
      x = "Time",
      y = "Mean wealth by eventual role",
      colour = NULL,
      caption = "Figure 3 demonstrates that the long-run class structure is visible early in the transition dynamics."
    ) +
    theme_black_sheep()
  save_figure_outputs(fig03, "fig03_event_time_roles", 7.4, 4.8)

  quantile_bands <- enforcement_agents |>
    group_by(time) |>
    summarise(
      q10 = quantile(wealth, 0.10),
      q25 = quantile(wealth, 0.25),
      q50 = quantile(wealth, 0.50),
      q75 = quantile(wealth, 0.75),
      q90 = quantile(wealth, 0.90),
      .groups = "drop"
    )

  p_dist_heat <- ggplot(enforcement_agents, aes(time, wealth)) +
    geom_bin2d(bins = 32) +
    scale_fill_viridis_c(option = "C", name = "Count") +
    labs(
      title = "Wealth mass migrates upward and downward quickly",
      x = "Time",
      y = "Wealth"
    ) +
    theme_black_sheep()

  p_dist_band <- ggplot(quantile_bands, aes(time, q50)) +
    geom_ribbon(aes(ymin = q10, ymax = q90), fill = "#C9D7CB", alpha = 0.7) +
    geom_ribbon(aes(ymin = q25, ymax = q75), fill = "#5B8E7D", alpha = 0.45) +
    geom_line(linewidth = 0.9, colour = "#1E3D36") +
    labs(
      title = "Central mass thins while the tails widen",
      x = "Time",
      y = "Wealth"
    ) +
    theme_black_sheep()

  fig04 <- p_dist_heat + p_dist_band +
    plot_annotation(
      title = "The wealth distribution evolves from equality to stratification",
      caption = "Figure 4 shows that the transition is not a one-agent anomaly: dispersion broadens and then hardens into a stratified distribution."
    )
  save_figure_outputs(fig04, "fig04_distribution_evolution", 10.4, 4.8)

  lorenz_times <- c(0, 5, 20, max(enforcement_agents$time))
  lorenz_df <- bind_rows(lapply(lorenz_times, function(tt) {
    lorenz_curve_df(enforcement_agents$wealth[enforcement_agents$time == tt], glue("t = {tt}"))
  }))

  p_gini <- ggplot(enforcement_metrics, aes(time, gini)) +
    geom_line(linewidth = 0.9, colour = "#B24C63") +
    labs(x = "Time", y = "Gini", title = "Inequality rises sharply") +
    theme_black_sheep()

  p_top10 <- ggplot(enforcement_metrics, aes(time, top10_share)) +
    geom_line(linewidth = 0.9, colour = "#6C4E97") +
    labs(x = "Time", y = "Top 10% wealth share", title = "Top-share concentration follows") +
    theme_black_sheep()

  p_lorenz <- ggplot(lorenz_df, aes(population_share, wealth_share, colour = label)) +
    geom_abline(slope = 1, intercept = 0, linewidth = 0.5, linetype = "dashed", colour = "grey50") +
    geom_line(linewidth = 0.9) +
    labs(x = "Population share", y = "Wealth share", title = "Lorenz curves fan out over time", colour = NULL) +
    theme_black_sheep()

  fig05 <- p_gini + p_top10 + p_lorenz +
    plot_annotation(
      title = "Inequality dynamics are persistent rather than transitory",
      caption = "Figure 5 demonstrates that the honest shock has durable distributional consequences, not just a temporary reshuffling of goods."
    )
  save_figure_outputs(fig05, "fig05_inequality_dynamics", 12.4, 4.8)

  slack_levels <- selected_grid_levels(contract_grid$slackness)
  target_levels <- selected_grid_levels(contract_grid$target_advantage)
  p_contract_heat <- ggplot(contract_grid, aes(target_advantage, slackness, fill = patron_surplus)) +
    geom_tile() +
    scale_fill_gradient2(low = "#B24C63", mid = "white", high = "#356D9A", midpoint = 0) +
    labs(
      title = "Patron surplus rises with targeting advantage",
      x = "Targeting advantage",
      y = "Poor-worker slackness",
      fill = "Patron surplus"
    ) +
    theme_black_sheep()

  p_contract_lines <- contract_grid |>
    filter(round(target_advantage, 2) %in% target_levels) |>
    mutate(
      target_band = factor(
        round(target_advantage, 2),
        levels = target_levels,
        labels = paste("Targeting advantage =", formatC(target_levels, format = "f", digits = 2))
      )
    ) |>
    select(slackness, target_band, thief_compensation, outside_option) |>
    pivot_longer(c(thief_compensation, outside_option), names_to = "series", values_to = "value") |>
    mutate(series = recode(
      series,
      thief_compensation = "Thief compensation",
      outside_option = "Outside option"
    )) |>
    ggplot(aes(slackness, value, colour = series, linetype = series)) +
    geom_line(linewidth = 0.9) +
    geom_point(size = 1.1) +
    facet_wrap(~ target_band, nrow = 1) +
    scale_colour_manual(values = c("Thief compensation" = "#356D9A", "Outside option" = "#B24C63")) +
    scale_linetype_manual(values = c("Thief compensation" = "solid", "Outside option" = "dashed")) +
    labs(
      title = "Compensation stays above the outside option",
      x = "Poor-worker slackness",
      y = "Expected compensation",
      colour = NULL
    ) +
    guides(linetype = "none") +
    theme_black_sheep()

  fig06 <- p_contract_heat + p_contract_lines +
    plot_annotation(
      title = "Contracts create strict patron surplus away from the knife-edge",
      caption = "Figure 6 shows that positive patron surplus comes from better targeting and weak outside options among poor thieves."
    )
  save_figure_outputs(fig06, "fig06_contracting_comparative_statics", 10.4, 4.8)

  fig07 <- ggplot(regime_grid, aes(gamma, enforcement_effectiveness, fill = dominant_regime)) +
    geom_tile() +
    scale_fill_manual(values = phase_palette, drop = FALSE) +
    labs(
      title = "Regime map",
      subtitle = "Higher theft intensity and stronger enforcement shift the medium-run regime in distinct ways.",
      x = expression(gamma),
      y = "Enforcement effectiveness",
      fill = NULL,
      caption = "Figure 7 demonstrates that the paper's regimes occupy distinct parameter regions rather than a single hand-picked path."
    ) +
    theme_black_sheep()
  save_figure_outputs(fig07, "fig07_regime_phase_diagram", 7.5, 4.8)

  role_levels <- c("Honest", "Stayers", "Freelance thieves", "Hired thieves", "Patrons", "Guards", "Elites", "Inactive")
  role_shares <- enforcement_agents |>
    mutate(plot_role = recode(
      role,
      elite = "Elites",
      patron = "Patrons",
      hired_thief = "Hired thieves",
      freelance_thief = "Freelance thieves",
      guard = "Guards",
      honest = "Honest",
      stay = "Stayers",
      inactive = "Inactive"
    )) |>
    mutate(plot_role = factor(plot_role, levels = role_levels)) |>
    count(time, plot_role) |>
    complete(time, plot_role, fill = list(n = 0)) |>
    group_by(time) |>
    mutate(share = n / sum(n)) |>
    ungroup() |>
    arrange(time, plot_role)

  fig08 <- ggplot(role_shares, aes(time, share, fill = plot_role)) +
    geom_area(position = "stack", alpha = 0.9) +
    scale_fill_manual(
      values = c(
        "Honest" = role_palette[["honest"]],
        "Stayers" = role_palette[["stay"]],
        "Freelance thieves" = role_palette[["freelance_thief"]],
        "Hired thieves" = role_palette[["hired_thief"]],
        "Patrons" = role_palette[["patron"]],
        "Guards" = role_palette[["guard"]],
        "Elites" = role_palette[["elite"]],
        "Inactive" = role_palette[["inactive"]]
      ),
      guide = guide_legend(nrow = 2)
    ) +
    scale_y_continuous(labels = percent_format(), expand = expansion(mult = c(0, 0.02))) +
    coord_cartesian(ylim = c(0, 1)) +
    labs(
      title = "Role composition changes as the system reorganizes",
      x = "Time",
      y = "Population share",
      fill = NULL,
      caption = "Figure 8 shows the endogenous transition from universal theft to patronage and then to guarded elite protection."
    ) +
    theme_black_sheep()
  save_figure_outputs(fig08, "fig08_role_shares", 7.6, 4.8)

  p_timing_patron <- ggplot(transition_timing, aes(factor(initial_honest), patron_complex_share_t3)) +
    geom_boxplot(width = 0.58, fill = "#DCC3CB", colour = "#B24C63", outlier.shape = NA) +
    geom_jitter(width = 0.08, height = 0, size = 1.5, alpha = 0.75, colour = "#8F344A") +
    scale_y_continuous(labels = percent_format(accuracy = 1)) +
    labs(
      x = "Initial honest agents",
      y = "Share in patronage roles at time 3",
      title = "Patronage reorganizes the population almost immediately"
    ) +
    theme_black_sheep()

  p_timing_guard <- ggplot(transition_timing, aes(factor(initial_honest), guard_share_5pct_time)) +
    geom_boxplot(width = 0.58, fill = "#BED1E5", colour = "#356D9A", outlier.shape = NA) +
    geom_jitter(width = 0.08, height = 0, size = 1.5, alpha = 0.75, colour = "#2D5D84") +
    labs(
      x = "Initial honest agents",
      y = "Time until guards reach 5 percent of agents",
      title = "The move into guarding is later and more dispersed"
    ) +
    theme_black_sheep()

  fig09 <- p_timing_patron + p_timing_guard +
    plot_annotation(
      title = "Initial honesty changes early patronage and later guard timing",
      caption = "The first patron appears at the earliest feasible post-shock contracting round in every run.\nThe left panel therefore measures patronage at time 3, while the right panel records when guards reach five percent of the population."
    )
  save_figure_outputs(fig09, "fig09_transition_timing", 10.2, 4.8)

  guard_time <- first_period_with(enforcement_metrics$n_guards > 0, enforcement_metrics$time)
  patron_time <- first_period_with(enforcement_metrics$n_patrons > 0, enforcement_metrics$time)
  snapshot_times <- unique(na.omit(c(1, patron_time, guard_time)))
  snapshot_titles <- c("First honest night", "Patronage network", "Guard regime")

  network_plots <- lapply(seq_along(snapshot_times), function(idx) {
    tt <- snapshot_times[idx]
    nodes <- enforcement_agents |>
      filter(time == tt) |>
      mutate(plot_role = recode(role, !!!pretty_role_labels)) |>
      group_by(plot_role) |>
      mutate(role_rank = rank(-wealth, ties.method = "first")) |>
      ungroup() |>
      mutate(
        plot_label = case_when(
          plot_role == "Honest" ~ "Honest",
          plot_role %in% c("Patrons", "Elites") & role_rank == 1 ~ "Elite",
          plot_role == "Guards" & role_rank == 1 ~ "Guard",
          plot_role == "Hired thieves" & role_rank == 1 ~ "Hired thief",
          TRUE ~ ""
        )
      ) |>
      select(id, role, wealth, plot_role, plot_label)
    edges <- enforcement_edges |>
      filter(time == tt, kind %in% c("baseline_theft", "delegated_theft", "freelance_theft", "patron_contract", "guard_contract")) |>
      mutate(kind = recode(
        kind,
        baseline_theft = "theft",
        delegated_theft = "theft",
        freelance_theft = "theft",
        patron_contract = "contract",
        guard_contract = "guard"
      )) |>
      select(from, to, amount, kind)
    if (!nrow(edges)) {
      return(
        ggplot() +
          annotate("text", x = 0, y = 0, label = "No edges at this date") +
          labs(title = snapshot_titles[idx]) +
          theme_void()
      )
    }
    graph <- graph_from_data_frame(edges, directed = TRUE, vertices = nodes)
    ggraph(graph, layout = "stress") +
      geom_edge_link(aes(width = amount, colour = kind), alpha = 0.5, show.legend = FALSE) +
      geom_node_point(aes(size = wealth, colour = plot_role), alpha = 0.9, show.legend = FALSE) +
      geom_node_text(
        aes(label = plot_label),
        repel = TRUE,
        size = 2.6,
        point.padding = unit(0.15, "lines"),
        max.overlaps = Inf
      ) +
      scale_edge_colour_manual(values = c(theft = "#B24C63", contract = "#6C4E97", guard = "#356D9A")) +
      scale_colour_manual(values = c(
        "Honest" = role_palette[["honest"]],
        "Stayers" = role_palette[["stay"]],
        "Freelance thieves" = role_palette[["freelance_thief"]],
        "Hired thieves" = role_palette[["hired_thief"]],
        "Patrons" = role_palette[["patron"]],
        "Guards" = role_palette[["guard"]],
        "Elites" = role_palette[["elite"]],
        "Inactive" = role_palette[["inactive"]]
      )) +
      scale_edge_width(range = c(0.2, 1.4), guide = "none") +
      scale_size(range = c(2, 6), guide = "none") +
      labs(title = snapshot_titles[idx]) +
      theme_void(base_family = "serif") +
      theme(plot.title = element_text(face = "bold", size = 11))
  })

  fig10 <- wrap_plots(network_plots, nrow = 1) +
    plot_annotation(
      title = "Network structure changes across regimes",
      caption = "Figure 10 shows the progression from direct theft to patronage links and finally to guard-based protection."
    )
  save_figure_outputs(fig10, "fig10_network_snapshots", 13.2, 5.0)

  welfare_long <- enforcement_metrics |>
    select(time, total_wealth, utilitarian_welfare, theft_costs, contracting_costs, guarding_costs, punishment_losses) |>
    pivot_longer(-time, names_to = "series", values_to = "value") |>
    mutate(series_label = recode(series, !!!pretty_series_labels))

  p_welfare_levels <- welfare_long |>
    filter(series %in% c("total_wealth", "utilitarian_welfare")) |>
    ggplot(aes(time, value, colour = series_label)) +
    geom_line(linewidth = 0.9) +
    scale_colour_manual(values = c("Total Wealth" = "#4C5B8F", "Expected Utility" = "#B24C63")) +
    labs(x = "Time", y = "Level", title = "Gross resources and welfare diverge", colour = NULL) +
    theme_black_sheep()

  p_welfare_costs <- welfare_long |>
    filter(series %in% c("theft_costs", "contracting_costs", "guarding_costs", "punishment_losses")) |>
    ggplot(aes(time, value, colour = series_label)) +
    geom_line(linewidth = 0.9) +
    scale_colour_manual(values = c(
      "Theft Costs" = "#E0A458",
      "Contracting Costs" = "#6C4E97",
      "Guarding Costs" = "#356D9A",
      "Punishment Losses" = "#4C4C4C"
    )) +
    labs(x = "Time", y = "Cost", title = "Resource-burning activity shifts form over time", colour = NULL) +
    theme_black_sheep()

  fig11 <- p_welfare_levels + p_welfare_costs +
    plot_annotation(
      title = "Welfare falls because the shock creates inequality and costly protection",
      caption = "Figure 11 demonstrates that the welfare loss is not a confusion about pure redistribution: it comes from concavity plus theft, contract, guard, and punishment costs."
    )
  save_figure_outputs(fig11, "fig11_welfare_decomposition", 10.4, 4.8)

  fig12 <- sensitivity_metrics |>
    pivot_longer(cols = c(final_gini, final_welfare), names_to = "outcome", values_to = "metric") |>
    mutate(
      outcome = recode(outcome, final_gini = "Final Gini", final_welfare = "Final Welfare"),
      parameter = factor(
        recode(parameter, !!!pretty_parameter_labels),
        levels = c("Contracting cost", "Occupied-house vulnerability", "Targeting advantage", "Theft intensity")
      ),
      dominant_regime = factor(
        dominant_regime,
        levels = c("Transition", "Guard regime", "Coexistence", "Collapse", "Patronage", "Balanced cycle")
      ),
      outcome = factor(outcome, levels = c("Final Gini", "Final Welfare"))
    ) |>
    ggplot(aes(value, metric, colour = outcome, group = 1)) +
    geom_line(linewidth = 0.9, show.legend = FALSE) +
    geom_point(aes(shape = dominant_regime, fill = dominant_regime), size = 2.2, stroke = 0.35, colour = "#333333") +
    facet_grid(outcome ~ parameter, scales = "free", switch = "y") +
    scale_colour_manual(values = c("Final Gini" = "#B24C63", "Final Welfare" = "#356D9A")) +
    scale_fill_manual(values = phase_palette, drop = TRUE) +
    scale_shape_manual(
      values = c(
        "Transition" = 24,
        "Guard regime" = 21,
        "Coexistence" = 22,
        "Collapse" = 23,
        "Patronage" = 25,
        "Balanced cycle" = 20
      ),
      drop = TRUE
    ) +
    labs(
      title = "Robustness across key parameters",
      subtitle = "Welfare is most responsive to theft intensity and occupied-house vulnerability, while inequality moves within a narrower band.",
      x = "Parameter value",
      y = "Outcome",
      colour = NULL,
      fill = "Dominant regime",
      shape = "Dominant regime",
      caption = "Figure 12 shows how final welfare and final inequality move in one-dimensional sweeps around the baseline calibration. Marker shapes identify the dominant regime reached at each parameter value."
    ) +
    theme_black_sheep() +
    theme(strip.placement = "outside")
  save_figure_outputs(fig12, "fig12_robustness_panels", 11.2, 6.8)
}

if (sys.nframe() == 0L) {
  make_figures()
}
