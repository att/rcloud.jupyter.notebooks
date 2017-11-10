#' Creates an ipynb list structure and writes to file
#'
#' @param id notebook id
#' @param version notebook version
#' @param file Optional file path to write to
#' @return A list
#' @export

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
  jsonlite::write_json(x = cell_To_IPYNB(cells), path = tmp, auto_unbox = TRUE)

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
#' @examples
#' notebook <- readRDS("data/notebooks/notebook01.rds")
#' cell_To_IPYNB(notebook$content$files)

cell_To_IPYNB <- function(cells){

  # Check language of first cell
  #Jupyter notebooks currently do not support multple languages
  metaData <- cellLanguage(cells[[1]])

  # Create JSON Shell
  JSON <- list(cells = list(),
               metadata = list(kernelspec = metaData$kernelspec,
                               language_info = metaData$language_info),
               nbformat = 4L,
               nbformat_minor = 2L)

  for(i in seq_along(cells)){

    JSON$cells[[i]] <- list(cell_type = cellType(cells[[i]]),
                            execution_count = i,                                 # Cell number
                            metadata = structure(list(), .Names = character(0)), # Named list
                            outputs = list(),                                    # Ignore output (TO DO: markdown)
                            source = list(cells[[i]]$content))                   # Pull content of each cell
  }
  return(JSON)

}

#' Check if cell is code or markdown
#'
#' @param cell A single notebook cell
#' @return cell type
#' @examples
#' notebook <- readRDS("data/notebooks/notebook01.rds")
#' cellType(notebook$content$files$part1.R)
cellType <- function(cell){
  if(grepl("^part.*\\.md$", cell$filename)){
    return("markdown")
  }else if(grepl("^part.*\\.rmd$", cell$filename)){
    return("markdown")
  } else{
    return("code")
  }
}

#' Checks the language of a cell. (First cell supplied)
#'
#' @param cell A single notebook cell
#' @return list containing either python or R kernel nad language info
#' @examples
#' notebook <- readRDS("data/notebooks/notebook01.rds")
#' cellLanguage(notebook$content$files$part1.R)
cellLanguage <- function(cell){
  if (grepl("^part.*\\.R$", cell$filename)) {
    return(list(language_info = language_info_R,
                kernelspec = kernelspec_R))

  } else if(grepl("^part.*\\.py$", cell$filename)){
    return(list(language_info = language_info_py,
                kernelspec = kernelspec_py))

  }
}

