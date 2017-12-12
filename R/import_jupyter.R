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
                                   language = json$metadata$language_info$file_extension)

    notebook$files[[paste0("part", i,  cellContent$ext)]] <- list(content =  paste(unlist(cellContent$content), collapse = ""))

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
    return(language)
  } else if(cell$cell_type == "markdown"){

    return(".md")

  }else{
    stop("Cell type unknown")
  }
}

cellImportCheck <- function(cell, language){

  content <- cell$source

  ext <- if(cell$cell_type == "code"){
    language
  } else if(cell$cell_type == "markdown"){
    ".md"
  } else{
    stop("Cell type unknown")
  }

  ## Cell magics %%R %%! %%sh
  ## Line magics %R !

  if(length(grep("^%%R", content)) > 0){
    content <- gsub("^%%R", replacement = "", x = content )
    ext <- ".R"
  }
  if(length(grep("^%R", content)) > 0){
    content <- gsub("^%R", replacement = "", x = content )
    ext <- ".R"
  }

  if(length(grep("^!", content)) > 0 ){
    content <- gsub("^!", replacement = "", x = content )
    ext <- ".sh"
  }
  if(length(grep("^%%!", content)) > 0 ){
    content <- gsub("^%%!", replacement = "", x = content )
    ext <- ".sh"
  }
  if(length(grep("^%%sh", content)) > 0 ){
    content <- gsub("^%%sh", replacement = "", x = content )
    ext <- ".sh"
  }

  return(c(content = list(content), ext = ext))


}

