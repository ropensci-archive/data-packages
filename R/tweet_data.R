library(rtweet)

token <- get_tokens()

# replace this with our generated list 
dt <- read.csv("https://raw.githubusercontent.com/vincentarelbundock/Rdatasets/master/datasets.csv")

i <- sample(seq_len(nrow(dt)), 1L)
cran_link <- paste0("https://cran.r-project.org/package=", 
                    dt[i, "Package"])
toot <- paste0("#RData: ", dt[i, "Title"], " - ", cran_link)

post_tweet(toot)
