# SIndexR Wrapper Examples

This document provides quick examples for the convenience wrapper functions added to `SIndexR`.

For legacy-to-modern mappings and a modernization matrix for still-active interfaces, see
`vignette("legacy-interfaces")`.

Usage (in R):

```r
library(SIndexR)

# Convert height to site index
HT2SI(1, 50, 1, 30, 0)

# Convert site index to height
SI2HT(1, 50, 1, 30)

# Convert site index to age
SI2AGE(1, 30, 1, 30)

# Compute breast-height age from site index and y
SIY2BH(1, 30)
```

Run the example scripts included in the package:

```sh
Rscript -e "library(SIndexR); source(system.file('examples','wrappers_example.R', package='SIndexR'))"
Rscript -e "library(SIndexR); source(system.file('examples','psp_workflow_example.R', package='SIndexR'))"
Rscript -e "library(SIndexR); source(system.file('examples','treelist_workflow_example.R', package='SIndexR'))"
```

For full narrative workflow examples, see:

```r
vignette("workflow-integration", package = "SIndexR")
```
