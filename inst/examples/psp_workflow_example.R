library(SIndexRCFS)

# Example: Permanent Sample Plot (PSP) workflow.
# Goal: estimate site index and years-to-breast-height from observed dominant age/height.
psp_path <- system.file("examples", "psp_sample.csv", package = "SIndexRCFS")
psp <- read.csv(psp_path, stringsAsFactors = FALSE)

psp$site_index_m <- mapply(
  function(sp, age, age_type, h, est_type) {
    HT2SI(age = age, age_type = age_type, height = h, si_est_type = est_type, species = sp)
  },
  psp$species, psp$bh_age, psp$age_type, psp$dom_height_m, psp$si_est_type
)

psp$y2bh_years <- mapply(
  function(sp, si) SIY2BH(site_index = si, species = sp),
  psp$species, psp$site_index_m
)

cat("PSP-level estimates:\n")
print(psp)

cat("\nPlot summaries (mean SI and y2bh):\n")
plot_summary <- aggregate(
  psp[, c("site_index_m", "y2bh_years")],
  by = list(plot_id = psp$plot_id),
  FUN = mean
)
print(plot_summary)

