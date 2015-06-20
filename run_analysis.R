# analysis script for data cleansing project
library(data.table)
library(dplyr)

# This code will do the following as per assignment:
#1-Merges the training and the test sets to create one data set.
#2-Extracts only the measurements on the mean and standard deviation for each measurement. 
#3-Uses descriptive activity names to name the activities in the data set
#4-Appropriately labels the data set with descriptive variable names. 
#5-From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


#first the features, common for test and training
features <- data.table(read.table(file = "../UCI HAR Dataset/features.txt", col.names = c("feature.num","feature.name")))
activity.names <- data.table(read.table(file = "../UCI HAR Dataset/activity_labels.txt", col.names = c("activity.id","activity.name")))

# the test data
# fread won't read becaue of initial spaces
subject.test <- data.table(read.table(file =  "../UCI HAR Dataset/test/subject_test.txt", col.names = "subject", header = FALSE))
activity.test <- data.table(read.table(file = "../UCI HAR Dataset/test/y_test.txt", col.names = "activity.id", header = FALSE))
# note col.names for #r in assignment
measure.test <- data.table(read.table(file = "../UCI HAR Dataset/test/X_test.txt", 
                                      col.names = features$feature.name, header = FALSE))

#train data
subject.train <- data.table(read.table(file =  "../UCI HAR Dataset/train/subject_train.txt", col.names = "subject", header = FALSE))
activity.train <- data.table(read.table(file = "../UCI HAR Dataset/train/y_train.txt", col.names = "activity.id", header = FALSE))
# note col.names for #4 in assignment
measure.train <- data.table(read.table(file = "../UCI HAR Dataset/train/X_train.txt", 
                                      col.names = features$feature.name, header = FALSE))


#setkeys for joins
setkey(activity.names,"activity.id")
setkey(activity.test,"activity.id")
setkey(activity.train,"activity.id")

#combine all of the various tables
# note that activity.names joined with activity.test for #3 in assignment
combined.test <- cbind(subject.test,activity.names[activity.test],measure.test)
combined.train <- cbind(subject.train,activity.names[activity.train],measure.train)

# filter out just the columns that I need for #2 in assignment
columns.I.need <- grep('activity.name|subject|mean|std',names(combined.test))

#combine test and train
# this is for assignment step #1
combined <- rbind(combined.test, combined.train)
final.raw.data <- combined[,columns.I.need,with=FALSE]

# for step 5 create tidy average data set
# I will use dplyr
final.tidy.data <- final.raw.data %>% group_by(subject, activity.name) %>% summarise_each(funs(mean))
write.table(final.tidy.data, file = "final-tidy-data.txt", row.names = FALSE)
