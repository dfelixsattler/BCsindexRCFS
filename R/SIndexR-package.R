#' SIndexRCFS: Site Tools in R
#' @useDynLib SIndexRCFS, .registration=TRUE
#' @importFrom Rcpp evalCpp
#' @importFrom stats aggregate optimize sd
#' @importFrom utils read.csv write.csv
#' @details
#'   The SiteTools external DLL backend used by this package is published by
#'   the Government of British Columbia and is available at:
#'   https://www2.gov.bc.ca/gov/content/industry/forestry/managing-our-forest-resources/forest-inventory/field-forms-and-software/software-download#SiteTools
#' @keywords internal
#' @seealso See `vignette("legacy-interfaces")` for a complete reference of legacy
#'   function mappings and migration guidance.
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

