# https://raw.githubusercontent.com/r-pkgs/desc/master/R/read.R
collate_fields <- c(
  main = "Collate",
  windows = "Collate.windows",
  unix = "Collate.unix"
)

field_classes <- list(
  
  Package = "Package",
  Version = "Version",
  License = "License",
  Description = "Description",
  Title = "Title",
  Maintainer = "Maintainer",
  AuthorsAtR = "Authors@R",
  
  DependencyList = c("Imports", "Suggests", "Depends", "Enhances",
                     "LinkingTo"),
  RepoList = "Additional_repositories",
  URL = "BugReports",
  URLList = "URL",
  Priority = "Priority",
  Collate = unname(collate_fields),
  Logical = c("LazyData", "KeepSource", "ByteCompile", "ZipData", "Biarch",
              "BuildVignettes", "NeedsCompilation", "License_is_FOSS",
              "License_restricts_use", "BuildKeepEmpty", "BuildManual",
              "BuildResaveData", "LazyLoad"),
  PackageList = c("VignetteBuilder", "RdMacros"),
  Encoding = "Encoding",
  OSType = "OS_type",
  Type = "Type",
  Classification = c("Classification/ACM", "Classification/ACM-2012",
                     "Classification/JEL", "Classification/MSC", "Classification/MSC-2010"),
  Language = "Language",
  Date = "Date",
  Compression = c("LazyDataCompression", "SysDataCompression"),
  Repository = "Repository",
  
  FreeForm = c("Author", "SystemRequirements",
               "Archs", "Contact", "Copyright", "MailingList", "Note", "Path",
               "LastChangedDate", "LastChangedRevision", "Revision", "RcmdrModels",
               "RcppModules", "Roxygen", "Acknowledgements", "Acknowledgments",
               "biocViews"),
  
  AddedByRCMD = c("Built", "Packaged", "MD5sum", "Date/Publication")
)

field_classes$FreeForm <- c(
  field_classes$FreeForm,
  paste0(unlist(field_classes), "Note")
)

create_fields <- function(keys, values) {
  mapply(keys, values, SIMPLIFY = FALSE, FUN = create_field)
}

create_field <- function(key, value) {
  f <- structure(list(key = key, value = value), class = "DescriptionField")
  if (key %in% unlist(field_classes)) {
    cl <- paste0("Description", find_field_class(key))
    class(f) <- c(cl, class(f))
  }
  f
}

find_field_class <- function(k) {
  names(which(vapply(field_classes, `%in%`, logical(1), x = k)))
}

read_dcf <- function(file) {
  lines <- readLines(file)
  no_tws_fields <- sub(
    ":$",
    "",
    grep("^[^\\s]+:$", lines, perl = TRUE, value = TRUE)
  )
  
  con <- textConnection(lines, local = TRUE)
  fields <- colnames(read.dcf(con))
  close(con)
  
  con <- textConnection(lines, local = TRUE)
  res <- read.dcf(con, keep.white = fields)
  close(con)
  
  con <- textConnection(lines, local = TRUE)
  res2 <- read.dcf(con, keep.white = fields, all = TRUE)
  close(con)
  
  if (any(mismatch <- res != res2)) {
    stop("Duplicate DESCRIPTION fields: ",
         paste(sQuote(colnames(res)[mismatch]), collapse = ", "))
  }
  
  notws <- res[1, match(no_tws_fields, fields)]
  
  list(
    dcf = create_fields(fields, res[1, ]),
    notws = notws
  )
}

library(desc)
library(tidyverse)

### package name to a description file
package_name_to_dsc <- function(package_name){
  sprintf("https://raw.githubusercontent.com/cran/%s/master/DESCRIPTION", package_name)
}

### description file to a data_frame object
dsc_to_df <- function(dsc){
  dsc <- dsc[[1]]
  key_to_df <- function(dsc_element){
    df <- data_frame(dsc_element$value) %>% 
      set_names(dsc_element$key)
    df
  }
  dsc %>%
    map(~key_to_df(.)) %>% 
    do.call(cbind, .)
  
}

### package names to a data_frame
package_names <- c("ggplot2", "sp")

package_names %>% 
  map(~package_name_to_dsc(.)) %>% 
  map(~read_dcf(.)) %>% 
  map_df(~dsc_to_df(.))
