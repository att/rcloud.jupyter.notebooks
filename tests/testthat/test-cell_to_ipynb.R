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

test_that("An R notebook list is converted to json list", {

  file <- "notebookR.rds"
  fileSh <- "notebookSh.rds"
  file_path <- file.path(paste0("data/", file))
  file_path_sh <- file.path(paste0("data/", fileSh))

  notebook <- readRDS(file_path)
  notebookSh <- readRDS(file_path_sh)
  json <- cellToIpynb(notebook$content$files)
  jsonSh <- cellToIpynb(notebookSh$content$files)

  expect_equal(names(json), c("cells", "metadata", "nbformat", "nbformat_minor"))
  expect_equal(names(jsonSh), c("cells", "metadata", "nbformat", "nbformat_minor"))


})



