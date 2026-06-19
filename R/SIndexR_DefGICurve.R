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

#' @noRd
SIndexR_DefGICurve <- function(sp_index) {
  default_gi_curve(species = sp_index)
}
