context("ipyToJson")

test_that("ipyToJson takes a JSON structure and converts to a notebook like list",{

  file <- "ipyOut.ipynb"
  file_path <- system.file(paste0("data/", file), package = "rcloud.jupyter.notebooks")

  json <- jsonlite::read_json(file_path)
  notebook <- ipyToJson(json, "ipynbOut.ipynb")

  expect_equal(class(notebook), "list")
  expect_equal(names(notebook), c("description", "files"))

})
