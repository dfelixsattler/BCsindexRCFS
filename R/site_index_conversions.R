# Site index conversions
# Modern public API: si_to_si(), site_class_to_index()
# Legacy aliases:    SI2SI(), SC2SI(), SiteClassToIndex()

#' Convert site index between species
#'
#' Converts site index from a source species to a target species using
#' the internal species conversion table.
#'
#' @param source_species integer/numeric species index or species code (e.g. "BA", "HWC")
#' @param site_index numeric, source species site index value
#' @param target_species integer/numeric species index or species code (e.g. "BA", "HWC")
#' @param source_fiz optional FIZ code used when remapping source species codes
#' @param target_fiz optional FIZ code used when remapping target species codes
#' @return numeric converted site index, or a negative SIndex error code
#' @examples
#' si_to_si("BA", 20, "HWC")
#' si_to_si(11, 20, 48)
#' @export
si_to_si <- function(source_species, site_index, target_species, source_fiz = NULL, target_fiz = NULL) {
  sp_index1 <- SIndexR_SpeciesIndex(source_species, fiz = source_fiz)
  sp_index2 <- SIndexR_SpeciesIndex(target_species, fiz = target_fiz)

  if (length(sp_index1) != 1 || length(sp_index2) != 1) {
    stop("source_species and target_species must each resolve to a single species index.")
  }

  Sindex_SITOSI(as.integer(sp_index1), as.numeric(site_index), as.integer(sp_index2))
}

#' @export
#' @noRd
SI2SI <- function(...) si_to_si(...)

#' Convert site class to site index
#'
#' Translates site class code (G/M/P/L) to estimated site index (height in metres).
#' Used where total age is small (under 30 years), where site index based on height may not be reliable.
#' For details on site class definitions, see the SiteTools documentation:
#' https://www2.gov.bc.ca/assets/gov/farming-natural-resources-and-industry/forestry/silviculture/training-modules/sicourse.pdf
#'
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param site_class character, one of "G" (good), "M" (medium), "P" (poor), "L" (low)
#' @param fiz optional FIZ code (character: A-C for coast, D-L for interior)
#' @return numeric site index (height in metres)
#' @examples
#' site_class_to_index("FDI", "M")
#' site_class_to_index(11, "P", "H")
#' @export
site_class_to_index <- function(species, site_class, fiz = NULL) {
  sp_index <- SIndexR_SpeciesIndex(species, fiz = fiz)

  if (length(sp_index) != 1) {
    stop("species must resolve to a single species index.")
  }

  if (!site_class %in% c("G", "M", "P", "L")) {
    stop("site_class must be one of 'G', 'M', 'P', or 'L'.")
  }

  if (!is.null(fiz)) {
    if (!fiz %in% c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L")) {
      stop("fiz must be a valid Forest Inventory Zone code (A-C for coast, D-L for interior).")
    }
  } else {
    fiz <- ""
  }

  sindex_class_to_index(as.integer(sp_index), site_class, fiz)
}

#' @export
#' @noRd
SC2SI <- function(...) site_class_to_index(...)

#' @export
#' @noRd
SiteClassToIndex <- function(...) site_class_to_index(...)
