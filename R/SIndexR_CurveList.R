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
#' List site index curves for a species
#' @description
#' Returns the defined site index curves for a given species index.
#' @param sp_index Integer/Numeric or character, species index or species code.
#' @return
#' If `sp_index` has length 1, an integer vector of curve indices.
#' If `sp_index` contains multiple species, a named list of integer vectors.
#' @examples
#' sp <- SIndexR_FirstSpecies()
#' SIndexR_CurveList(sp)
#' SIndexR_CurveList("Sw")
#' @export
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
