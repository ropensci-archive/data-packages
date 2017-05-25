library(gh)
library(dplyr)
library(purrr)
library(stringi)

get_tag <- function(rd, tag) {
  x <- tools:::.Rd_get_metadata(rd, kind = tag)
  if (!length(x)) return(NA_character_)
  x <- x[nchar(x) > 0]
  x
}

pkgs <- readRDS("pkg_data_data.rds")
pkgs_with_data <- pkgs$pkg_name[pkgs$has_data_dir]

pkgs_data_rds <- lapply(pkgs_with_data[1:20], function(pkg_name) {
  message(pkg_name)
  Sys.sleep(0.7)
  query <- sprintf( "repo:cran/%s extension:Rd docType{data", pkg_name)
  res <- tryCatch(gh("GET /search/code", q = query), 
                  error = function(e) {
                    if(any(stri_detect_fixed(e, "403 Forbidden"))) {
                      # Should really check rate limit API and restart then
                      # But easiest to just stop and manually restart later
                      stop("Rate limit exceeded.")
                    }
                    NULL
                  })
  res[[3]]
})

# res <- gh("GET /search/code", q = "user:cran extension:Rd docType{data")


rd_file_meta <- map_df(pkgs_data_rds, function(x) {
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
