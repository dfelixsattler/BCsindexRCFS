# Bore age conversion
# Modern public API: bore_age_to_ages()
# cap_y2bh replaces the legacy psp_cap name; the cap is recommended for all data.

#' Convert bored age to breast height age and total age
#'
#' Corrects a bore core age reading---which may be taken at any stem height,
#' not necessarily breast height (1.3 m)---and returns the corrected breast
#' height (BH) age, total age, site index, and years to breast height.
#'
#' An iterative correction is applied when the bore was taken at a height other
#' than 1.3 m. The correction formula on each iteration is:
#'
#' \deqn{BH\_age = bore\_age - y2bh \times \frac{1.3 - bore\_height}{1.3}}
#'
#' The formula handles both cases naturally: when the bore is above 1.3 m the
#' sign reverses and BH age is larger than bore age; when below 1.3 m the BH
#' age is smaller. Iteration continues until successive BH age estimates agree
#' to the nearest whole year, or until 10 iterations have been completed.
#'
#' Site index and years-to-breast-height are estimated internally on each
#' iteration using \code{\link{ht_age_to_si}} and \code{\link{si_to_y2bh}}.
#' Total age is returned as \code{bh_age + y2bh}.
#'
#' @param bore_age numeric, age at bore height (must be positive).
#' @param bore_height numeric, height of the bore core in metres (must be
#'   positive).
#' @param tree_height numeric, total tree height in metres (must be positive).
#' @param species character, species code (e.g. \code{"SW"}, \code{"FDC"},
#'   \code{"HW"}).
#' @param fiz character (optional), FIZ or IC region code used to disambiguate
#'   coastal/interior species (e.g. \code{"I"} for interior, \code{"C"} for
#'   coastal). Passed to \code{\link{ht_age_to_si}} and
#'   \code{\link{si_to_y2bh}}.
#' @param si_est_type integer, SI estimation type passed to
#'   \code{\link{ht_age_to_si}}: \code{0L} = direct (default),
#'   \code{1L} = iterative.
#' @param cap_y2bh logical. When \code{TRUE} (the default), caps \code{y2bh}
#'   at \code{min(bore_age, 25)} after convergence if \code{y2bh} exceeds
#'   either value. This prevents biologically implausible corrections that can
#'   arise when a low site index produces an inflated years-to-breast-height
#'   estimate---a problem that can occur in any data source regardless of
#'   compilation type. The cap originates from the BC PSP compilation
#'   specification but is recommended for general use. Set to \code{FALSE}
#'   only when you specifically want uncapped behaviour for sensitivity
#'   analysis or to match a non-standard pipeline.
#' @param curve curve selector passed through to \code{\link{ht_age_to_si}}:
#'   \code{"default"} (the default), \code{"first"}, or a numeric curve index.
#'
#' @return A \code{data.frame} with one row per input observation and columns:
#'   \describe{
#'     \item{bh_age}{corrected breast height age (years)}
#'     \item{total_age}{total age in years (\code{bh_age + y2bh})}
#'     \item{site_index}{site index (m) estimated during the correction}
#'     \item{y2bh}{years to breast height}
#'   }
#'   Rows with any \code{NA} input are returned as all-\code{NA}.
#'
#' @seealso \code{\link{ht_age_to_si}}, \code{\link{si_to_y2bh}},
#'   \code{\link{age_to_age}}
#'
#' @examples
#' # Bore taken above breast height
#' bore_age_to_ages(bore_age = 55, bore_height = 2.5,
#'                  tree_height = 32, species = "SW")
#'
#' # Bore taken at breast height — no iterative correction needed
#' bore_age_to_ages(bore_age = 55, bore_height = 1.3,
#'                  tree_height = 32, species = "SW")
#'
#' # Bore taken below breast height
#' bore_age_to_ages(bore_age = 60, bore_height = 0.5,
#'                  tree_height = 30, species = "HW", fiz = "C")
#'
#' # Vectorised: multiple trees, mixed species / regions
#' bore_age_to_ages(
#'   bore_age    = c(45, 60, 52),
#'   bore_height = c(1.3, 2.5, 0.5),
#'   tree_height = c(28, 35, 30),
#'   species     = c("SW", "FDC", "HW"),
#'   fiz         = c("I", "C", "C")
#' )
#' @export
bore_age_to_ages <- function(bore_age, bore_height, tree_height, species,
                              fiz = NULL, si_est_type = 0L, cap_y2bh = TRUE,
                              curve = "default") {

  n <- max(length(bore_age), length(bore_height),
           length(tree_height), length(species))

  # --- input validation ---
  if (!is.numeric(bore_age)    || any(bore_age[!is.na(bore_age)]       <= 0))
    stop("bore_age must be a positive numeric vector.")
  if (!is.numeric(bore_height) || any(bore_height[!is.na(bore_height)] <= 0))
    stop("bore_height must be a positive numeric vector.")
  if (!is.numeric(tree_height) || any(tree_height[!is.na(tree_height)] <= 0))
    stop("tree_height must be a positive numeric vector.")

  # --- recycle scalars to length n ---
  bore_age    <- rep_len(as.numeric(bore_age),    n)
  bore_height <- rep_len(as.numeric(bore_height), n)
  tree_height <- rep_len(as.numeric(tree_height), n)
  species     <- rep_len(as.character(species),   n)
  fiz_list    <- if (is.null(fiz)) rep(list(NULL), n) else
                   as.list(rep_len(as.character(fiz), n))

  # resolve one curve index per observation
  cu_vec <- mapply(
    function(sp, fz) resolve_curve_index(species = sp, fiz = fz, curve = curve),
    species, fiz_list,
    SIMPLIFY = TRUE
  )

  # --- output containers ---
  bh_age_out    <- rep(NA_real_, n)
  total_age_out <- rep(NA_real_, n)
  si_out        <- rep(NA_real_, n)
  y2bh_out      <- rep(NA_real_, n)

  for (i in seq_len(n)) {
    ba  <- bore_age[i]
    bh  <- bore_height[i]
    th  <- tree_height[i]
    cu  <- cu_vec[i]

    if (anyNA(c(ba, bh, th, cu))) next

    # --- bore exactly at breast height: no correction needed ---
    if (bh == 1.3) {
      si   <- ht_age_to_si(cu_index = cu, age = ba, age_type = 1L,
                            height = th, si_est_type = si_est_type)
      y2bh <- si_to_y2bh(cu_index = cu, site_index = si)
      bh_age_out[i]    <- ba
      total_age_out[i] <- ba + y2bh
      si_out[i]        <- si
      y2bh_out[i]      <- y2bh
      next
    }

    # --- iterative correction (bore above OR below 1.3 m) ---
    first_bha  <- ba
    second_bha <- ba
    si_i       <- NA_real_
    y2bh_i     <- NA_real_

    for (iter in seq_len(10)) {
      first_bha <- second_bha
      si_i   <- ht_age_to_si(cu_index = cu, age = first_bha, age_type = 1L,
                              height = th, si_est_type = si_est_type)
      y2bh_i <- si_to_y2bh(cu_index = cu, site_index = si_i)
      second_bha <- ba - y2bh_i * (1.3 - bh) / 1.3
      if (iter >= 2 && round(first_bha) == round(second_bha)) break
    }

    # --- y2bh cap: applied after convergence ---
    if (cap_y2bh && (y2bh_i > ba || y2bh_i > 25)) {
      y2bh_i     <- min(ba, 25)
      second_bha <- ba - y2bh_i * (1.3 - bh) / 1.3
    }

    # --- guard against degenerate result ---
    if (second_bha <= 0.1) {
      warning(sprintf(
        "Observation %d: derived BH age (%.2f) <= 0.1; bore age used as BH age.",
        i, second_bha
      ))
      second_bha <- ba
      si_i   <- ht_age_to_si(cu_index = cu, age = ba, age_type = 1L,
                              height = th, si_est_type = si_est_type)
      y2bh_i <- si_to_y2bh(cu_index = cu, site_index = si_i)
    }

    bh_age_out[i]    <- second_bha
    total_age_out[i] <- second_bha + y2bh_i
    si_out[i]        <- si_i
    y2bh_out[i]      <- y2bh_i
  }

  data.frame(
    bh_age     = bh_age_out,
    total_age  = total_age_out,
    site_index = si_out,
    y2bh       = y2bh_out,
    stringsAsFactors = FALSE
  )
}
