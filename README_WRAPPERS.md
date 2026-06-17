# SIndexRCFS Wrapper Examples

This guide summarizes the modern convenience wrappers in `SIndexRCFS` and
how they fit into common forestry analysis workflows.

## Core wrapper usage

```r
library(SIndexRCFS)

# Height -> Site index
HT2SI(age = 50, age_type = 1, height = 30, species = "SW")

# Site index -> Height
SI2HT(iage = 50, age_type = 1, site_index = 30, species = "SW")

# Site index -> Age
SI2AGE(site_height = 30, age_type = 1, site_index = 30, species = "SW")

# Site index -> Years to breast height
SIY2BH(site_index = 30, species = "SW")

# Site index conversion between species
SI2SI("BA", 20, "HWC")
```

## Metadata helpers

```r
# Available curves and defaults for a species
CurveOptions("SW")
PrintCurveOptions("SW")

# Modern metadata aliases
DefaultCurve("SW")
SpeciesCode("SW")
SpeciesName("SW")
```

## Run packaged examples

```sh
Rscript -e "library(SIndexRCFS); source(system.file('examples','wrappers_example.R', package='SIndexRCFS'))"
Rscript -e "library(SIndexRCFS); source(system.file('examples','psp_workflow_example.R', package='SIndexRCFS'))"
Rscript -e "library(SIndexRCFS); source(system.file('examples','treelist_workflow_example.R', package='SIndexRCFS'))"
```

## Additional documentation

```r
vignette("workflow-integration", package = "SIndexRCFS")
vignette("legacy-interfaces", package = "SIndexRCFS")
```

