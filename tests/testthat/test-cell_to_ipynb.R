context("cell_to_ipynb")


test_that("notebook list is converted to json list", {

  file <- "notebook01.rds"
  file_path <- system.file(paste0("data/", file), package = "rcloud.jupyter.notebooks")

  notebook <- readRDS(file_path)
  json <- cell_to_ipynb(notebook$content$files)

  expect_equal(length(json), 4)
  expect_equal(class(json), "list")
  expect_equal(names(json), c("cells", "metadata", "nbformat", "nbformat_minor"))


})

