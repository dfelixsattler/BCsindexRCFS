## SiteTools validation helper

sindex_parse_sitetools_csv <- function(filepath) {
  lines <- readLines(filepath)

  bh_age_idx <- grep("BH Age", lines)
  if (length(bh_age_idx) != 1) {
    stop("Could not find the SiteTools table header in: ", filepath)
  }

  si_header_idx <- bh_age_idx + 1

  metadata <- list()
  for (i in seq_len(bh_age_idx - 1L)) {
    line <- lines[[i]]
    if (grepl(",", line, fixed = TRUE)) {
      parts <- strsplit(line, ",", fixed = TRUE)[[1]]
      if (length(parts) >= 2L) {
        key <- trimws(parts[[1]])
        value <- trimws(parts[[2]])
        if (nzchar(key) && nzchar(value)) {
          metadata[[key]] <- value
        }
      }
    }
  }

  si_parts <- strsplit(lines[[si_header_idx]], ",", fixed = TRUE)[[1]]
  si_values <- suppressWarnings(as.numeric(trimws(si_parts[-1L])))
  si_values <- si_values[!is.na(si_values)]

  table_lines <- lines[si_header_idx:length(lines)]
  tmpfile <- tempfile(fileext = ".csv")
  writeLines(table_lines, tmpfile)
  on.exit(unlink(tmpfile), add = TRUE)

  data <- read.csv(tmpfile, stringsAsFactors = FALSE, row.names = NULL)
  data <- data[!apply(is.na(data), 1L, all), , drop = FALSE]

  if ("X" %in% names(data)) {
    data <- data[data$X != "Y2BH", , drop = FALSE]
  }

  list(metadata = metadata, si_values = si_values, data = data)
}

sindex_validate_sitetools_table <- function(sitetools_data, species_code, species_name) {
  metadata <- sitetools_data$metadata
  si_values <- sitetools_data$si_values
  data <- sitetools_data$data

  first_col_name <- names(data)[1L]
  ages <- as.numeric(data[[first_col_name]])

  results <- list()
  for (si_idx in seq_along(si_values)) {
    si <- si_values[[si_idx]]
    col_idx <- si_idx + 1L

    sitetools_heights <- as.numeric(data[[col_idx]])
    r_heights <- sapply(ages, function(age) {
      tryCatch(
        SI2HT(age = age, age_type = 1, site_index = si, species = species_code),
        error = function(e) NA_real_
      )
    })

    diff <- sitetools_heights - r_heights
    pct_diff <- ifelse(sitetools_heights != 0, (diff / sitetools_heights) * 100, NA_real_)

    results[[si_idx]] <- data.frame(
      species = species_name,
      SI = si,
      Age = ages,
      SiteTools = sitetools_heights,
      R_Wrapper = r_heights,
      Difference = diff,
      Pct_Diff = pct_diff,
      stringsAsFactors = FALSE
    )
  }

  all_results <- do.call(rbind, results)
  rownames(all_results) <- NULL

  summary_stats <- aggregate(
    all_results[, c("Difference", "Pct_Diff")],
    by = list(SI = all_results$SI),
    FUN = function(x) c(
      Min = min(x, na.rm = TRUE),
      Max = max(x, na.rm = TRUE),
      Mean = mean(x, na.rm = TRUE),
      SD = sd(x, na.rm = TRUE)
    )
  )

  list(metadata = metadata, comparison = all_results, summary = summary_stats)
}

#' Validate SiteTools CSV exports against SIndexR
#'
#' Reads one or more SiteTools 4.4 CSV exports, compares the height table for
#' each species against the corresponding SIndexR wrapper, and optionally writes
#' comparison CSV files.
#'
#' @param csv_files named character vector of CSV file paths. Names must be
#'   SIndexR species codes (e.g. `c(FDC = "path/to/fd.csv", CWC = "path/to/cw.csv")`).
#'   Any species exported from SiteTools can be included.
#' @param output_dir directory where comparison CSV files are written. Defaults
#'   to the directory of the first CSV file.
#' @param use_external_dll logical; if TRUE, route calculations through the
#'   runtime external DLL backend configured via `set_external_dll()`
#' @param external_dll_path optional path to the external DLL to load before
#'   validating. If omitted and `use_external_dll` is TRUE, falls back to the
#'   `SINDEX_EXTERNAL_DLL` environment variable or `C:/sindex64.dll`
#' @param save_results logical; write one comparison CSV per species to `output_dir`
#' @param verbose logical; print per-species summaries to the console
#' @return a list with a named entry per species code (each containing
#'   `metadata`, `comparison`, and `summary`) plus a `files` entry with the
#'   written CSV paths
#' @examples
#' \dontrun{
#' validate_site_tools(
#'   csv_files = c(
#'     FDC = "C:/SIndexR/my_tests/SiteToolsExport_Fd.csv",
#'     CWC = "C:/SIndexR/my_tests/SiteToolsExport_Cw.csv"
#'   ),
#'   output_dir = "C:/SIndexR/my_tests",
#'   use_external_dll = TRUE,
#'   external_dll_path = "C:/sindex64.dll"
#' )
#' }
#' @export
validate_site_tools <- function(csv_files,
                                output_dir = dirname(csv_files[[1]]),
                                use_external_dll = FALSE,
                                external_dll_path = NULL,
                                save_results = TRUE,
                                verbose = TRUE) {
  if (!is.character(csv_files) || is.null(names(csv_files)) || any(!nzchar(names(csv_files)))) {
    stop("csv_files must be a named character vector of species code -> CSV path, ",
         "e.g. c(FDC = 'path/to/fd.csv', CWC = 'path/to/cw.csv')")
  }

  for (path in csv_files) {
    if (!file.exists(path)) {
      stop("CSV does not exist: ", path)
    }
  }

  dll_loaded <- FALSE
  if (isTRUE(use_external_dll)) {
    if (is.null(external_dll_path)) {
      external_dll_path <- Sys.getenv("SINDEX_EXTERNAL_DLL", unset = "C:/sindex64.dll")
    }
    if (!nzchar(external_dll_path)) {
      stop("use_external_dll is TRUE but no external_dll_path was supplied.")
    }
    dll_loaded <- isTRUE(set_external_dll(external_dll_path))
  }

  on.exit({
    if (dll_loaded) clear_external_dll()
  }, add = TRUE)

  results <- list()
  file_paths <- list()

  for (sp_code in names(csv_files)) {
    path <- csv_files[[sp_code]]
    sp_label <- tryCatch(species_name(sp_code), error = function(e) sp_code)

    parsed <- sindex_parse_sitetools_csv(path)
    result <- sindex_validate_sitetools_table(parsed, sp_code, sp_label)
    results[[sp_code]] <- result

    if (save_results) {
      if (!dir.exists(output_dir)) {
        dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
      }
      out_file <- file.path(output_dir, paste0("Validation_", sp_code, "_Comparison.csv"))
      write.csv(result$comparison, out_file, row.names = FALSE)
      file_paths[[sp_code]] <- out_file
    } else {
      file_paths[[sp_code]] <- NA_character_
    }

    if (verbose) {
      cat(sp_label, "(", sp_code, ") summary:\n")
      print(result$summary)
      cat("\n")
    }
  }

  c(results, list(files = file_paths))
}