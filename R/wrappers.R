## Convenience wrappers for SIndexR core routines

# Resolve a single curve index from explicit curve index or species+curve selector.
resolve_curve_index <- function(cu_index = NULL, species = NULL, curve = "default", fiz = NULL) {
  if (!is.null(cu_index)) {
    return(as.integer(cu_index))
  }

  if (is.null(species)) {
    stop("Provide either cu_index, or species with an optional curve selector.")
  }

  sp_index <- SIndexR_SpeciesIndex(species, fiz = fiz)
  if (length(sp_index) != 1) {
    stop("species must resolve to a single species index for this call.")
  }

  available_curves <- SIndexR_CurveList(sp_index)
  if (length(available_curves) == 0) {
    stop("No curves are available for the provided species.")
  }

  if (is.numeric(curve) || is.integer(curve)) {
    curve <- as.integer(curve)
    if (!curve %in% available_curves) {
      stop("The requested curve index is not valid for this species.")
    }
    return(curve)
  }

  if (!is.character(curve) || length(curve) != 1) {
    stop("curve must be a single character selector or numeric curve index.")
  }

  curve_key <- tolower(curve)
  if (curve_key %in% c("default", "def")) {
    return(as.integer(Sindex_DefCurve(sp_index)))
  }
  if (curve_key == "first") {
    return(as.integer(available_curves[[1]]))
  }

  curve_names <- vapply(available_curves, function(x) Sindex_CurveName(as.integer(x)), character(1))
  curve_names_lc <- tolower(curve_names)

  exact_match <- which(curve_names_lc == curve_key)
  if (length(exact_match) == 1) {
    return(as.integer(available_curves[[exact_match]]))
  }

  partial_match <- grep(curve_key, curve_names_lc, fixed = TRUE)
  if (length(partial_match) == 1) {
    return(as.integer(available_curves[[partial_match]]))
  }
  if (length(partial_match) > 1) {
    stop("curve selector is ambiguous; use a full curve name or numeric curve index.")
  }

  stop("curve selector did not match any available curve for this species.")
}

#' List available curves for a species
#'
#' Returns available curve indices and names for a species, and marks the default curve.
#'
#' @param species integer or character species index/code
#' @param fiz optional FIZ code when remapping species codes
#' @return data.frame (single species) or named list of data.frames (multiple species)
#' @examples
#' CurveOptions("SW")
#' @export
CurveOptions <- function(species, fiz = NULL) {
  sp_index <- SIndexR_SpeciesIndex(species, fiz = fiz)

  out <- lapply(sp_index, function(sp) {
    curves <- SIndexR_CurveList(sp)
    if (length(curves) == 0) {
      return(data.frame(
        curve_index = integer(0),
        curve_name = character(0),
        is_default = logical(0),
        stringsAsFactors = FALSE
      ))
    }

    def_curve <- as.integer(Sindex_DefCurve(as.integer(sp)))
    curve_names <- vapply(curves, function(x) Sindex_CurveName(as.integer(x)), character(1))

    data.frame(
      curve_index = as.integer(curves),
      curve_name = curve_names,
      is_default = as.integer(curves) == def_curve,
      stringsAsFactors = FALSE
    )
  })

  if (length(out) == 1) {
    return(out[[1]])
  }

  names(out) <- as.character(sp_index)
  out
}

#' Print a compact curve menu for a species
#'
#' Prints available curves in a concise table and marks the default curve with `*`.
#'
#' @param species integer or character species index/code
#' @param fiz optional FIZ code when remapping species codes
#' @return invisibly returns the same value as `CurveOptions()`
#' @examples
#' PrintCurveOptions("SW")
#' @export
PrintCurveOptions <- function(species, fiz = NULL) {
  opts <- CurveOptions(species, fiz = fiz)

  print_one <- function(df, label) {
    cat("Species", label, "\n")
    if (nrow(df) == 0) {
      cat("  (no curves available)\n")
      return(invisible(NULL))
    }

    markers <- ifelse(df$is_default, "*", " ")
    for (i in seq_len(nrow(df))) {
      cat(sprintf("%s %3d  %s\n", markers[i], df$curve_index[i], df$curve_name[i]))
    }
    cat("\n")
    invisible(NULL)
  }

  if (is.data.frame(opts)) {
    sp_idx <- SIndexR_SpeciesIndex(species, fiz = fiz)
    print_one(opts, sp_idx[1])
    return(invisible(opts))
  }

  for (nm in names(opts)) {
    print_one(opts[[nm]], nm)
  }
  invisible(opts)
}

#' Get default curve index for species
#'
#' Modern alias for `SIndexR_DefCurve()` that accepts species codes
#' and optional FIZ remapping.
#'
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param fiz optional FIZ code used when remapping species codes
#' @return integer default curve index (vectorized)
#' @examples
#' DefaultCurve("SW")
#' DefaultCurve(c("SW", "FDI"))
#' @export
DefaultCurve <- function(species, fiz = NULL) {
  sp_index <- SIndexR_SpeciesIndex(species, fiz = fiz)
  SIndexR_DefCurve(sp_index)
}

#' Get canonical species code
#'
#' Modern alias for `SIndexR_SpecCode()` that accepts species codes
#' or species indices and returns canonical species codes.
#'
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param fiz optional FIZ code used when remapping species codes
#' @return character canonical species code (vectorized)
#' @examples
#' SpeciesCode("SW")
#' SpeciesCode(c(11, 48))
#' @export
SpeciesCode <- function(species, fiz = NULL) {
  sp_index <- SIndexR_SpeciesIndex(species, fiz = fiz)
  SIndexR_SpecCode(sp_index)
}

#' Get species full name
#'
#' Modern alias for `SIndexR_SpecName()` that accepts species codes
#' or species indices and returns full species names.
#'
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param fiz optional FIZ code used when remapping species codes
#' @return character full species name (vectorized)
#' @examples
#' SpeciesName("SW")
#' SpeciesName(c(11, 48))
#' @export
SpeciesName <- function(species, fiz = NULL) {
  sp_index <- SIndexR_SpeciesIndex(species, fiz = fiz)
  SIndexR_SpecName(sp_index)
}

# Height -> Site Index
#' Convert height to site index
#'
#' A thin wrapper around the internal `height_to_index` routine.
#'
#' @param cu_index numeric or integer, explicit curve index
#' @param age numeric, age of the tree
#' @param age_type integer, one of the `SI_AT_*` constants (default: `SI_AT_BREAST`)
#' @param height numeric, tree height
#' @param si_est_type integer, estimation type (default: `SI_EST_ITERATE`)
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param curve curve selector when species is provided: "default", "first", numeric curve index, or curve name
#' @param fiz optional FIZ code used when remapping species codes
#' @return numeric site index
#' @examples
#' HT2SI(1, 50, 1, 30, 0)
#' HT2SI(age = 50, height = 30, species = "SW")
#' @export
HT2SI <- function(cu_index = NULL, age, age_type = 1, height, si_est_type = 0,
                  species = NULL, curve = "default", fiz = NULL) {
  cu_index <- resolve_curve_index(cu_index = cu_index, species = species, curve = curve, fiz = fiz)
  sindex_height_to_index(as.integer(cu_index), as.numeric(age), as.integer(age_type), as.numeric(height), as.integer(si_est_type))
}

#' Convert site index to height
#'
#' Wrapper around `index_to_height`. If `y2bh` is not provided it will be
#' estimated via `si_y2bh`.
#'
#' @param cu_index numeric or integer, explicit curve index
#' @param iage numeric, age to convert
#' @param age_type integer, one of the `SI_AT_*` constants
#' @param site_index numeric, site index value
#' @param y2bh numeric, years to breast height (optional)
#' @param pi numeric, projection index (default: 0.5)
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param curve curve selector when species is provided: "default", "first", numeric curve index, or curve name
#' @param fiz optional FIZ code used when remapping species codes
#' @return numeric height
#' @examples
#' SI2HT(1, 50, 1, 30)
#' SI2HT(iage = 50, site_index = 30, species = "SW")
#' @export
SI2HT <- function(cu_index = NULL, iage, age_type = 1, site_index, y2bh = NA_real_, pi = 0.5,
                  species = NULL, curve = "default", fiz = NULL) {
  cu_index <- resolve_curve_index(cu_index = cu_index, species = species, curve = curve, fiz = fiz)
  if (is.na(y2bh)) y2bh <- sindex_y2bh(as.integer(cu_index), as.numeric(site_index))
  sindex_index_to_height(as.integer(cu_index), as.numeric(iage), as.integer(age_type), as.numeric(site_index), as.numeric(y2bh), as.numeric(pi))
}

#' Convert site index to age
#'
#' Wrapper around `index_to_age`. If `y2bh` is not provided it will be
#' estimated via `si_y2bh`.
#'
#' @param cu_index numeric or integer, explicit curve index
#' @param site_height numeric, height at which to compute age
#' @param age_type integer, one of the `SI_AT_*` constants
#' @param site_index numeric, site index value
#' @param y2bh numeric, years to breast height (optional)
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param curve curve selector when species is provided: "default", "first", numeric curve index, or curve name
#' @param fiz optional FIZ code used when remapping species codes
#' @return numeric age
#' @examples
#' SI2AGE(1, 30, 1, 30)
#' SI2AGE(site_height = 30, site_index = 30, species = "SW")
#' @export
SI2AGE <- function(cu_index = NULL, site_height, age_type = 1, site_index, y2bh = NA_real_,
                   species = NULL, curve = "default", fiz = NULL) {
  cu_index <- resolve_curve_index(cu_index = cu_index, species = species, curve = curve, fiz = fiz)
  if (is.na(y2bh)) y2bh <- sindex_y2bh(as.integer(cu_index), as.numeric(site_index))
  sindex_index_to_age(as.integer(cu_index), as.numeric(site_height), as.integer(age_type), as.numeric(site_index), as.numeric(y2bh))
}

#' Years to breast height (y2bh)
#'
#' Compute the years-to-breast-height value from the species/curve index and site index.
#'
#' @param cu_index numeric or integer, explicit curve index
#' @param site_index numeric, site index value
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param curve curve selector when species is provided: "default", "first", numeric curve index, or curve name
#' @param fiz optional FIZ code used when remapping species codes
#' @param ... additional arguments passed through compatibility aliases
#' @return numeric years to breast height
#' @examples
#' SIY2BH(1, 30)
#' SIY2BH(site_index = 30, species = "SW")
#' @export
SIY2BH <- function(cu_index = NULL, site_index, species = NULL, curve = "default", fiz = NULL) {
  cu_index <- resolve_curve_index(cu_index = cu_index, species = species, curve = curve, fiz = fiz)
  sindex_y2bh(as.integer(cu_index), as.numeric(site_index))
}

#' @rdname SIY2BH
#' @export
Y2BH <- function(...) SIY2BH(...)

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
#' @param ... additional arguments passed through compatibility aliases
#' @return numeric years to breast height rounded to 0.5-year steps
#' @examples
#' SIY2BH05(1, 30)
#' SIY2BH05(site_index = 30, species = "SW")
#' @export
SIY2BH05 <- function(cu_index = NULL, site_index, species = NULL, curve = "default", fiz = NULL) {
  cu_index <- resolve_curve_index(cu_index = cu_index, species = species, curve = curve, fiz = fiz)
  si_y2bh05(as.integer(cu_index), as.numeric(site_index))
}

#' @rdname SIY2BH05
#' @export
Y2BH05 <- function(...) SIY2BH05(...)

#' Convert age between type-at-breast and type-at-total
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
#' @param ... additional arguments passed through compatibility aliases
#' @return numeric converted age
#' @examples
#' Age2Age(cu_index = 112, age1 = 50, age1_type = 1, age2_type = 0, y2bh = 2)
#' Age2Age(age1 = 50, age1_type = 1, age2_type = 0, species = "SW")
#' @export
Age2Age <- function(cu_index = NULL, age1, age1_type, age2_type, y2bh = NA_real_,
                    species = NULL, curve = "default", fiz = NULL) {
  cu_index <- resolve_curve_index(cu_index = cu_index, species = species, curve = curve, fiz = fiz)

  if (is.na(y2bh)) {
    y2bh <- sindex_y2bh(as.integer(cu_index), site_index = 30.0)
  }

  sindex_age_to_age(as.integer(cu_index), as.numeric(age1), as.integer(age1_type),
                    as.integer(age2_type), as.numeric(y2bh))
}

#' @rdname Age2Age
#' @export
AgeToAge <- function(...) Age2Age(...)

#' Convert site class to site index
#'
#' Translates site class code (G/M/P/L) to estimated site index (height in metres).
#' Used where total age is small (under 30 years), where site index based on height may not be reliable.
#'
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param site_class character, one of "G" (good), "M" (medium), "P" (poor), "L" (low)
#' @param fiz optional FIZ code (character: A-C for coast, D-L for interior)
#' @param ... additional arguments passed through compatibility aliases
#' @return numeric site index (height in metres)
#' @examples
#' SC2SI("FDI", "M")
#' SC2SI(11, "P", "H")
#' @export
SC2SI <- function(species, site_class, fiz = NULL) {
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

#' @rdname SC2SI
#' @export
SiteClassToIndex <- function(...) SC2SI(...)

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
#' SI2SI("BA", 20, "HWC")
#' SI2SI(11, 20, 48)
#' @export
SI2SI <- function(source_species, site_index, target_species, source_fiz = NULL, target_fiz = NULL) {
  sp_index1 <- SIndexR_SpeciesIndex(source_species, fiz = source_fiz)
  sp_index2 <- SIndexR_SpeciesIndex(target_species, fiz = target_fiz)

  if (length(sp_index1) != 1 || length(sp_index2) != 1) {
    stop("source_species and target_species must each resolve to a single species index.")
  }

  Sindex_SITOSI(as.integer(sp_index1), as.numeric(site_index), as.integer(sp_index2))
}
