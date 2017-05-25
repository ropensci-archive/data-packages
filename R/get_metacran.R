library(gh)
res <- gh("GET /search/code", q = "user:cran extension:Rd docType{data")

lapply(res[[3]], function(x) {
  reponame <- x$repository$name
  repo_url <- paste0("https://github.com/cran/", reponame)
  dataset_rd <- gsub("\\.Rd$", "", x$name)
  dataset_rd_url <- gsub("github\\.com", "raw.githubusercontent.com", 
                         x$html_url)
  dataset_rd_url <- gsub("/blob/", "/", dataset_rd_url)
  
  list(reponame = reponame, 
       repo_url = repo_url, 
       dataset_rd = dataset_rd, 
       dataset_rd_url = dataset_rd_url)
}
)
