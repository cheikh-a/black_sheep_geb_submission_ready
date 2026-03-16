suppressPackageStartupMessages({
  library(ggplot2)
  library(glue)
  library(scales)
})

repo_root <- function() {
  normalizePath(getwd(), winslash = "/", mustWork = TRUE)
}

project_path <- function(...) {
  file.path(repo_root(), ...)
}

ensure_dir <- function(path) {
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  invisible(path)
}

clamp <- function(x, lower, upper) {
  pmin(pmax(x, lower), upper)
}

safe_mean <- function(x) {
  x <- x[is.finite(x)]
  if (!length(x)) {
    return(0)
  }
  mean(x)
}

safe_sum <- function(x) {
  x <- x[is.finite(x)]
  if (!length(x)) {
    return(0)
  }
  sum(x)
}

gini_coefficient <- function(x) {
  x <- as.numeric(x)
  x <- x[is.finite(x) & x >= 0]
  n <- length(x)
  if (n == 0L) {
    return(0)
  }
  total <- sum(x)
  if (total <= 0) {
    return(0)
  }
  x <- sort(x)
  index <- seq_len(n)
  (2 * sum(index * x) / (n * total)) - (n + 1) / n
}

top_share <- function(x, p = 0.1) {
  x <- as.numeric(x)
  x <- x[is.finite(x) & x >= 0]
  if (!length(x) || sum(x) <= 0) {
    return(0)
  }
  n_top <- max(1L, ceiling(length(x) * p))
  sum(sort(x, decreasing = TRUE)[seq_len(n_top)]) / sum(x)
}

lorenz_curve_df <- function(x, label) {
  x <- as.numeric(x)
  x <- x[is.finite(x) & x >= 0]
  if (!length(x) || sum(x) <= 0) {
    return(data.frame(
      population_share = c(0, 1),
      wealth_share = c(0, 1),
      label = label,
      stringsAsFactors = FALSE
    ))
  }
  x <- sort(x)
  pop <- seq_along(x) / length(x)
  wealth <- cumsum(x) / sum(x)
  data.frame(
    population_share = c(0, pop),
    wealth_share = c(0, wealth),
    label = rep(label, length(pop) + 1L),
    stringsAsFactors = FALSE
  )
}

phase_palette <- c(
  "Balanced cycle" = "#5B8E7D",
  "Transition" = "#E0A458",
  "Patronage" = "#B24C63",
  "Guard regime" = "#4C5B8F",
  "Coexistence" = "#8E6C88",
  "Collapse" = "#4C4C4C"
)

role_palette <- c(
  honest = "#2F6B5E",
  stay = "#6B8F71",
  freelance_thief = "#D98E04",
  hired_thief = "#B24C63",
  patron = "#6C4E97",
  guard = "#356D9A",
  elite = "#274A7A",
  inactive = "#7A7A7A"
)

theme_black_sheep <- function() {
  theme_minimal(base_size = 11, base_family = "Times") +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      plot.title = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size = 10, colour = "grey25"),
      axis.title = element_text(face = "bold"),
      legend.position = "bottom",
      legend.title = element_text(face = "bold"),
      strip.text = element_text(face = "bold"),
      plot.caption = element_text(hjust = 0, size = 9, colour = "grey30")
    )
}

save_figure_outputs <- function(plot, name, width = 7, height = 4.5, dpi = 400) {
  ensure_dir(project_path("output", "figures"))
  ensure_dir(project_path("paper", "figures"))
  pdf_output <- project_path("output", "figures", glue("{name}.pdf"))
  png_output <- project_path("output", "figures", glue("{name}.png"))
  pdf_paper <- project_path("paper", "figures", glue("{name}.pdf"))
  png_paper <- project_path("paper", "figures", glue("{name}.png"))

  ggsave(pdf_output, plot = plot, width = width, height = height, device = cairo_pdf, family = "Times")
  ggsave(png_output, plot = plot, width = width, height = height, dpi = dpi)
  ggsave(pdf_paper, plot = plot, width = width, height = height, device = cairo_pdf, family = "Times")
  ggsave(png_paper, plot = plot, width = width, height = height, dpi = dpi)
}

write_csv_outputs <- function(df, name) {
  ensure_dir(project_path("output", "tables"))
  ensure_dir(project_path("paper", "tables"))
  write.csv(df, project_path("output", "tables", glue("{name}.csv")), row.names = FALSE)
  write.csv(df, project_path("paper", "tables", glue("{name}.csv")), row.names = FALSE)
}

latex_escape <- function(x) {
  x <- gsub("\\\\", "\\\\textbackslash{}", x)
  x <- gsub("([#$%&_{}])", "\\\\\\1", x, perl = TRUE)
  x <- gsub("\\^", "\\\\textasciicircum{}", x)
  x <- gsub("~", "\\\\textasciitilde{}", x)
  x
}

write_latex_table <- function(df, name, align = NULL, digits = 3) {
  ensure_dir(project_path("output", "tables"))
  ensure_dir(project_path("paper", "tables"))
  if (is.null(align)) {
    align <- paste(rep("l", ncol(df)), collapse = "")
  }
  formatted <- df
  for (j in seq_along(formatted)) {
    if (is.numeric(formatted[[j]])) {
      formatted[[j]] <- number(formatted[[j]], accuracy = 10^(-digits), big.mark = ",")
    } else {
      values <- as.character(formatted[[j]])
      is_math <- grepl("^\\$.*\\$$", values)
      values[!is_math] <- latex_escape(values[!is_math])
      formatted[[j]] <- values
    }
  }
  header <- paste(latex_escape(names(formatted)), collapse = " & ")
  body <- apply(formatted, 1, function(row) paste(row, collapse = " & "))
  body <- paste0(body, " \\\\")
  lines <- c(
    glue("\\begin{{tabular}}{{{align}}}"),
    "\\toprule",
    glue("{header} \\\\"),
    "\\midrule",
    body,
    "\\bottomrule",
    "\\end{tabular}"
  )
  output_file <- project_path("output", "tables", glue("{name}.tex"))
  paper_file <- project_path("paper", "tables", glue("{name}.tex"))
  writeLines(lines, output_file)
  writeLines(lines, paper_file)
}
