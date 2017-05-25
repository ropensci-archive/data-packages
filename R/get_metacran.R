library(gh)
res <- gh("GET /search/code", q = "user:cran extension:Rd docType{data")

lapply(res[[3]], function(x) {
  reponame <- x$repository$name
  repo_url <- paste0("https://github.com/cran/", reponame)
  dataset_rd <- gsub("\\.Rd$", "", x$name)
  
  list(reponame = reponame, 
       repo_url = repo_url, 
       dataset_rd = dataset_rd, 
       dataset_rd_url = paste("https://raw.githubusercontent.com/cran", 
                              reponame, x$sha, x$path, sep = "/"))
}
)
