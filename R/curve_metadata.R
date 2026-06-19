# Curve metadata
# Modern public API: curve_options(), curve_notes(), curve_source(),
#                    default_curve_estab(), default_gi_curve()
# Internal helpers:  SIndexR_CurveList(), DefaultCurve()

#' List site index curves for a species
#'
#' Returns the defined site index curves for a given species index.
#' This is an internal helper used by \code{curve_options()} and
#' \code{resolve_curve_index()}. Most user code should prefer
#' \code{curve_options()} for a tabular view.
#'
#' @param sp_index Integer/Numeric or character, species index or species code.
#' @return
#' If `sp_index` has length 1, an integer vector of curve indices.
#' If `sp_index` contains multiple species, a named list of integer vectors.
#' @noRd
SIndexR_CurveList <- function(sp_index) {
  sp_index <- SIndexR_SpeciesIndex(sp_index)
  result <- lapply(sp_index, function(s) {
    first_curve <- SIndexR_FirstCurve(s)
    if (length(first_curve) != 1 || first_curve <= 0) {
      return(integer(0))
    }

    curves <- first_curve
    repeat {
      next_curve <- SIndexR_NextCurve(s, curves[length(curves)])
      if (length(next_curve) != 1 || next_curve <= 0) break
      curves <- c(curves, next_curve)
    }
    curves
  })

  if (length(result) == 1) {
    return(result[[1]])
  }

  names(result) <- as.character(sp_index)
  result
}

#' List available curves for a species
#'
#' Returns available curve indices and names for a species, and marks the default curve.
#'
#' @param species integer or character species index/code
#' @param fiz optional FIZ code when remapping species codes
#' @return data.frame (single species) or named list of data.frames (multiple species)
#' @examples
#' curve_options("SW")
#' @export
curve_options <- function(species, fiz = NULL) {
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
      species_index = as.integer(sp),
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

#' @export
#' @noRd
CurveOptions <- function(species, fiz = NULL) {
  sindex_warn_legacy_once("CurveOptions", "curve_options")
  curve_options(species = species, fiz = fiz)
}

# Internal: get default curve index, accepts species codes.
# Not exported; use curve_options() instead.
#' @noRd
DefaultCurve <- function(species, fiz = NULL) {
  sp_index <- SIndexR_SpeciesIndex(species, fiz = fiz)
  Sindex_DefCurve(sp_index)
}

#' Curve notes
#'
#' Returns notes describing usage constraints or guidance for a site index curve.
#' You can provide a curve index directly, or provide a species and let SIndexR
#' resolve the curve using the `curve` selector.
#'
#' @param cu_index integer/numeric curve index. Optional when `species` is provided.
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param curve curve selector when `species` is provided: "default", "first", or numeric curve index
#' @param fiz optional FIZ code used when remapping species codes
#' @return character vector of curve notes
#' @examples
#' curve_notes(cu_index = 112)
#' curve_notes(species = "SW")
#' curve_notes(species = "FDC", curve = "first")
#' @export
curve_notes <- function(cu_index = NULL, species = NULL, curve = "default", fiz = NULL) {
  if (!is.null(species)) {
    cu_index <- resolve_curve_index(cu_index = cu_index, species = species, curve = curve, fiz = fiz)
  }
  if (is.null(cu_index)) stop("Provide either cu_index or species.")
  cu_index <- wholeToInteger(cu_index, "cu_index")
  unlist(lapply(cu_index, function(s) Sindex_CurveNotes(s)))
}

#' Curve source citation
#'
#' Returns the bibliographic reference (author, year, journal or report) for the
#' research paper that a site index curve is based on. Use this to look up the
#' original publication and its equations.
#' You can provide a curve index directly, or provide a species and let SIndexR
#' resolve the curve using the `curve` selector.
#'
#' @param cu_index integer/numeric curve index. Optional when `species` is provided.
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI")
#' @param curve curve selector when `species` is provided: "default", "first", or numeric curve index
#' @param fiz optional FIZ code used when remapping species codes
#' @return character string containing the full bibliographic citation
#' @examples
#' curve_source(cu_index = 112)
#' curve_source(species = "SW")
#' curve_source(species = "FDC", curve = "first")
#' @export
curve_source <- function(cu_index = NULL, species = NULL, curve = "default", fiz = NULL) {
  if (!is.null(species)) {
    cu_index <- resolve_curve_index(cu_index = cu_index, species = species, curve = curve, fiz = fiz)
  }
  if (is.null(cu_index)) stop("Provide either cu_index or species.")
  Sindex_CurveSource(as.integer(cu_index))
}

#' Default curve index by establishment type
#'
#' Returns the default curve index for each species and establishment type pair.
#' This is a specialized lookup used when default-curve selection differs by
#' regeneration/establishment class.
#'
#' @param species integer/numeric species index or species code (e.g. "FDC", "SW")
#' @param estab integer establishment type code
#' @return integer vector of default curve indices (or SIndex error codes)
#' @examples
#' default_curve_estab(species = "FDC", estab = 1)
#' default_curve_estab(species = c("FDC", "SW"), estab = 1)
#' @export
default_curve_estab <- function(species, estab) {
  sp_index <- SIndexR_SpeciesIndex(species)
  sp_index <- wholeToInteger(sp_index, "species")
  estab <- wholeToInteger(estab, "estab")

  if (length(sp_index) == 1 && length(estab) != 1) {
    sp_index <- rep(sp_index, length(estab))
  }
  if (length(sp_index) != 1 && length(estab) == 1) {
    estab <- rep(estab, length(sp_index))
  }
  if (length(sp_index) != length(estab)) {
    stop("species and estab must have the same length, or one must be length 1.")
  }

  inputs <- Map(list, sp_index, estab)
  unlist(lapply(inputs, function(x) {
    Sindex_DefCurveEst(sp_index = x[[1]], estab = x[[2]])
  }))
}

#' Default growth-intercept curve index
#'
#' Returns the default growth-intercept (GI) curve index for each species.
#' This helper is used when workflows require GI-specific curve selection.
#'
#' @param species integer/numeric species index or species code (e.g. "FDC", "SW")
#' @return integer vector of GI default curve indices (or SIndex error codes)
#' @examples
#' default_gi_curve("FDC")
#' default_gi_curve(c("FDC", "SW"))
#' @export
default_gi_curve <- function(species) {
  sp_index <- SIndexR_SpeciesIndex(species)
  sp_index <- wholeToInteger(sp_index, "species")
  unlist(lapply(sp_index, function(s) Sindex_DefGICurve(s)))
}
