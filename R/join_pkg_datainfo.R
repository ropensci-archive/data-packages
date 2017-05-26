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

# Test using already installed packages (Claudia's laptop)
packs <- packs[packs %in% installed.packages()[,"Package"]]
df <- data.frame(matrix(NA, nrow = 0, ncol = 5))
names(df) <- c("Package", "Item", "class", "dim", "Title")
for (pack in packs) {
  x <- try(vcdExtra::datasets(package = pack, incPackage = T), silent = T)
  if (class(x) == "data.frame") {
    print(pack)
    df <- rbind(df, x)
  }
  try(unloadNamespace(pack), silent = TRUE)
}
saveRDS(df, "data/datasets_info.rds")

# Test using already installed packages (Richie's laptop)
dfR <- readRDS("data/metadata-for-many-pkgs.rds")
names(dfR)[1] <- names(pkgs)[1]

names(dfR) <- c()
names(df)

# Add data from gh (Andy)
gh <- read.csv("data/data_rd_metadata.csv")
names(gh)[1] <- names(pkgs)[1]

# Join the dataset info with the package info
temp1 <- dplyr::left_join(df, pkgs, "Package")
temp2 <- dplyr::left_join(gh, pkgs, "Package")
dfX <- dplyr::full_join(temp1, temp2, names(pkgs))

# Which columns do not contain NAs?
cols <- names(dfX)[which(!apply(dfX, 2, function(x) any(is.na(x))))] # only dataset info an pkg name!

# Select only the info you want to visualise
dfX2 <- dfX[,cols]
# as.data.frame(names(dfX2))
# dfX2 <- dfX2[, c(1, 13, 6, 7, 11, 14, 2, 5, 3, 4)]
# names(dfX2)[c(2, 8, 7)] <- c("PackageTitle", "DatasetTitle", "DatasetName")
# as.data.frame(names(dfX2))
# saveRDS(dfX2, "data/pkgs_datasets_info_small.rds")
dfX2 <- dfX2[, c(1, 14, 7, 8, 12, 15, 3, 4, 5, 6)]
saveRDS(dfX2, "data/pkgs_datasets_info_small2.rds")
