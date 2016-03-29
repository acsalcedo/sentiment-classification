library(maxent)
source("clean.r")

# Reads data from file where all reviews are stored.
data <- read.csv(file="../data/divided/withNeutral.csv")
dataSize   <- nrow(data)

corpus <- Corpus(VectorSource(data$review[1:dataSize]))
matrix <- DocumentTermMatrix(corpus)

sparse <- as.compressed.matrix(matrix)

# Training set which contains 70% of the data.
trainIndex    <- 1502
trainSet      <- sparse[1:trainIndex,]
trainSetClass <- data$class[1:trainIndex]

# Test set which has the leftover 30%.
testSet <- sparse[trainIndex:dataSize,]

# Calculates max entropy model.
model <- maxent(trainSet,trainSetClass)

# Classifies test set given the max entropy model.
classifiedTestSet <- predict(model,testSet)

getCount <- function(results) {

    positives <- 0
    negatives <- 0

    i <- 1
    resultSize <- nrow(results)
    
    while (i <= resultSize) {
        
        if (results[i,2] > 0.5) {
            positives <- positives + 1
        } else {
            negatives <- negatives + 1
        }

        i <- i + 1
    }
    
    result <- matrix(c(positives,negatives),ncol=2,byrow=TRUE)
    colnames(result) <- c("positive","negative")
    
    result <- as.table(result)
    return (result)
}

count <- getCount(classifiedTestSet)
print(count)
size <- nrow(testSet)