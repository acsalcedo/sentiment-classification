stopQuietly <- function() {
    blankMsg <- sprintf("\r%s\r", paste(rep(" ", getOption("width")-1L), collapse=" "));
    stop(simpleError(blankMsg));
}

argumentErrors <- function() {
    cat("\nIncorrect call. Please try again.\n")
    cat("\n$ Rscript <algorithm>")
    cat("\n\nAlgorithm:")
    cat("\n\t1 -> k-Nearest Neighbors")
    cat("\n\t2 -> Support Vector Machines")   
    cat("\n\t3 -> Maximum Entropy Classifier")
    cat("\n")
    stopQuietly()
}

main <- function() {

    args <- commandArgs(trailingOnly = TRUE)
    folder <- ""

    if (length(args) < 1) {
        argumentErrors()
    }

    algorithm <- args[1]

    if (algorithm == 1) {
        print ("k-Nearest Neighbors Algorithm")
        folder <- "../results/knn/"
        source("knn.r")
    } else if (algorithm == 2) {
        print ("Support Vector Machines")
        folder <- "../results/svm/"
        source("svm.r")
    } else if (algorithm == 3) {
        print ("Maximum Entropy Classifier")
        folder <- "../results/maxent/"
        source("maxent.r")
    } else {
        argumentErrors()
    }

    printResults <- function(confusionMatrix) {
        truePositive <- confusionMatrix[1]
        falsePositive <- confusionMatrix[3]
        trueNegative <- confusionMatrix[4]
        falseNegative <- confusionMatrix[2]

        accuracy <- (sum(diag(confusionMatrix)) / size) * 100
        precision <- (truePositive / (truePositive + falsePositive)) * 100
        recall    <- (truePositive / (truePositive + falseNegative)) * 100
        specificity <- (trueNegative / (falsePositive + trueNegative)) * 100

        cat("\n------------------RESULTS------------------\n")
        cat("\nConfusion Matrix\n")
        print(confusionMatrix)
        cat("\n")
        cat("Accuracy:", accuracy, "\n")
        cat("Precision:", precision, "\n")
        cat("Recall:", recall, "\n")
        cat("Specificity:", specificity, "\n")
        cat("\n-------------------------------------------\n")

    }
    printResults(confusionMatrix)

    now <- Sys.time()
    fileName <- paste(folder,format(now, "%Y%m%d%H%M%S"), "_data.RData", sep="")
    save(list=c("confusionMatrix","size"), file=fileName)
}

main()
