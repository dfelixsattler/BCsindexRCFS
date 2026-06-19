# BCsindexRCFS Wrapper Examples

This guide summarizes the modern convenience wrappers in `BCsindexRCFS` and
how they fit into common forestry analysis workflows.

## Core wrapper usage

```r
library(BCsindexRCFS)

# Height + age -> Site index
ht_age_to_si(age = 50, age_type = 1, height = 30, species = "SW")

# Site index -> Height
si_to_ht(age = 50, age_type = 1, site_index = 30, species = "SW")

# Site index + height -> Age
si_ht_to_age(site_height = 30, age_type = 1, site_index = 30, species = "SW")

# Site index -> Years to breast height
si_to_y2bh(site_index = 30, species = "SW")

# Site index conversion between species
si_to_si("BA", 20, "HWC")
```

## Metadata helpers

```r
# Available curves and defaults for a species
curve_options("SW")

# Modern metadata aliases
default_curve("SW")
species_code("SW")
species_name("SW")
```

## Run packaged examples

```sh
Rscript -e "library(BCsindexRCFS); source(system.file('examples','wrappers_example.R', package='BCsindexRCFS'))"
Rscript -e "library(BCsindexRCFS); source(system.file('examples','psp_workflow_example.R', package='BCsindexRCFS'))"
Rscript -e "library(BCsindexRCFS); source(system.file('examples','treelist_workflow_example.R', package='BCsindexRCFS'))"
```

## Additional documentation

```r
vignette("workflow-integration", package = "BCsindexRCFS")
vignette("legacy-interfaces", package = "BCsindexRCFS")
```

