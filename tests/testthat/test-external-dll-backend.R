context("External DLL backend")

get_external_dll_path <- function() {
  p <- Sys.getenv("SINDEX_EXTERNAL_DLL", unset = "C:/sindex64.dll")
  if (!nzchar(p) || !file.exists(p)) {
    return(NA_character_)
  }
  normalizePath(p, winslash = "/", mustWork = TRUE)
}

test_that("external DLL lifecycle works", {
  skip_if(.Platform$OS.type != "windows", "External DLL backend is Windows-only")

  dll_path <- get_external_dll_path()
  skip_if(is.na(dll_path), "Set SINDEX_EXTERNAL_DLL or place DLL at C:/sindex64.dll")

  info0 <- SIndexR_ExternalDllInfo()
  expect_false(isTRUE(info0$loaded))

  expect_true(SIndexR_SetExternalDll(dll_path))
  info1 <- SIndexR_ExternalDllInfo()
  expect_true(isTRUE(info1$loaded))
  expect_equal(info1$dll_path, dll_path)

  SIndexR_ClearExternalDll()
  info2 <- SIndexR_ExternalDllInfo()
  expect_false(isTRUE(info2$loaded))
})

test_that("external DLL mode matches built-in mode for core wrappers", {
  skip_if(.Platform$OS.type != "windows", "External DLL backend is Windows-only")

  dll_path <- get_external_dll_path()
  skip_if(is.na(dll_path), "Set SINDEX_EXTERNAL_DLL or place DLL at C:/sindex64.dll")

  # Built-in baseline values
  b_ht2si <- HT2SI(age = 50, age_type = 1, height = 30, species = "FDC", curve = "Bruce (1981ac)")
  b_si2ht <- SI2HT(iage = 50, age_type = 1, site_index = 30, species = "FDC", curve = "Bruce (1981ac)")
  b_siy2bh <- SIY2BH(site_index = 30, species = "FDC", curve = "Bruce (1981ac)")
  b_si2age <- SI2AGE(site_height = 30, age_type = 1, site_index = 30, species = "FDC", curve = "Bruce (1981ac)")
  b_age2age <- Age2Age(age1 = 50, age1_type = 1, age2_type = 0, species = "FDC", curve = "Bruce (1981ac)")

  on.exit(SIndexR_ClearExternalDll(), add = TRUE)
  expect_true(SIndexR_SetExternalDll(dll_path))

  # External DLL values
  e_ht2si <- HT2SI(age = 50, age_type = 1, height = 30, species = "FDC", curve = "Bruce (1981ac)")
  e_si2ht <- SI2HT(iage = 50, age_type = 1, site_index = 30, species = "FDC", curve = "Bruce (1981ac)")
  e_siy2bh <- SIY2BH(site_index = 30, species = "FDC", curve = "Bruce (1981ac)")
  e_si2age <- SI2AGE(site_height = 30, age_type = 1, site_index = 30, species = "FDC", curve = "Bruce (1981ac)")
  e_age2age <- Age2Age(age1 = 50, age1_type = 1, age2_type = 0, species = "FDC", curve = "Bruce (1981ac)")
  e_sc2si <- SC2SI("FDI", "M", "H")

  expect_equal(e_ht2si, b_ht2si, tolerance = 1e-6)
  expect_equal(e_si2ht, b_si2ht, tolerance = 1e-3)
  expect_equal(e_siy2bh, b_siy2bh, tolerance = 1e-3)
  expect_equal(e_si2age, b_si2age, tolerance = 5e-2)
  expect_equal(e_age2age, b_age2age, tolerance = 1e-6)
  expect_equal(e_sc2si, 27, tolerance = 1e-6)
})

test_that("external DLL reproduces SiteTools anchor points", {
  skip_if(.Platform$OS.type != "windows", "External DLL backend is Windows-only")

  dll_path <- get_external_dll_path()
  skip_if(is.na(dll_path), "Set SINDEX_EXTERNAL_DLL or place DLL at C:/sindex64.dll")

  on.exit(SIndexR_ClearExternalDll(), add = TRUE)
  expect_true(SIndexR_SetExternalDll(dll_path))

  # Anchors from SiteTools exports at BH age 50
  expect_equal(SI2HT(iage = 50, age_type = 1, site_index = 30, species = "FDC", curve = "Bruce (1981ac)"), 30, tolerance = 5e-2)
  expect_equal(SI2HT(iage = 50, age_type = 1, site_index = 30, species = "CWC", curve = "Nigh (2016)"), 30, tolerance = 5e-2)
})
