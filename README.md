Getting and Cleaning Data - Course Project ReadMe
=================================================
This guide is intended to provide a concise overview of how the `run_analysis.R` script in this repo works. The first purpose of this script is to explain how the separate data files in the "Human Activity Recognition Using Smartphones Data Set" from the UCI Machine Learning Repository located [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) are combined into one data set. The second purpose is to explain how the final tidy data set is derived and the choices made in determining the variables for that data set.

The following files from the raw data set are used in `run_analysis.R`:
* activity_labels.txt
* features.txt
* train/subject_train.txt
* train/X_train.txt
* train/y_train.txt
* test/subject_test.txt
* test/X_test.txt
* test/y_test.txt

The variable choices made for the tidy data set are based on the information provided in features_info.txt from the raw data [.zip file](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) and from the [UCI website](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

__NOTE:__ The script and this ReadMe assumes the following:
* You have the `reshape` and `plyr` packages installed.
* You have unzipped the raw data in your working directory.

## Combining the raw data files.
The data files were combined based on the size of their dimensions. The files in the /train and /test subfolders have the same number of rows (respectively), so they were bound together by column into `train` and `test` data frames:
```
train <- cbind(subject_train, y_train, X_train)
test <- cbind(subject_test, y_test, X_test)
```
The `train` and `test` data frames were combined into one data frame by row because they have an equal number of columns:
```
combine <- rbind(train, test)
```
Column names are applied from features.txt and a more descriptive variable is applied for each activity from activity_labels.txt:
```
colnames(combine) <- c("subject_id","activity_id", as.character(features$V2))
combine <- merge(activity_labels, combine, by = "activity_id")
```
The UCI team estimated many different variables for each signal in the raw data, however we are only interested in the mean and standard deviation estimates for our tidy data set. Any variables that do not contain the `mean()-` or `std()-` labels are filtered out of the combined data frame:
```
combine <- combine[, grep("activity_name|subject|std\\(\\)-|mean\\(\\)-", colnames(combine))]
```

## Creating the tidy data set.
First the combined data frame is melted so that it can be re-cast to meet the specifications of the assignment.
```
tidy <- melt(combine, id.vars = c("activity_name", "subject_id"), measure.vars = colnames(combine[3:50]))
```
The cast function is used to aggregate the molten data and reshape it such that the average of the mean and standard deviation signal measurements for each activity and each subject are returned.
```
tidy <- cast(tidy, subject_id + variable ~ activity_name, mean)
```
Tidy data has only one variable in each column. In features_info.txt the creators of the raw data list the features such that the three major components of each feature are separated by a "-" character. For example, `fBodyAcc-mean()-X` contains the following information:
* A Fast Fourier Transform (denoted by the lower case 'f' prefix) was applied to the Body Acceleration signal.
* The mean value was estimated from the signal.
* This is a measurement of the X axis.


This is a lot of information to include in one column. The final data set to be used in further analyses should be as easy to work with as possible. It may be helpful to be able to easily subset the data based on a certain axis or signal alone, so this single column is parsed out on the "-" character and separated into three individual columns. A full explanation of what each variable represents can be found in features_info.txt.
```
tidy <- cbind(tidy[, 1], ldply(strsplit(as.character(tidy$variable), "\\-")), tidy[, 3:8])
```
Finally, unnecessary characters are stripped from the new variables and more meaningful column names are applied. The column names are based on the feature descriptions in features_info.txt. The string "_MEAN" is appended to each activity to make it more clear that this column represents the mean value of the signal computed from the raw data.
```
tidy$V2 <- sub("\\(\\)", "", tidy$V2)
colnames(tidy) <- c("SUBJECT_ID", "SIGNAL", "MEASUREMENT", "AXIS", paste(colnames(tidy[5:10]), "_MEAN", sep = ""))
```
Last but not least, the output file is generated in the working directory.
```
write.table(tidy, file.path(directory, "tidySmartphoneData.txt"), sep = "\t", row.names = FALSE)
```

