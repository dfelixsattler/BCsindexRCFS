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

#' SIndex library version number
#'
#' Returns the version number of the built-in Sindex routines.
#'
#' The version is an integer in the form `Mmm` where `M` is the major
#' release and `mm` is the minor release (e.g. `631` = version 6.31).
#' If the major release is greater than what your application expects,
#' assume the Sindex routines are not backward compatible.
#'
#' @return integer version number
#' @examples
#' sindex_version()
#' @export
sindex_version <- function() {
  sindex_version_number()
}

#' @noRd
#' @export
SIndexR_VersionNumber <- function() {
  sindex_version()
}
