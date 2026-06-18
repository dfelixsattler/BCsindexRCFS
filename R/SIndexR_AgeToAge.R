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


#' @export
#' @noRd
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

