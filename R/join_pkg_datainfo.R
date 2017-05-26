# All the packages from CRAN
cran <- tools::CRAN_package_db()

# clean up
# cran$LazyData <- toupper(cran$LazyData)
# cran$LazyData[cran$LazyData == "NO"] <- FALSE
# cran$LazyData[cran$LazyData == "YES"] <- TRUE
# cran$LazyData[cran$LazyData == "LAZYDATA: TRUE"] <- TRUE
# cran$LazyData[cran$LazyData == "NA"] <- NA
# cran$LazyData[cran$LazyData == ""] <- NA
# table(cran$LazyData)

# All the packages containing a data folder
x <- readRDS("data/pkg_data_data.rds")
x <- x[x$has_data_dir == TRUE,]

pkgs <- cran[which(cran$Package %in% x$pkg_name), ]

rm(x, cran)

# DOWNLOAD ALL THE RELEVANT PACKAGES FROM CRAN
packs <- pkgs$Package
# new_packages <- packs[!(packs %in% installed.packages()[,"Package"])]
# if(length(new_packages)) install.packages(new_packages)

# # Test using already installed packages (Claudia's laptop)
# packs <- packs[packs %in% installed.packages()[,"Package"]]
# df <- data.frame(matrix(NA, nrow = 0, ncol = 5))
# names(df) <- c("Package", "Item", "class", "dim", "Title")
# for (pack in packs) {
#   x <- try(vcdExtra::datasets(package = pack, incPackage = T), silent = T)
#   if (class(x) == "data.frame") {
#     print(pack)
#     df <- rbind(df, x)
#   }
#   try(unloadNamespace(pack), silent = TRUE)
# }
# saveRDS(df, "data/datasets_info.rds")

# Add data from gh (Andy)
gh <- read.csv("data/data_rd_metadata.csv")
names(gh)[1] <- names(pkgs)[1]

# Test using already installed packages (Richie's laptop)
dfR <- readRDS("data/metadata-for-many-pkgs.rds")
dfC <- readRDS("data/metadata-for-many-pkgs2.rds")
df <- rbind(dfR, dfC); rm(dfC, dfR)
df <- df[!duplicated(df), ]
df <- df[which(df$pkg_name %in% pkgs$Package),]
names(df)[1] <- names(pkgs)[1]
names(df)[2] <- names(gh)[2]
names(df)[10] <- names(gh)[3]

# Join the dataset info with the package info
temp1 <- dplyr::left_join(df, pkgs, "Package")
temp2 <- dplyr::left_join(gh, pkgs, "Package")
dfX <- dplyr::full_join(temp1, temp2, c(names(pkgs), names(df)[c(2, 10)]))
dfX <- dfX[!duplicated(dfX[, c("Package", "dataset_name")]), ]
rm(df, gh, pkgs, temp1, temp2)

# Select only the info you want to visualise
dfX <- dfX[, c("Package", "License", "Description", "URL", "dataset_name", 
               "dataset_title", "dataset_description", "type", "classes", 
               "length", "n_elts", "nrow", "ncol", "dims", "dataset_format", 
               "dataset_source", "dataset_has_examples", "dataset_has_links")]
saveRDS(dfX, "data/pkgs_datasets_final.rds")

dfX2 <- dfX[, c("Package", "License", "Description", "URL")]
saveRDS(dfX2, "data/pkgs_datasets_final2.rds")

dfX3 <- dfX[, c("dataset_name", 
               "dataset_title", "dataset_description", "type", "classes", 
               "length", "n_elts", "nrow", "ncol", "dims")]
saveRDS(dfX3, "data/pkgs_datasets_final3.rds")

dfX4 <- dfX[, c("dataset_format", 
               "dataset_source", "dataset_has_examples", "dataset_has_links")]
saveRDS(dfX4, "data/pkgs_datasets_final4.rds")
