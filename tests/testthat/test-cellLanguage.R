context("cellLanguage")

test_that("cell language of a notebook can be detected",{

  file <- "python_Notebook.rds"
  file_path <- file.path(paste0("data/", file))

  notebook <- readRDS(file_path)
  language <- cellLanguage(notebook$content$files$part1.py, kernel = FALSE)
  kernel <- cellLanguage(notebook$content$files$part1.py)

  test_that(language, "Python")
  test_that(names(kernel), c("language_info", "kernelspec"))
})

test_that("notebok cell type", {

  file <- "notebook01.rds"
  file_path <- file.path(paste0("data/", file))

  notebook <- readRDS(file_path)
  type <-       cellType(notebook$content$files$part1.R)

  expect_equal(type, "code")
})

