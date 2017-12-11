context("cellToIpynb")


test_that("notebook list is converted to json list", {

  file <- "notebook01.rds"
  file_path <- file.path(paste0("data/", file))

  notebook <- readRDS(file_path)
  json <- cellToIpynb(notebook$content$files)

  expect_equal(length(json), 4)
  expect_equal(class(json), "list")
  expect_equal(names(json), c("cells", "metadata", "nbformat", "nbformat_minor"))


})

