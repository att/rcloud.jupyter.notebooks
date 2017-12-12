context("cellLanguage")

test_that("cell language of a notebook can be detected and kernel returned",{

  file <- "python_Notebook.rds"
  file_path <- file.path(paste0("data/", file))

  notebook <- readRDS(file_path)
  language <- cellLanguage(notebook$content$files$part1.py)

  kernelOut <- getKernel(lang = language)

  expect_equal(language, "Python")
  expect_equal(kernelOut, list(language_info = languageInfoPy,
                         kernelspec = kernelspecPy))
  expect_equal(getKernel("R"), list(language_info = languageInfoR,
                                 kernelspec = kernelspecR))

})

test_that("notebok cell type", {

  file <- "notebook01.rds"
  file_path <- file.path(paste0("data/", file))

  notebook <- readRDS(file_path)
  type <- cellType(notebook$content$files$part1.R)

  expect_equal(type, "code")
})


