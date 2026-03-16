source(file.path(getwd(), "src", "04_simulate_patronage.R"))

simulate_enforcement_path <- function(
    params = default_parameters(),
    periods = params$enforcement_periods,
    save_outputs = TRUE,
    seed = params$seed + 200L) {
  simulate_patronage_path(
    params = params,
    periods = periods,
    allow_guards = TRUE,
    save_outputs = save_outputs,
    seed = seed,
    prefix = "enforcement"
  )
}

if (sys.nframe() == 0L) {
  invisible(simulate_enforcement_path())
}
