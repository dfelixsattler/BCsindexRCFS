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

#' Species geographic location in BC
#'
#' Returns a data frame indicating where a species generally occurs in British
#' Columbia and whether it is considered common, decoded from the underlying
#' \code{Sindex_SpecUse()} bit-field.
#'
#' The underlying C function uses a bit-field (bit 1 = coast, bit 2 = interior,
#' bit 4 = common). This wrapper decodes those bits into readable logical columns.
#'
#' @param species integer/numeric species index or species code (e.g. "SW", "FDC")
#' @param fiz optional FIZ code used when remapping species codes
#' @return A data frame with columns \code{species}, \code{coast},
#'   \code{interior}, and \code{common}
#' @examples
#' species_location("FDC")            # coastal Douglas-fir
#' species_location("SW")             # interior spruce
#' species_location(c("FDC", "SW"))
#' @export
species_location <- function(species, fiz = NULL) {
  sp_index <- SIndexR_SpeciesIndex(species, fiz = fiz)
  sp_index <- wholeToInteger(sp_index, "species")
  raw <- unlist(lapply(sp_index, function(s) Sindex_SpecUse(s)))

  result <- data.frame(
    species  = if (is.character(species)) species else as.character(sp_index),
    coast    = bitwAnd(raw, 1L) != 0L,
    interior = bitwAnd(raw, 2L) != 0L,
    common   = bitwAnd(raw, 4L) != 0L,
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  result
}

#' @noRd
SIndexR_SpecUse <- function(sp_index) {
  sp_index <- wholeToInteger(sp_index, "sp_index")
  unlist(lapply(sp_index, function(s) Sindex_SpecUse(s)))
}
