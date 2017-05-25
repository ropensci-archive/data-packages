# This script finds CRAN R packages that have a data directory.
library(gh)
library(tibble)
library(purrr)
library(stringi)
library(dplyr)

token <- Sys.getenv("GITHUB_PAT")

dir.create("pkg-data")

ap <- available.packages()
pkg_names <- rownames(ap)

pkgs_with_data <- map_df(
  pkg_names,
  function(pkg_name) {
    message(pkg_name)
    pkg_data_file <- paste0("pkg-data/", pkg_name, ".rds")
    if(file.exists(pkg_data_file)) {
      # Already done this one
      return(readRDS(pkg_data_file))
    }
    # To avoid rate limiting. 5000 calls/hour allowed
    Sys.sleep(0.7)
    
    # Get repo directory tree
    res <- tryCatch(
      gh("/repos/cran/:repo/git/trees/master", repo = pkg_name, token = token),
      error = function(e) {
        if(any(stri_detect_fixed(e, "403 Forbidden"))) {
          # Should really check rate limit API and restart then
          # But easiest to just stop and manually restart later
          stop("Rate limit exceeded.")
        }
        NULL
      }
    )
    has_data_dir <- if(is.null(res)) {
      NA
    } else {
      # Is there a dir named "data"?
      any(map_lgl(res$tree, function(x) x$path == "data"))
    }
    pkg_data_data <- data_frame(
      pkg_name = pkg_name,
      has_data_dir = has_data_dir
    )
    # Dumb caching
    saveRDS(pkg_data_data, pkg_data_file)
    pkg_data_data
  }
)

# Probably more reliable to get this from RDS files, actually
pkg_data_data <- lapply(dir("pkg-data/", full.names = TRUE), readRDS) %>% 
  bind_rows()
