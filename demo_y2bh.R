#!/usr/bin/env Rscript
# Demonstrate the three Y2BH function variants

library(SIndexR, lib.loc = 'C:/Rlibs')

cat("=== Y2BH (alias to SIY2BH, short form) ===\n")
result1 <- Y2BH(1, 30)
cat("Y2BH(1, 30) =", result1, "\n")
cat("Type:", typeof(result1), "\n\n")

cat("=== SIY2BH (primary modern wrapper) ===\n")
result2 <- SIY2BH(1, 30)
cat("SIY2BH(1, 30) =", result2, "\n")
cat("Type:", typeof(result2), "\n\n")

cat("=== SIndexR_Y2BH (legacy low-level API) ===\n")
result3 <- SIndexR_Y2BH(1, 30)
cat("SIndexR_Y2BH(1, 30) structure:\n")
str(result3)
cat("output field:", result3[['output']], "\n")
cat("error field:", result3[['error']], "\n")

cat("\n=== Summary ===\n")
cat("Y2BH and SIY2BH are equivalent (Y2BH is an alias)\n")
cat("SIndexR_Y2BH has a different legacy API (returns list with output/error)\n")
