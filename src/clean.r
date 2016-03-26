require("tm")
require("plyr")
require("class")


#Option so R doesn't convert string to factors.
options(stringAsFactors = FALSE)

reviews <- c("positive.data", "negative.data")
path = "../data/divided/"

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
    numReviews <- 87
    dataList <- list()

    while(length(currentLine <- readLines(inputFile, n=1, warn=FALSE)) > 0) {
        dataList <- c(dataList, c=currentLine)
        numReviews <- numReviews - 1
    }
    close(inputFile)
    return (dataList)
}



getCleanedData <- function(reviews, path) {
    data <- Corpus(VectorSource(readFile(path,reviews)))
    cleanedData <- processedData(data)
    return(cleanedData)
}

cleanedData <- lapply(reviews,getCleanedData, path = path)
 


columnNames <- c("review","class")

posLst <- cleanedData[[1]]$content
positiveFile = "../data/divided/outputPositive.csv"
negativeFile = "../data/divided/outputNegative.csv"
allFile = "../data/divided/all.csv"
cat(c("review","class"),file = positiveFile, fill=TRUE, sep=",")
cat(c("review","class"),file = negativeFile, fill=TRUE, sep=",")
cat(c("review","class"),file = allFile, fill=TRUE, sep=",")
for (review in posLst) {
    elem <- gsub("<.*?>", "", review)
    content <- paste((gsub("[\r\n\t]", "", elem)),"positive",sep=",")
    if (nchar(review$content) > 1) { 
        cat(content, file=positiveFile,fill=TRUE, append=TRUE, sep=",") 
        cat(content, file=allFile,fill=TRUE, append=TRUE, sep=",") 

    }
}

negLst <- cleanedData[[2]]$content
processedNeg <- list()
for (review in negLst) {
     elem <- gsub("<.*?>", "", review)
    content <- paste((gsub("[\r\n\t]", "", elem)),"negative",sep=",")
    if (nchar(review$content) > 1) {  
        cat(content, file=negativeFile, fill=TRUE, append=TRUE, sep=",") 
        cat(content, file=allFile,fill=TRUE, append=TRUE, sep=",") 
    }
}