context("Wrapper functions for SIndexR")

test_that("HT2SI returns expected site index for known inputs", {
  expect_equal(HT2SI(1, 50, 1, 30, 0), 30)
})

test_that("SI2HT returns expected height for known inputs", {
  expect_equal(SI2HT(1, 50, 1, 30), 30)
})

test_that("SI2AGE returns expected approximate age", {
  res <- SI2AGE(1, 30, 1, 30)
  expect_true(is.numeric(res))
  expect_equal(round(res, 5), 50.49023)
})

test_that("SIY2BH computes breast height age correctly", {
  expect_equal(SIY2BH(1, 30), 2)
})

test_that("SIY2BH05 computes 0.5-step breast height age", {
  v <- SIY2BH05(1, 30)
  expect_true(is.numeric(v))
  expect_true(v > 0)
  expect_equal((v * 2) %% 1, 0)
})

test_that("Y2BH05 alias matches SIY2BH05", {
  expect_equal(Y2BH05(1, 30), SIY2BH05(1, 30))
})

test_that("wrappers accept species codes with default curve selection", {
  expect_equal(HT2SI(age = 50, age_type = 1, height = 30, species = "SW"), 30)
  expect_equal(SI2HT(iage = 50, age_type = 1, site_index = 30, species = "SW"), 30)

  y2bh <- SIY2BH(site_index = 30, species = "SW")
  expect_true(is.numeric(y2bh))
  expect_true(y2bh > 0)
})

test_that("curve options helper returns default flag", {
  opts <- CurveOptions("SW")
  expect_true(is.data.frame(opts))
  expect_true(nrow(opts) >= 1)
  expect_true(all(c("curve_index", "curve_name", "is_default") %in% names(opts)))
  expect_equal(sum(opts$is_default), 1)
})

test_that("compact curve menu printer returns options invisibly", {
  out <- capture.output(ret <- PrintCurveOptions("SW"))
  expect_true(length(out) >= 1)
  expect_true(is.data.frame(ret))
  expect_true(any(grepl("\\*", out)))
})

test_that("Age2Age converts age types", {
  res <- Age2Age(cu_index = 112, age1 = 50, age1_type = 1, age2_type = 0, y2bh = 2)
  expect_true(is.numeric(res))
  expect_true(res > 0)
})

test_that("Age2Age accepts species codes", {
  res <- Age2Age(age1 = 50, age1_type = 1, age2_type = 0, species = "SW")
  expect_true(is.numeric(res))
  expect_true(res > 0)
})

test_that("AgeToAge backward-compat alias matches Age2Age", {
  res_new <- Age2Age(age1 = 50, age1_type = 1, age2_type = 0, species = "SW")
  res_alias <- AgeToAge(age1 = 50, age1_type = 1, age2_type = 0, species = "SW")
  expect_equal(res_alias, res_new)
})

test_that("SIndexR_AgeToAge legacy alias matches Age2Age", {
  res_new <- Age2Age(age1 = 50, age1_type = 1, age2_type = 0, species = "SW")
  res_legacy <- SIndexR_AgeToAge(age1 = 50, age1_type = 1, age2_type = 0, species = "SW")
  expect_equal(res_legacy, res_new)
})

test_that("SC2SI converts site class to index", {
  res <- SC2SI("FDI", "M")
  expect_equal(res, 17)
})

test_that("SC2SI validates site class", {
  expect_error(SC2SI("FDI", "X"), "site_class must be")
})

test_that("SiteClassToIndex backward-compat alias matches SC2SI", {
  expect_equal(SiteClassToIndex("FDI", "M"), SC2SI("FDI", "M"))
})

test_that("SIndexR_SIToSI converts between defined species pairs", {
  ba_idx <- SIndexR_SpeciesIndex("BA")
  hwc_idx <- SIndexR_SpeciesIndex("HWC")

  ba_to_hwc <- SIndexR_SIToSI(ba_idx, 20, hwc_idx)
  hwc_to_ba <- SIndexR_SIToSI(hwc_idx, 20, ba_idx)

  expect_equal(ba_to_hwc$error, 0)
  expect_equal(hwc_to_ba$error, 0)
  expect_true(ba_to_hwc$output > 0)
  expect_true(hwc_to_ba$output > 0)
})

test_that("SI2SI wrapper returns numeric conversion for defined species pairs", {
  ba_to_hwc <- SI2SI("BA", 20, "HWC")
  hwc_to_ba <- SI2SI("HWC", 20, "BA")

  expect_true(is.numeric(ba_to_hwc))
  expect_true(is.numeric(hwc_to_ba))
  expect_true(ba_to_hwc > 0)
  expect_true(hwc_to_ba > 0)
})

test_that("SIndexR_SIToSI output matches SI2SI values", {
  ba_idx <- SIndexR_SpeciesIndex("BA")
  hwc_idx <- SIndexR_SpeciesIndex("HWC")

  legacy <- SIndexR_SIToSI(ba_idx, 20, hwc_idx)
  wrapper <- SI2SI(ba_idx, 20, hwc_idx)

  expect_equal(legacy$error, 0)
  expect_equal(legacy$output, wrapper)
})

