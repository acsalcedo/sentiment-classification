
args <- commandArgs(trailingOnly = TRUE)
folder <- ""

if (length(args) < 1) {
    argumentErrors()
}

algorithm <- args[1]

if (algorithm == 1) {
    print ("k-Nearest Neighbors Algorithm")
    folder <- "../results/knn/"
} else if (algorithm == 2) {
    print ("Support Vector Machines")
    folder <- "../results/svm/"
} else if (algorithm == 3) {
    print ("Maximum Entropy Classifier")
    folder <- "../results/maxent/"
}

fileNames <- list.files(folder, pattern="*.RData", full.names=TRUE)

cat("\nNumber of results:", length(fileNames), "\n")

totalTruePositive  <- 0
totalFalsePositive <- 0
totalTrueNegative  <- 0
totalFalseNegative <- 0
totalSize <- 0

for (file in fileNames) {

    load(file=file)

    totalTruePositive  <- totalTruePositive  + confusionMatrix[1]
    totalFalsePositive <- totalFalsePositive + confusionMatrix[3]
    totalTrueNegative  <- totalTrueNegative  + confusionMatrix[4]
    totalFalseNegative <- totalFalseNegative + confusionMatrix[2]
    totalSize <- totalSize + size
}

accuracy <- ((totalTruePositive + totalTrueNegative) / totalSize) * 100
precision <- (totalTruePositive / (totalTruePositive + totalFalsePositive)) * 100
recall    <- (totalTruePositive / (totalTruePositive + totalFalseNegative)) * 100
specificity <- (totalTrueNegative / (totalFalsePositive + totalTrueNegative)) * 100

cat("\n------------------RESULTS------------------\n\n")
cat("Accuracy:", accuracy, "\n")
cat("Precision:", precision, "\n")
cat("Recall:", recall, "\n")
cat("Specificity:", specificity, "\n")
cat("\n-------------------------------------------\n")