###### COURSERA: GETTING AND CLEANING DATA - COURSE PROJECT ######

## The following code combines the files in the 
## UCI "Human Activity Recognition Using Smartphones" data set
## into one data frame. The mean and standard deviation measurements are extracted
## and the mean of each of these measurements for each activity
## and each subject is computed from the combined data frame and
## returned in an independent tidy data set.

### This script assumes two things:
### 1) You have the Samsung data in your working directory. If you don't have it, 
###   download it from here: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
### 2) You have the "reshape" and "plyr" packages installed.

### Load requisite libraries all of the raw data files from the working directory.
library(reshape)
library(plyr)

directory <- getwd()
X_train <- read.table(file.path(directory, "train/X_train.txt"), quote = "\"")
y_train <- read.table(file.path(directory, "train/y_train.txt"), quote = "\"")
subject_train <- read.table(file.path(directory, "train/subject_train.txt"), quote = "\"")
X_test <- read.table(file.path(directory, "test/X_test.txt"), quote = "\"")
y_test <- read.table(file.path(directory, "test/y_test.txt"), quote = "\"")
subject_test <- read.table(file.path(directory, "test/subject_test.txt"), quote = "\"")
activity_labels <- read.table(file.path(directory, "activity_labels.txt"), quote = "\"", col.names = c("activity_id", "activity_name"))
features <- read.table(file.path(directory, "features.txt"), quote = "\"")

### Combine the training and test data sets into one data frame.
train <- cbind(subject_train, y_train, X_train)
test <- cbind(subject_test, y_test, X_test)
combine <- rbind(train, test)
colnames(combine) <- c("subject_id","activity_id", as.character(features$V2))
combine <- merge(activity_labels, combine, by = "activity_id")

### Filter out signal measurement columns that are not mean or standard deviation measurements.
combine <- combine[, grep("activity_name|subject|std\\(\\)-|mean\\(\\)-", colnames(combine))]

### Transform the combined data frame into the final tidy data set and
### compute the mean and standard deviation from each signal variable measurement
### for each activity for each subject.
tidy <- melt(combine, id.vars = c("activity_name", "subject_id"), measure.vars = colnames(combine[3:50]))
tidy <- cast(tidy, subject_id + variable ~ activity_name, mean)

### Split the signal measurement column variables from original "signal-measurement-axis" format into three columns
### in order to keep only one variable in each column.
tidy <- cbind(tidy[, 1], ldply(strsplit(as.character(tidy$variable), "\\-")), tidy[, 3:8])
tidy$V2 <- sub("\\(\\)", "", tidy$V2)
colnames(tidy) <- c("SUBJECT_ID", "SIGNAL", "MEASUREMENT", "AXIS", paste(colnames(tidy[5:10]), "_MEAN", sep = ""))

### Write the final tidy data set to a file in the working directory.
write.table(tidy, file.path(directory, "tidySmartphoneData.txt"), sep = "\t", row.names = FALSE)

