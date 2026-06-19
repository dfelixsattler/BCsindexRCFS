# Copyright 2018 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#' @title
#'    Determine species index from species code
#' @description
#'    Determine species index from species code
#' @param sc Character, Defined as species code.
#' @return Species index.
#'    May return an error code under the following conditions:
#'
#'    return value    condition
#'    ------------    ---------
#'    SI_ERR_CODE     if species code is unknown
#'
#' @note
#'    Species code string can be 1, 2, or 3 letters; upper/lower case
#'      is ignored.
#' @noRd
SIndexR_SpecMap <- function(sc)
{
  return(unlist(lapply(sc, function(s) species_map (s))))
}

#' @title
#'    Resolve species index from species code or numeric index
#' @description
#'    Convert a species code string or numeric species index into an integer species index.
#' @param species Integer or character species index or code.
#' @param fiz Character, optional Forest inventory zone code used to disambiguate species codes.
#' @return Integer species index.
#'    May return an error code under the following conditions:
#'    SI_ERR_CODE     if species code is unknown
#'    SI_ERR_FIZ      if FIZ code is unknown
#' @note
#'    Species code string can be 1, 2, or 3 letters; upper/lower case is ignored.
#' @noRd
SIndexR_SpeciesIndex <- function(species, fiz = NULL)
{
  if (is.factor(species)) {
    species <- as.character(species)
  }

  if (is.character(species)) {
    if (is.null(fiz)) {
      return(unlist(lapply(species, function(s) species_map(s))))
    }

    if (length(species) == 1 & length(fiz) != 1) {
      fiz <- rep(fiz, length(species))
    }
    if (length(species) != length(fiz)) {
      stop("species and fiz do not have same length.")
    }

    species_list <- lapply(species, function(s) s)
    fiz_list <- lapply(fiz, function(s) s)
    allinputs <- Map(list, species_list, fiz_list)
    return(unlist(lapply(allinputs, function(s) species_remap(sc = s[[1]],
                                                               fiz = s[[2]]))))
  }

  if (is.numeric(species) || is.integer(species)) {
    return(wholeToInteger(species, "species"))
  }

  stop("species must be an integer index or a species code character string.")
}


#' Resolve species index using FIZ-aware remapping
#'
#' Converts species code(s) to the recommended integer species index using the
#' Forest Inventory Zone (FIZ) to disambiguate codes that map to different species
#' depending on coast vs interior (e.g. `"FD"` → `FDC` on coast, `FDI` in interior).
#'
#' @param species character species code(s) (e.g. `"FD"`, `"Sw"`)
#' @param fiz character FIZ code(s): `A`–`C` for coast, `D`–`L` for interior.
#'   Recycled to the length of `species` if length 1.
#' @return integer vector of remapped species indices
#' @examples
#' species_to_sp_index("FD", "A")   # coastal Douglas-fir
#' species_to_sp_index("FD", "D")   # interior Douglas-fir
#' species_to_sp_index(c("Sw", "Pl"), "H")
#' @export
species_to_sp_index <- function(species, fiz) {
  if (length(species) == 1 && length(fiz) != 1) {
    species <- rep(species, length(fiz))
  }
  if (length(species) != 1 && length(fiz) == 1) {
    fiz <- rep(fiz, length(species))
  }
  if (length(species) != length(fiz)) {
    stop("species and fiz must have the same length, or one must be length 1.")
  }
  inputs <- Map(list, species, fiz)
  unlist(lapply(inputs, function(x) species_remap(sc = x[[1]], fiz = x[[2]])))
}

#' @noRd
SIndexR_SpecRemap <- function(sc, fiz) {
  species_to_sp_index(species = sc, fiz = fiz)
}

