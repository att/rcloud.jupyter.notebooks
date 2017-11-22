# notebook <- readRDS("data/notebooks/notebook01.rds")
# notebook$content$files$part2.py <- structure(list(filename = "part2.py", type = "text/plain", language = "Python",
#                                                   raw_url = "", size = 18L, content = "x = 10"), .Names = c("filename",
#                                                                                                                          "type", "language", "raw_url", "size", "content"))
#
# #metaData <- cellLanguage(cells[[1]])
# theLang <- cellLanguages[1]
# theKernel <- metaData$kernelspec$language
# content <- JSON$cells[[1]]$source

#' Checks each cell language against kernel
#' if cell language differs from kernel, cell magics pre-pended to allow code to run
#'
#' @param cellLanguage
#' @param kernel
#' @param content
#' @export

magicsContent <- function(cellLanguage, kernel, content){

  if(cellLanguage != kernel & cellLanguage == "R"){
    warning <- "# Excuting R code in a Python notebook. Ensure you have loaded the correct extensions in an above cell\n # eg. %load_ext rpy2.ipython\n"
   content <-  list(paste("%%R\n", warning,content))
  }
  return(content)
}


