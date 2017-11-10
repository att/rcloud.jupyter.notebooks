caps <- NULL

.onLoad <- function(libname, pkgname) {

  ## Not in RCloud? Return silently
  if (! requireNamespace("rcloud.support", quietly = TRUE)) return()

  path <- system.file(
    package = "rcloud.jupyter.notebooks",
   "javascript",
   "rcloud.jupyter.notebooks.js"
  )

  caps <<- rcloud.support::rcloud.install.js.module(
    "rcloud.jupyter.notebooks",
    paste(readLines(path), collapse = '\n')
  )

  ocaps <- list(
    importIpynb = make_oc(importIpynb),
    exportIpynb = make_oc(exportIpynb)
  )

  if (!is.null(caps)) caps$init(ocaps)
}

make_oc <- function(x) {
  do.call(base::`:::`, list("rcloud.support", "make.oc"))(x)
}
