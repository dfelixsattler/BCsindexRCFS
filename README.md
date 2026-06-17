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

- Added modern wrapper interfaces for core conversions (`ht_age_to_si`, `si_to_ht`,
    `si_ht_to_age`, `si_to_si`, `SC2SI`, `si_to_y2bh`, `si_to_y2bh05`).
- Added modern metadata aliases (`default_curve`, `species_code`,
    `species_name`).
- Added once-per-session legacy warnings for superseded conversion wrappers.
- Added workflow examples with generic data for:
    - Permanent Sample Plot (PSP) productivity estimation.
    - Treelist enrichment for growth-and-yield model inputs.
- Added migration and legacy reference documentation vignettes.

## Installation

### From local tarball (recommended for testing)

The built source package is available at: `C:\SIndexR_build\SIndexRCFS_0.2.0.tar.gz`

In RStudio:
1. **Tools** → **Install Packages**
2. Change to "Package Archive File (.tar.gz)"
3. Browse to the tarball file and click **Install**

Or via command line:
```r
install.packages("C:/SIndexR_build/SIndexRCFS_0.2.0.tar.gz", repos=NULL, type="source")
```

### From local source checkout:

```r
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_local(".", build_vignettes = TRUE)
```

### From GitHub (replace with your repo path):

```r
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("<owner>/SIndexRCFS", build_vignettes = TRUE)
```

### Dependency management

R automatically installs all declared dependencies from DESCRIPTION:
- **Imports** (required): Rcpp, stats, utils, data.table
- **Suggests** (optional): testthat, knitr, rmarkdown

### Development directory structure

- `C:\SIndexR` — Main development repository (current)
- `C:\SIndexR_build` — Built package artifacts (tarballs)
- `C:\SIndexRCFS_old` — Archived early test package (deprecated)

## Quick start

```r
library(SIndexRCFS)

# Height -> Site index
ht_age_to_si(age = 50, age_type = 1, height = 30, species = "SW")

# Site index -> Height
si_to_ht(iage = 50, age_type = 1, site_index = 30, species = "SW")

# Site index -> Age
si_ht_to_age(site_height = 30, age_type = 1, site_index = 30, species = "SW")
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

