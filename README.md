# SIndexRCFS

SIndexRCFS is a modernized fork of the original SIndexR package for running
Site index calculations in R, with a focus on practical forestry workflows.

## Project goals

SIndexRCFS keeps compatibility with legacy SIndexR interfaces while adding a
cleaner modern wrapper layer that is easier to use in applied analysis and
data pipelines.

## Acknowledgements

- Yong Luo, original author of the SIndexR R package.
- Ken Polsson, original author/maintainer of the underlying Sindex C code.

## What has changed in this fork

- Added modern wrapper interfaces for core conversions (`HT2SI`, `SI2HT`,
    `SI2AGE`, `SI2SI`, `SC2SI`, `SIY2BH`, `SIY2BH05`).
- Added modern metadata aliases (`DefaultCurve`, `SpeciesCode`,
    `SpeciesName`).
- Added once-per-session legacy warnings for superseded conversion wrappers.
- Added workflow examples with generic data for:
    - Permanent Sample Plot (PSP) productivity estimation.
    - Treelist enrichment for growth-and-yield model inputs.
- Added migration and legacy reference documentation vignettes.

## Installation

Install from a local checkout:

```r
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_local(".", build_vignettes = TRUE)
```

Or install from GitHub (replace with your repo path):

```r
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("<owner>/SIndexRCFS", build_vignettes = TRUE)
```

## Quick start

```r
library(SIndexRCFS)

# Height -> Site index
HT2SI(age = 50, age_type = 1, height = 30, species = "SW")

# Site index -> Height
SI2HT(iage = 50, age_type = 1, site_index = 30, species = "SW")

# Site index -> Age
SI2AGE(site_height = 30, age_type = 1, site_index = 30, species = "SW")
```

## Workflow examples

Run the packaged scripts:

```r
source(system.file("examples", "psp_workflow_example.R", package = "SIndexRCFS"))
source(system.file("examples", "treelist_workflow_example.R", package = "SIndexRCFS"))
```

Open the vignettes:

```r
vignette("workflow-integration", package = "SIndexRCFS")
vignette("legacy-interfaces", package = "SIndexRCFS")
```

## Support and contribution

Please file issues and contributions in this fork repository. See
`CONTRIBUTING.md` and `CODE_OF_CONDUCT.md`.

## License

Apache License 2.0. See `LICENSE`.

