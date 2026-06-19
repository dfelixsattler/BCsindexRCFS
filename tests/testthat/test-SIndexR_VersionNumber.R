test_that("sindex_version returns the correct version number", {
  library(data.table)
  library(testthat)
  expect_is(sindex_version(), "integer")
  expect_equal(sindex_version(), 152L)
})
