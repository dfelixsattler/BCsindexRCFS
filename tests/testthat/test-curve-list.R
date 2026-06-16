context("Curve listing helpers")

test_that("SIndexR_CurveList returns a non-empty integer vector for a species with defined curves", {
  valid_species <- vapply(0:143, function(sp) {
    curves <- SIndexR_CurveList(sp)
    length(curves) > 0
  }, logical(1))

  expect_true(any(valid_species))
  sp <- which(valid_species)[1] - 1
  curves <- SIndexR_CurveList(sp)
  expect_true(is.integer(curves) || is.numeric(curves))
  expect_true(length(curves) >= 1)
  expect_true(all(curves > 0))
})
