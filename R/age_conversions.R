# Age conversions
# Modern public API: si_to_y2bh(), si_to_y2bh05(), age_to_age()
# Legacy aliases:    Age2Age(), AgeToAge()

#' Years to breast height (y2bh)
#'
#' Compute the years-to-breast-height value from the species/curve index and site index.
#'
#' @param cu_index numeric or integer, explicit curve index
#' @param site_index numeric, site index value
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param curve curve selector when species is provided: "default", "first", numeric curve index, or curve name
#' @param fiz optional FIZ code used when remapping species codes
#' @return numeric years to breast height
#' @examples
#' si_to_y2bh(1, 30)
#' si_to_y2bh(site_index = 30, species = "SW")
#' @export
si_to_y2bh <- function(cu_index = NULL, site_index, species = NULL, curve = "default", fiz = NULL) {
  cu_index <- resolve_curve_index(cu_index = cu_index, species = species, curve = curve, fiz = fiz)
  sindex_y2bh(as.integer(cu_index), as.numeric(site_index))
}

#' Years to breast height rounded to 0.5
#'
#' Compute years to breast height rounded to 0.5-year steps
#' (0.5, 1.5, 2.5, ...).
#'
#' @param cu_index numeric or integer, explicit curve index
#' @param site_index numeric, site index value
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param curve curve selector when species is provided: "default", "first", numeric curve index, or curve name
#' @param fiz optional FIZ code used when remapping species codes
#' @return numeric years to breast height rounded to 0.5-year steps
#' @examples
#' si_to_y2bh05(1, 30)
#' si_to_y2bh05(site_index = 30, species = "SW")
#' @export
si_to_y2bh05 <- function(cu_index = NULL, site_index, species = NULL, curve = "default", fiz = NULL) {
  cu_index <- resolve_curve_index(cu_index = cu_index, species = species, curve = curve, fiz = fiz)
  si_y2bh05(as.integer(cu_index), as.numeric(site_index))
}

#' Convert between breast height age and total age
#'
#' Converts age from one age type (breast height or total) to another.
#'
#' @param cu_index numeric or integer, explicit curve index
#' @param age1 numeric, initial age value
#' @param age1_type integer, initial age type (1 for breast height, 0 for total)
#' @param age2_type integer, target age type (1 for breast height, 0 for total)
#' @param y2bh numeric, years to breast height (typically estimated automatically)
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param curve curve selector when species is provided: "default", "first", numeric curve index, or curve name
#' @param fiz optional FIZ code used when remapping species codes
#' @return numeric converted age
#' @examples
#' age_to_age(cu_index = 112, age1 = 50, age1_type = 1, age2_type = 0, y2bh = 2)
#' age_to_age(age1 = 50, age1_type = 1, age2_type = 0, species = "SW")
#' @export
age_to_age <- function(cu_index = NULL, age1, age1_type, age2_type, y2bh = NA_real_,
                       species = NULL, curve = "default", fiz = NULL) {
  cu_index <- resolve_curve_index(cu_index = cu_index, species = species, curve = curve, fiz = fiz)

  if (is.na(y2bh)) {
    y2bh <- sindex_y2bh(as.integer(cu_index), site_index = 30.0)
  }

  sindex_age_to_age(as.integer(cu_index), as.numeric(age1), as.integer(age1_type),
                    as.integer(age2_type), as.numeric(y2bh))
}

#' @export
#' @noRd
Age2Age <- function(...) age_to_age(...)

#' @export
#' @noRd
AgeToAge <- function(...) age_to_age(...)
