library(maxent)
source("clean.r")

# Reads data from file where all reviews are stored.
data <- read.csv(file="../data/divided/all.csv")

# Sorts data in random order so not all 
# positive and negative reviews are together.
sortedData <- data[sample(nrow(data)),]
dataSize   <- nrow(sortedData)

corpus <- Corpus(VectorSource(sortedData$review[1:dataSize]))
matrix <- DocumentTermMatrix(corpus)

sparse <- as.compressed.matrix(matrix)

# Training set which contains 70% of the data.
trainIndex    <- ceiling(0.7*dataSize)
trainSet      <- sparse[1:trainIndex,]
trainSetClass <- sortedData$class[1:trainIndex]

# Test set which has the leftover 30%.
testSet <- sparse[trainIndex:dataSize,]

# Calculates max entropy model.
model <- maxent(trainSet,trainSetClass)

# Classifies test set given the max entropy model.
classifiedTestSet <- predict(model,testSet)

getConfusionMatrix <- function(results) {

    posAsPos <- 0
    posAsNeg <- 0
    negAsNeg <- 0
    negAsPos <- 0
    i <- 1
    resultSize <- nrow(results)
    
    while (i <= resultSize) {
        
        if (results[[i,1]] == "positive") {
            if (results[i,2] > 0.5) {
                posAsPos <- posAsPos + 1
            } else {
                posAsNeg <- posAsNeg + 1
            }
        } else {
            if (results[[i,3]] > 0.5) {
                negAsNeg <- negAsNeg + 1
            } else {
                negAsPos <- negAsPos + 1
            }    
        }
        i <- i + 1
    }
    result <- matrix(c(posAsPos,posAsNeg,negAsPos,negAsNeg),ncol=2,byrow=TRUE)
    
    colnames(result) <- c("positive","negative")
    rownames(result) <- c("positive","negative")
    
    result <- as.table(result)
    return (result)
}

confusionMatrix <- getConfusionMatrix(classifiedTestSet)
size <- nrow(testSet)