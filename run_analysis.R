## Download data and store to temp file

url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "coursera.zip", method = "curl", quiet = TRUE)
dir.create(coursera)
unzip(coursera, exdir = coursera)

## read files
act.labels <- read.table("~/coursera/UCI HAR Dataset/activity_labels.txt", quote="\"", comment.char="") ##labels for activity
measures <- read.table("~/coursera/UCI HAR Dataset/features.txt", quote="\"", comment.char="") ## labels for measures
test.subject <- read.table("~/coursera/UCI HAR Dataset/test/subject_test.txt", quote="\"", comment.char="") ## test subject IDs
test.vals <- read.table("~/coursera/UCI HAR Dataset/test/X_test.txt", quote="\"", comment.char="") ## readings for test set
test.act <- read.table("~/coursera/UCI HAR Dataset/test/y_test.txt", quote="\"", comment.char="")  ##activity for test set
train.subject <- read.table("~/coursera/UCI HAR Dataset/train/subject_train.txt", quote="\"", comment.char="") ## train subject IDs
train.vals <- read.table("~/coursera/UCI HAR Dataset/train/X_train.txt", quote="\"", comment.char="") ##readings for train set
train.act <- read.table("~/coursera/UCI HAR Dataset/train/y_train.txt", quote="\"", comment.char="") ##activity for train set

## create test data frame with measures, activity and subjects
test.df <- data.frame(test.subject, test.act, test.vals)

## create train data frame with measures, activity and subjects
train.df <- data.frame(train.subject, train.act, train.vals)

## combine dataframes 
combined.df <- rbind(train.df, test.df)

## rename column headers 

meas <- as.character(measures[,2]) ## creates a list of measure names
colnames(combined.df) <-c("subject", "actvity", unlist(meas))

##select only those columns with mean and std values

mean <- grepl("mean()", names(combined.df))
sd <- grepl("std()", names(combined.df))

## subset data frame

tmp1 <- combined.df[, mean]
tmp2 <- combined.df[, sd]
tmp3 <- combined.df[, 1:2]

##recombine

tidydf <- data.frame(tmp3, tmp1, tmp2)

## recode activity variable to act.labels

tidydf$activity[tidydf$activity == 1] <- "walking"
tidydf$activity[tidydf$activity == 2] <- "walking_upstairs"
tidydf$activity[tidydf$activity == 3] <- "walking_downstairs"
tidydf$activity[tidydf$activity == 4] <- "sitting"
tidydf$activity[tidydf$activity == 5] <- "standing"
tidydf$activity[tidydf$activity == 6] <- "laying"

## convert to long format using gather from the tidyr package

library(tidyr)
t1<-gather(tidydf, "measure", "values", 3:81)

## export the tidy dataset

write.table(t1, file = "astidy1.txt", row.names = TRUE)

## create means for each subgroup
library(dplyr)
t2 <- t1 %>% group_by(subject, activity, measure) %>% summarise(mean(values))

## write table for submission

write.table(t2, file = "tidy_final.txt", row.names = FALSE)

