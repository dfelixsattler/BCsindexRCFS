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


#' Legacy alias for age_to_age
#'
#' `SIndexR_AgeToAge()` is kept for backward compatibility.
#' Prefer using `age_to_age()` for new code.
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
#' @rdname age_to_age
#' @export
SIndexR_AgeToAge <- function(cu_index = NULL, age1, age1_type, age2_type, y2bh = NA_real_,
                                           species = NULL, curve = "default", fiz = NULL) {
   age_to_age(
      cu_index = cu_index,
      age1 = age1,
      age1_type = age1_type,
      age2_type = age2_type,
      y2bh = y2bh,
      species = species,
      curve = curve,
      fiz = fiz
   )
}

