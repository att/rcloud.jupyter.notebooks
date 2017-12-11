#' Maps Ipynotebook to gist list
#'
#' @param json Json list
#' @param filename filename
#' @return list
#' @export
ipyToJson <- function(json, filename){

  notebookName <- tools::file_path_sans_ext(basename(filename))

  notebook <- list(description = notebookName, files = list())

  for(i in seq_along(json$cells)){

    extn <- noteBookType(cell = json$cells[[i]], language = json$metadata$language_info$name)

    notebook$files[[paste0("part", i,  extn)]] <- list(content = paste(unlist(json$cells[[i]]$source), collapse = ""))
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
#' @param language extracted from Json metadata
#' @return character string

noteBookType <- function(cell, language){

  if(cell$cell_type == "code"){
    if(language == "python") language <- "py"

    return(paste0(".", language))

  } else if(cell$cell_type == "markdown"){

    return(".md")

  }else{
    stop("Cell type unknown")
  }
}



