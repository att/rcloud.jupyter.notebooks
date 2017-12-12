#' Creates an ipynb list structure and writes to file
#'
#' @param id notebook id
#' @param version notebook version
#' @param file Optional file path to write to
#' @return A list
#' @importFrom jsonlite write_json

exportIpynb <- function(id ,version, file = NULL){

  # Use rcloud.support to read notebook
  notebook <- rcloud.support::rcloud.get.notebook(id, version)

  if (!notebook$ok) return(NULL)  # Check notebook

  cells <- notebook$content$files
  cells <- cells[grep("^part", names(cells))] # Pull out cells parts

  if (!length(names(cells))) return(NULL)

  #Extracts the part numbers
  cnums <- suppressWarnings(as.integer(
    gsub("^\\D+(\\d+)\\..*", "\\1", names(cells))
  ))

  cells <- cells[match(sort.int(cnums), cnums)]  # Order cells

  # Create a temp file if file not specifed
  tmp <- file

  if (is.null(tmp)) {
    tmp <- tempfile(fileext = ".ipynb")
    on.exit(unlink(tmp), add = TRUE)
  }

  # Write list to file
  jsonlite::write_json(x = cellToIpynb(cells), path = tmp, auto_unbox = TRUE)

  if (is.null(file)) {
    list(
      description = notebook$content$description,
      jup = readChar(tmp, file.info(tmp)$size),
      file = tmp
    )
  } else {
    invisible()
  }

}

#' Converts notebook cells to JSON cells
#'
#' @param cells A list of cells.
#' @return A list

cellToIpynb <- function(cells){

  # Check language of all cells
  cellLanguages <- lapply(cells, cellLanguage)

  #If any cells are Python, kernel is Python
  kernel <- if(any(cellLanguages == "Python")){
    "Python"
  }else if(any(cellLanguages == "R")){
    "R"
    # Eg. markdown or bash cells - set kernel to python
  } else{
    "Python"
  }

  metaData <- getKernel(lang = kernel)


  # Create json
  json <- list(cells = list(),
               metadata = list(kernelspec = metaData$kernelspec,
                               language_info = metaData$language_info),
               nbformat = 4L,
               nbformat_minor = 2L)

  # If mulitple language add cell to load the correct extentions
  cells <- cellMagicExt(kernel, cellLanguages, cells)

  for(i in seq_along(cells)){

    json$cells[[i]] <- list(cell_type = cellType(cells[[i]]),
                             execution_count = i,                                 # Cell number
                             metadata = structure(list(), .Names = character(0)), # Named list
                             outputs = list(),                                    # Ignore output
                             source = list(cells[[i]]$content))                   # Pull content of each cell


    # Markdown cells do not require an output or execution count
    if(cellType(cells[[i]]) == "markdown"){
      json$cells[[i]]$outputs <- NULL
      json$cells[[i]]$execution_count <- NULL
    }

    #If RCloud cells are shell script paste each line of content with ! to run in Jupyter
    if(cellLanguage(cells[[i]]) == "Shell"){
      json$cells[[i]]$source <- shellContent(json$cells[[i]]$source[[1]])

    }

    #If multi-language - need to update content to include magics
    if(kernel == "Python" && cellLanguage(cells[[i]]) == "R"){
      json$cells[[i ]]$source <- paste("%%R\n", json$cells[[i]]$source[[1]], collapse = "")

    }
  }
  return(json)

}

#' Check if cell is code or markdown
#'
#' @param cell A single notebook cell
#' @return cell type

cellType <- function(cell){
  if(grepl("^part.*\\.md$", cell$filename)){
    return("markdown")
  }else if(grepl("^part.*\\.Rmd$", cell$filename)){
    return("markdown")
  } else{
    return("code")
  }
}

#' Checks the language of a cell.
#'
#' @param cell A single notebook cell
#' @return Language of given cell (string)

cellLanguage <- function(cell){

  lang <-  if (grepl("^part.*\\.R$", cell$filename)) {
    "R"
  } else if(grepl("^part.*\\.py$", cell$filename)){
    "Python"
  } else if(grepl("^part.*\\.md$", cell$filename)){
    "Markdown"
  } else if(grepl("^part.*\\.sh$", cell$filename)){
    "Shell"
  } else{
    "Cell Language unknown"
  }

  lang

}

#' Return list in the format used for Jupyter kernel
#'
#' @param lang either 'R' or 'Python'
#' @return list containing either python or R kernel nad language info
getKernel <- function(lang = c("R", "Python")){
  if(lang == "R"){
    return(list(language_info = languageInfoR,
                kernelspec = kernelspecR))
  }else if(lang == "Python") {
    return(list(language_info = languageInfoPy,
                kernelspec = kernelspecPy))
  } else{
    return(NULL)
  }
}


#' Converts as shell cell to jupyter executable format
#' @description Running shell code in jupyter notebooks is currently only supported in a python kernel
#'
#' @param content shell cell content
#' @return content
shellContent <- function(content){
  splitLine <- strsplit(content, split = "\n")[[1]]
  pasteShell <- paste("!", splitLine)
  bindContent <- paste(pasteShell, collapse = "\n")
  return(bindContent)

}


#' Adds a cell to load extentions required to run R magic cells
#' @description Currently only supports R cells in Python, this funtion will be lkely to expand to support new languages
#'              Appends cell at top of notebook.
#'
#' @param kernel kernle
#' @param cellLanguages all cell languages in notebook
#' @param cells list to append to
#' @return content
cellMagicExt <- function(kernel, cellLanguages, cells){

  if(kernel == "Python" && "R" %in% cellLanguages){
    ## Insert cell to load rpy2.ipython
    cells <- c(part0.py = list(list(filename = "part0.py",
                                    language = "python",
                                    content = "%load_ext rpy2.ipython")),
               cells)
  }
  return(cells)
}

