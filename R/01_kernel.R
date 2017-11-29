# R ----------------
kernelspecR <- list(display_name = "R",
                     language = "R",
                     name = "ir")

languageInfoR <- list(
  codemirror_mode = "r",
  file_extension = ".r",
  mimetype = "text/x-r-source",
  name = "R",
  pygments_lexer = "r",
  version = paste(version$major, version$minor, sep = "."))

# Python ------------
kernelspecPy <- list(display_name = "Python 3",
                      language = "python",
                      name = "python3")

languageInfoPy <- list(
  codemirror_mode = list(name = "ipython", version = 3),
  file_extension = ".py",
  mimetype = "text/x-python",
  name = "python",
  nbconvert_exporter = "python",
  pygments_lexer = "ipython3",
  version = "3.6.1")   ## TODO: determine Python version from user installation

