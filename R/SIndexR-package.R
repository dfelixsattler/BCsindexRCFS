#' BCsindexRCFS: Site Tools in R
#' @useDynLib BCsindexRCFS, .registration=TRUE
#' @importFrom Rcpp evalCpp
#' @importFrom stats aggregate optimize sd
#' @importFrom utils read.csv write.csv
#' @details
#'   The SiteTools external DLL backend used by this package is published by
#'   the Government of British Columbia and is available at:
#'   https://www2.gov.bc.ca/gov/content/industry/forestry/managing-our-forest-resources/forest-inventory/field-forms-and-software/software-download#SiteTools
#'
#' @section Definition -- Site Index and Suitable Site Trees:
#'   For a given species, site index is defined in BC as the height of the
#'   largest diameter (at breast height) site tree on a 0.01 ha plot at 50
#'   years, breast height age, provided the tree meets all the criteria of a
#'   suitable site tree. A minimum of seven (7) plots, containing suitable site
#'   trees, in each homogeneous stand stratum is recommended.
#'
#'   A suitable site tree, for a particular species, reflects the site's full,
#'   inherent height-growth potential. That is, a suitable site tree is a
#'   vigorous dominant or co-dominant tree, with a full crown and a straight,
#'   disease-free, undamaged stem. It cannot be a wolf, open-grown, or veteran
#'   tree. Furthermore, it must be free from historic influences affecting the
#'   expression of inherent site potential. This includes both negative effects
#'   (suppression, repression, damage, disease, etc.) and positive effects
#'   (fertilization, genetic improvement, etc.).
#'
#'   Reference: BC Ministry of Forests, Lands, Natural Resource Operations and
#'   Rural Development (2009). \emph{SIBEC Sampling and Data Standards}.
#'   \url{http://www2.gov.bc.ca/assets/gov/environment/research-monitoring-and-reporting/research/sibec-documents/standards.pdf}
#'
#' @keywords package
#' @seealso
#'   See `vignette("workflow-integration", package = "BCsindexRCFS")` for
#'   practical PSP and treelist workflow examples.
#'
#'   See `vignette("legacy-interfaces", package = "BCsindexRCFS")` for a complete
#'   reference of legacy function mappings and migration guidance.
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

