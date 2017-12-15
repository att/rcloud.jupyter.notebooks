#' Maps Ipynotebook to gist list
#'
#' @param json Json list
#' @param filename filename
#' @return list
ipyToJson <- function(json, filename){

  notebookName <- tools::file_path_sans_ext(basename(filename))

  notebook <- list(description = notebookName, files = list())

  for(i in seq_along(json$cells)){


    cellContent <- cellImportCheck(json$cells[[i]],
                                   fileEtx = json$metadata$language_info$file_extension)


  # Check cell has content before creating
  if(nchar(paste0(cellContent, collapse = "")) > 0){
    notebook$files[[paste0("part", i,  cellContent$ext)]] <- list(content =  paste(unlist(cellContent$content), collapse = ""))

  }
  }

  notebook

}

#' Converts Json list to Rcloud notebook
#'
#' @param text Json list
#' @param filename filename
#' @return notebook
#' @export

importIpynb <- function(text, filename){

  notebook <- ipyToJson(text, filename)

  res <- rcloud.support::rcloud.create.notebook(notebook, FALSE)

  if (!isTRUE(res$ok)) stop("failed to create new notebook")

  res$content
}

#' Checks cell type
#'
#' @param cell Json cell
#' @param fileEtx extracted from Json metadata
#' @return character string

cellImportCheck <- function(cell, fileEtx){

  content <-  cell$source

  ext <- if(cell$cell_type == "code"){
    fileEtx
  } else if(cell$cell_type == "markdown"){
    ".md"
  } else{
    stop("Cell type unknown")
  }

  ## Cell magics %%R %%! %%sh
  ## Line magics %R !
  lookUp <- data.frame(magic = c("%%R", "%R", "^!", "%%!", "%%sh"),
                       extn = c(".R", ".R", ".sh", ".sh", ".sh"))

  for(i in seq_along(lookUp$magic)){
    theMagic <- paste0("^", lookUp$magic[i])

    if(length(grep(theMagic, content)) > 0){

      content <- trimws(gsub(theMagic, replacement = "", x = content ))
      ext <- lookUp$extn[i]
      }
  }

  # Remove rpy2.ipython cell/line created by export
  content <- trimws(gsub("%load_ext rpy2.ipython", "", content))

  return(c(content = list(content), ext = as.character(ext)))


}

