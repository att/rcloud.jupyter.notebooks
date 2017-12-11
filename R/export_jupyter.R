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
  kernel <- if(length(grep("Python", unique(cellLanguages))) > 0){
    "Python"
  }else if(length(grep("R", unique(cellLanguages))) > 0){
    "R"
    # Eg. markdown or bash cells - set kernel to python
  } else{
    "Python"
  }

  metaData <- getKernel(lang = kernel)

  # Create json Shell
  json <- list(cells = list(),
               metadata = list(kernelspec = metaData$kernelspec,
                               language_info = metaData$language_info),
               nbformat = 4L,
               nbformat_minor = 2L)

  for(i in seq_along(cells)){

    json$cells[[i]] <- list(cell_type = cellType(cells[[i]]),
                            execution_count = i,                                 # Cell number
                            metadata = structure(list(), .Names = character(0)), # Named list
                            outputs = list(),                                    # Ignore output (TO DO: markdown)
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
