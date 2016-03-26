library("tm")
library("plyr")
library("class")
source("clean.r")

#Option so R doesn't convert string to factors.
options(stringAsFactors = FALSE)

reviews <- c("positive.data", "negative.data")
path <- "../data/divided/"


termDocumentMatrix <- function(reviews, path) {
    preProcessedData <- getPreProcessedData(reviews,path)
    tdMatrix         <- TermDocumentMatrix(preProcessedData)
    # tdMatrix <- removeSparseTerms(tdMatrix,0.8)
    result           <- list(name = reviews, tdm = tdMatrix)
}

tdm <- lapply(reviews,termDocumentMatrix, path = path)

bindTDM <- function(tdm) {

    matrix    <- t(data.matrix(tdm[["tdm"]]))
    dataFrame <- as.data.frame(matrix, stringsAsFactors = FALSE)
    dataFrame <- cbind(dataFrame, rep(tdm[["name"]], nrow(dataFrame))) 
    
    colnames(dataFrame)[ncol(dataFrame)] <- "Target"
    return (dataFrame)
}

reviewTDM <- lapply(tdm, bindTDM)
tdmStack  <- do.call(rbind.fill, reviewTDM)
tdmStack[is.na (tdmStack)] <- 0

getRandomSets <- function(reviewTDM) {
    trainSet <- sample(nrow(reviewTDM),ceiling(nrow(reviewTDM) * 0.7))
    testSet  <- (1:nrow(reviewTDM)) [-trainSet]
    return (list(trainSet,testSet))
}

sets <- lapply(reviewTDM, getRandomSets)

positiveTrainSet <- sets[[1]][[1]]
positiveTestSet  <- sets[[1]][[2]]

sizePositive <- nrow(reviewTDM[[1]]["Target"])

negativeTrainSet <- sapply(sets[[2]][[1]],function(x) sum(x,sizePositive))
negativeTestSet  <- sapply(sets[[2]][[2]],function(x) sum(x,sizePositive))

trainSet <- c(positiveTrainSet,negativeTrainSet)
testSet  <- c(positiveTestSet,negativeTestSet)

reviewsClass         <- tdmStack[,"Target"]
reviewsWithoutTarget <- tdmStack[, !colnames(tdmStack) %in% "Target"]

# # KNN
classifyKnn     <- knn(reviewsWithoutTarget[trainSet, ], reviewsWithoutTarget[testSet,], reviewsClass[trainSet])
confusionMatrix <- table("Predictions" = classifyKnn, Actual = reviewsClass[testSet])

size <- length(testSet)