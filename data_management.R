# This is the data management part of a consulting project where the client 
# had thousands of files with the data in rows that varied with 
# each file. The data were collected by a researcher interested in soil 
# respiration rates when different treatments were applied.

# packages required to run code (also requires plyr)
library(dplyr)
library(knitr)
library(WriteXLS)

# obtains file names and paths of csv files in specified folder 
files <- list.files('.../LI-8100 Files', 
                    full.names = TRUE, "\\.csv$")

# gets the raw data from each file and creates a list where each element is 
# a data frame 
file_data <-setNames(
  lapply(
    files, read.csv, skip = 31, header = TRUE, sep = ""), 
  tools::file_path_sans_ext(basename(files)))


# merges all of the data frames into one
soil <- do.call("rbind", file_data)

# labels rows with file name (number of rows varies with each file)
soil$Name <- rep(names(file_data), sapply(file_data, nrow))

# subsets data based on client's specifications
soil <- soil %>%
  filter(Type == '3', Tbench >= 0) %>%
  select('Cdry' = Tbench, Name) %>%
  droplevels()

# separates Name into 3 components (treatment, day, and jar)
tdjs <-strsplit(soil$Name, split = "-")

# converts lists into vectors and sets those vectors as variables in data frame
soil$Treatment <- as.factor(unlist(lapply(tdjs, `[`, 1)))
soil$Day <- as.factor(unlist(lapply(tdjs, `[`, 2)))
soil$Jar <- as.factor(unlist(lapply(tdjs, `[`, 3)))

# corrects client's labeling error 
levels(soil$Treatment)[levels(soil$Treatment) == "5C"] <- "C5"
soil$Name <- as.factor(soil$Name)
soil$Name <- plyr::mapvalues(soil$Name, 
                                  from = c("5C-11-1", "5C-11-11", 
                                           "5C-11-12", "5C-11-2", 
                                           "5C-11-5", "5C-11-6", 
                                           "5C-11-7", "5C-11-8"), 
                                  to = c("C5-11-1", "C5-11-11", 
                                         "C5-11-12", "C5-11-2",
                                         "C5-11-5", "C5-11-6", 
                                         "C5-11-7", "C5-11-8"))

# creates an excel file containing cleaned data set 
WriteXLS(soil, ExcelFileName = "soil_data.xlsx")