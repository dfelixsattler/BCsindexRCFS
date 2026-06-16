#' @useDynLib SIndexR, .registration=TRUE
#' @importFrom Rcpp evalCpp
#' @keywords internal
"_PACKAGE"

# Track one-time legacy interface warnings for the current R session.
.sindexr_legacy_warned <- new.env(parent = emptyenv())

sindex_warn_legacy_once <- function(old_name, new_name) {
	key <- paste0(old_name, "->", new_name)
	if (!exists(key, envir = .sindexr_legacy_warned, inherits = FALSE)) {
		assign(key, TRUE, envir = .sindexr_legacy_warned)
		warning(
			sprintf("%s() is a legacy compatibility interface; prefer %s() for new code.", old_name, new_name),
			call. = FALSE
		)
	}
	invisible(NULL)
}
