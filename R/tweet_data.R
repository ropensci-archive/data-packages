library(rtweet)

# token <- get_tokens()
token <- twitter_token

# replace this with our generated list 
dt <- readRDS("data/pkgs_datasets_final.rds")

i <- sample(seq_len(nrow(dt)), 1L)
cran_link <- paste0("https://cran.r-project.org/package=", 
                    dt[i, "Package"])
(toot <- paste0("#rdata #rstats: ", dt[i, "dataset_title"], " - ", cran_link))

post_tweet(toot, token = token)
