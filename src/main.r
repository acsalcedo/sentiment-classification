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
        dataList <- c(dataList, c=currentLine)
    }
    close(inputFile)
    return (dataList)
}



termDocumentMatrix <- function(reviews, path) {
    data <- Corpus(VectorSource(readFile(path,reviews)))
    cleanedData <- processedData(data)
    tdMatrix <- TermDocumentMatrix(cleanedData)

    #TODO - Ver como funciona linea por linea
    # tdMatrix <- removeSparseTerms(tdMatrix,0.6)
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


# #TODO Quizas no es necesario
tdmStack <- do.call(rbind.fill, reviewTDM)
tdmStack[is.na (tdmStack)] <- 0
# reviewTDM[is.na (reviewTDM)] <- 0



getSample <- function(reviewTDM) {
    trainingSet <- sample(nrow(reviewTDM),ceiling(nrow(reviewTDM) * 0.8))
    return (trainingSet)
}

train <- lapply(reviewTDM, getSample)

trainSet <- unlist(train,recursive=FALSE)

# trainingSet <- sample(nrow(tdmStack),ceiling(nrow(tdmStack) * 0.7))
testSet <- (1:nrow(tdmStack)) [- trainSet]


# KNN

tdmReview <- tdmStack[,"Target"]
tdmReviewWithoutTarget <- tdmStack[, !colnames(tdmStack) %in% "Target"]


classifyKnn <- knn(tdmReviewWithoutTarget[trainingSet, ], tdmReviewWithoutTarget[testSet,], tdmReview[trainingSet])

confusionMatrix <- table("Predictions" = classifyKnn, Actual = tdmReview[testSet])


(accuracy <- sum(diag(confusionMatrix)) / length(testSet) * 100)


