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
#' Curve notes
#' @description
#'    Returns string containing notes on use. Can be called with either 
#'    a curve index directly, or with a species code to get notes for 
#'    the default curve of that species.
#' @param cu_index Integer/Numeric, Curve index (optional if species is provided).
#' @param species integer/numeric species index or species code (e.g. "SW", "FDI") - optional
#' @param curve curve selector when species is provided: "default", "first", numeric curve index, or curve name
#' @param fiz optional FIZ code used when remapping species codes
#' @return A string containing notes on use of curve.
#'    If input parameters do not resolve to a valid curve, the return is the
#'    null pointer.
#' @examples
#' SIndexR_CurveNotes(1)
#' SIndexR_CurveNotes(species = "SW")
#' @noRd
#' @export
SIndexR_CurveNotes <- function(cu_index = NULL, species = NULL, curve = "default", fiz = NULL){
  # If cu_index is provided, use it directly
  if (!is.null(cu_index)) {
    cu_index <- wholeToInteger(cu_index, "cu_index")
    return(unlist(lapply(cu_index, function(s) Sindex_CurveNotes(s))))
  }
  
  # If species is provided, resolve to curve index
  if (!is.null(species)) {
    sp_index <- SIndexR_SpeciesIndex(species, fiz = fiz)
    if (length(sp_index) != 1) {
      stop("species must resolve to a single species index.")
    }
    available_curves <- SIndexR_CurveList(sp_index)
    if (length(available_curves) == 0) {
      stop("No curves available for the provided species.")
    }
    if (tolower(curve) %in% c("default", "def")) {
      cu_index <- as.integer(Sindex_DefCurve(sp_index))
    } else if (curve == "first") {
      cu_index <- as.integer(available_curves[[1]])
    } else if (is.numeric(curve)) {
      cu_index <- as.integer(curve)
    } else {
      stop("curve selector must be 'default', 'first', or a numeric curve index.")
    }
    return(Sindex_CurveNotes(cu_index))
  }
  
  stop("Provide either cu_index or species.")
}
