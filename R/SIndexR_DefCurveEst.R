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

#' @noRd
SIndexR_DefCurveEst <- function(sp_index, estab) {
  default_curve_estab(species = sp_index, estab = estab)
}
