#!/usr/bin/env Rscript
# Verify and regenerate documentation

library(devtools)
setwd("C:/SIndexR")

# Regenerate documentation
cat("Regenerating documentation...\n")
devtools::document(roclets = c("rd", "namespace", "collate"))
cat("Documentation regenerated.\n")

# Install the package
cat("\nInstalling package...\n")
devtools::install_local(force = TRUE, build_vignettes = FALSE)
cat("Installation complete.\n")

# Load and test basic functionality
cat("\nRunning tests...\n")
devtools::test()
cat("\nTests complete.\n")
