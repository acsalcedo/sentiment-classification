library(e1071)
library(rpart)

# Reads the data positive and negative reviews.
dataPath = "home/andrea/Documents/usb/inteligencia/sentiment-classification/data/divided/"
positivePath <- paste(path, "positive.csv", sep="")
negativePath <- paste(path, "negative.csv", sep="")
positiveData <- read.table(positivePath, header=TRUE,sep=",")
negativeData <- read.table(negativePath, header=TRUE,sep=",")

# Determines the training and testing sets for the positive reviews.
posIndex     <- 1:nrow(positiveData)
posTestIndex <- sample(posIndex, trunc(length(posIndex)/3))
posTestSet   <- positiveData[posTestIndex,]
posTrainSet  <- positiveData[-posTestIndex,]

# Determines the training and testing sets for the negative reviews.
negIndex     <- 1:nrow(negativeData)
negTestIndex <- sample(negIndex, trunc(length(negIndex)/3))
negTestSet   <- negativeData[negTestIndex,]
negTrainSet  <- negativeData[-negTestIndex,]

# Merges both positive and negative training and testing sets.
mergedTrainSet <- rbind(posTrainSet,negTrainSet)
mergedTestSet  <- rbind(posTestSet, negTestSet)

# Randomizes the order of the data.
trainSet <- mergedTrainSet[sample(nrow(mergedTrainSet)),]
testSet  <- mergedTestSet[sample(nrow(mergedTestSet)),]

# Sets the SVM model.
svmModel <- svm(class ~ ., data = trainSet, cost = 100, gamma = 1)

# Predicts the class for each example of the testing set.
prediction <- predict(svmModel, testSet[-2])

# Calculates confusion matrix.
confusionMatrix <- table(pred = prediction, true = testSet[,2])

# Calculates accuracy of the classification.
accuracy <- (sum(diag(confusionMatrix)) / nrow(testSet)) * 100

print(confusionMatrix)
print(accuracy)

# Tuning of data to determine the best values for each parameter.
svmTune <- tune.svm(class ~ ., data=trainSet, cost = 10^(-10:10),
                    kernel= "radial", gamma= c(0.01,0.05,0.25,0.5,1,1.5,2,3))
print(svmTune)


#kernel = linear, radial polynomial