require("tm")
require("plyr")
require("class")


#Option so R doesn't convert string to factors.
options(stringAsFactors = FALSE)

reviews <- c("positive.data", "negative.data")
path <- "/home/andrea/Documents/usb/inteligencia/sentiment-classification/data/divided/"



processedData <- function(dataSet) {

    data <- tm_map(dataSet, removePunctuation)
    data <- tm_map(data, removeNumbers)
    data <- tm_map(data, stemDocument)
    data <- tm_map(data, removeWords, stopwords("english"))
    data <- tm_map(data, content_transformer(tolower))
    data <- tm_map(data, stripWhitespace)
    return (data)
}


readFile <- function(path,fileName) {

    inputFile <- file(paste(path,fileName,sep=""), open="r")

    dataList <- list()

    while(length(currentLine <- readLines(inputFile, n=1, warn=FALSE)) > 0) {
        
        #Removes HTML tags.
        line <- gsub("<.*?>", "", currentLine)
        dataList <- c(dataList, c=line)
    }
    close(inputFile)
    return (dataList)
}



termDocumentMatrix <- function(reviews, path) {
    data <- Corpus(VectorSource(readFile(path,reviews)))
    cleanedData <- processedData(data)
    tdMatrix <- TermDocumentMatrix(cleanedData)
    # tdMatrix <- removeSparseTerms(tdMatrix,0.8)
    result <- list(name = reviews, tdm = tdMatrix)
}

tdm <- lapply(reviews,termDocumentMatrix, path = path)

bindTDM <- function(tdm) {

    matrix <- t(data.matrix(tdm[["tdm"]]))
    dataFrame <- as.data.frame(matrix, stringsAsFactors = FALSE)
    dataFrame <- cbind(dataFrame, rep(tdm[["name"]], nrow(dataFrame))) 
    colnames(dataFrame)[ncol(dataFrame)] <- "Target"
    return (dataFrame)
}

reviewTDM <- lapply(tdm, bindTDM)
tdmStack <- do.call(rbind.fill, reviewTDM)
tdmStack[is.na (tdmStack)] <- 0

getRandomSets <- function(reviewTDM) {
    trainSet <- sample(nrow(reviewTDM),ceiling(nrow(reviewTDM) * 0.8))
    testSet <- (1:nrow(reviewTDM)) [-trainSet]
    return (list(trainSet,testSet))
}

sets <- lapply(reviewTDM, getRandomSets)

positiveTrainSet <- sets[[1]][[1]]
positiveTestSet <- sets[[1]][[2]]

sizePositive <- nrow(reviewTDM[[1]]["Target"])

negativeTrainSet <- sapply(sets[[2]][[1]],function(x) sum(x,sizePositive))
negativeTestSet <- sapply(sets[[2]][[2]],function(x) sum(x,sizePositive))


trainSet <- c(positiveTrainSet,negativeTrainSet)
testSet <- c(positiveTestSet,negativeTestSet)

# # KNN

reviewsClass <- tdmStack[,"Target"]
reviewsWithoutTarget <- tdmStack[, !colnames(tdmStack) %in% "Target"]


classifyKnn <- knn(reviewsWithoutTarget[trainSet, ], reviewsWithoutTarget[testSet,], reviewsClass[trainSet])
confusionMatrix <- table("Predictions" = classifyKnn, Actual = reviewsClass[testSet])


accuracy <- (sum(diag(confusionMatrix)) / length(testSet)) * 100

print (accuracy)
print (confusionMatrix)