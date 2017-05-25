library(gh)
library(dplyr)
library(purrr)
res <- gh("GET /search/code", q = "user:cran extension:Rd docType{data")

get_tag <- function(rd, tag) {
  x <- tools:::.Rd_get_metadata(rd, kind = tag)
  if (!length(x)) return(NA_character_)
  x <- x[nchar(x) > 0]
  x
}

rd_file_meta <- map_df(res[[3]], function(x) {
  reponame <- x$repository$name
  repo_url <- paste0("https://github.com/cran/", reponame)
  dataset_rd <- gsub("\\.Rd$", "", x$name)
  dataset_rd_url <- gsub("github\\.com", "raw.githubusercontent.com", x$html_url)
  dataset_rd_url <- gsub("/blob/", "/", dataset_rd_url)
  rd_text <-  tools::parse_Rd(dataset_rd_url)
  
  data_frame(pkg_name = reponame, 
       repo_url = repo_url, 
       dataset_rd_url = dataset_rd_url, 
       data_rd_name = get_tag(rd_text, "name"), 
       data_rd_alias = get_tag(rd_text, "alias"),
       data_rd_title = get_tag(rd_text, "title"), 
       data_rd_usage = get_tag(rd_text, "usage"), 
       data_rd_description = get_tag(rd_text, "description")
       )
})
