library(e1071)
source("clean.r")

# Reads the data positive and negative reviews.
dataPath = "../data/divided/"
positivePath <- paste(dataPath, "outputPositive.csv", sep="")
negativePath <- paste(dataPath, "outputNegative.csv", sep="")
positiveData <- read.table(positivePath, header=TRUE, sep=",")
negativeData <- read.table(negativePath, header=TRUE, sep=",")

# Determines the training and testing sets for the positive reviews.
posIndex     <- 1:nrow(positiveData)
posTestIndex <- sample(posIndex, trunc(length(posIndex)/3.5))
posTestSet   <- positiveData[posTestIndex,]
posTrainSet  <- positiveData[-posTestIndex,]

# Determines the training and testing sets for the negative reviews.
negIndex     <- 1:nrow(negativeData)
negTestIndex <- sample(negIndex, trunc(length(negIndex)/3.5))
negTestSet   <- negativeData[negTestIndex,]
negTrainSet  <- negativeData[-negTestIndex,]

# Merges both positive and negative training and testing sets.
mergedTrainSet <- rbind(posTrainSet,negTrainSet)
mergedTestSet  <- rbind(posTestSet, negTestSet)

# Randomizes the order of the data.
trainSet <- mergedTrainSet[sample(nrow(mergedTrainSet)),]
testSet  <- mergedTestSet[sample(nrow(mergedTestSet)),]

# Sets the SVM model.
svmModel <- svm(class ~ ., data = trainSet, gamma = 0.75, cost = 2)
# print(summary(svmModel))

# Predicts the class for each example of the testing set.
prediction <- predict(svmModel, testSet[-2])

# Calculates confusion matrix.
confusionMatrix <- table(pred = prediction, true = testSet[,2])

size <- nrow(testSet)

# Tuning of data to determine the best values for each parameter.
# svmTune <- tune.svm(class ~ ., data=trainSet, cost = c(1,2,3,4),
#                     kernel= "radial", gamma= c(0.25,0.5,0.75,1,2,3))
# print(svmTune)