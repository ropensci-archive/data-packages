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

pkgs <- readRDS("data/pkg_data_data.rds")
pkgs_with_data <- pkgs$pkg_name[pkgs$has_data_dir]

pkgs_data_rds <- lapply(pkgs_with_data[1:100], function(pkg_name) {
  message(pkg_name)
  Sys.sleep(2)
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
  res
})

# res <- gh("GET /search/code", q = "user:cran extension:Rd docType{data")


rd_file_meta <- lapply(pkgs_data_rds, function(x) {
  if (!length(x$items)) return(NULL)
  x <- x$items[[1]]
  reponame <- x$repository$name
  repo_url <- paste0("https://github.com/cran/", reponame)
  dataset_rd <- gsub("\\.Rd$", "", x$name)
  dataset_rd_url <- gsub("github\\.com", "raw.githubusercontent.com", x$html_url)
  dataset_rd_url <- gsub("/blob/", "/", dataset_rd_url)
  rd_text <- readLines(dataset_rd_url)
  list(name = reponame, 
       repo_url = repo_url, 
       dataset_rd_url = dataset_rd_url, 
       rd_text = rd_text,
       rd_text_parsed = tools::parse_Rd(textConnection(rd_text))
  )
})

rd_metadata <- map_df(rd_file_meta, function(x) {
  if (is.null(x)) return(NULL)
  data_frame(pkg_name = x$name, 
             dataset_name = get_tag(x$rd_text_parsed, "name"), 
             dataset_alias = get_tag(x$rd_text_parsed, "alias"),
             dataset_title = paste(get_tag(x$rd_text_parsed, "title"), collapse = " "), 
             dataset_description = paste(get_tag(x$rd_text_parsed, "description"), collapse = " ")
  )
})
