library("tm")
options(stringAsFactors = FALSE)

reviews <- c("positive.data", "negative.data","neutral.data")
path = "../data/divided/"

preProcessData <- function(dataSet) {
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

getPreProcessedData <- function(reviews, path) {
    data        <- Corpus(VectorSource(readFile(path,reviews)))
    cleanedData <- preProcessData(data)
    return(cleanedData)
}

cleanedData = lapply(reviews,getPreProcessedData, path = path)

files = c("outputPositive.csv","outputNegative.csv","all.csv","neutral.csv")

addHeader <- function(fileName) {
    cat(c("review","class"),file = paste(path,fileName,sep=""), fill=TRUE, sep=",")
}

lapply(files,addHeader)

addContent <- function(fileName,contentList,classify) {

    for (review in contentList) {
        elem    <- gsub("<.*?>", "", review)
        content <- paste((gsub("[\r\n\t]", "", elem)),classify,sep=",")
        if (nchar(review$content) > 1) { 
            cat(content, file=fileName,fill=TRUE, append=TRUE, sep=",")
        }
    }
}

posList <- cleanedData[[1]]$content
negList <- cleanedData[[2]]$content
neuList <- cleanedData[[3]]$content

addContent(paste(path,files[1],sep=""),posList,"positive")
addContent(paste(path,files[2],sep=""),negList,"negative")

addContent(paste(path,files[3],sep=""),posList,"positive")
addContent(paste(path,files[3],sep=""),negList,"negative")

addContent(paste(path,files[4],sep=""),neuList,"neutral")
