import xml.etree.ElementTree as ET
import requests
import time
import os
import csv

key = #insert key 
secret = #insert secret
dataFolder = "../data/"
NUMREVIEWS = 5000

class Review:

    def __init__(self, id, rating, body):
        self.id = id
        self.rating = rating
        self.body = body

    def getId(self):
        return self.id

    def getRating(self):
        return self.rating

    def getBody(self):
        return self.body

    def __str__(self):
        return "Review object:\n ID: %s\n Rating: %s\n Body:%s" %(self.id,self.rating,self.body)

def getRecentReviews():
    
    timestr = time.strftime("%Y%m%d%H%M%S")
    fileName = "recentReviews_"
    extension = ".xml"
    folder = "original/"

    payload = {'key': key}
    response = requests.get("https://www.goodreads.com/review/recent_reviews.xml?", params=payload,stream=True)

    with open(dataFolder+folder+fileName+timestr+extension, "w") as reviewsFile:
        reviewsFile.write(response.content)

def getReview(id):

    extension = ".xml"
    folder = "individual/"

    payload = {'id': id, 'key': key}
    response = requests.get("https://www.goodreads.com/review/show.xml?", params=payload,stream=True)

    with open(dataFolder+folder+str(id)+extension, "w") as reviewsFile:
        reviewsFile.write(response.content)
    

def getReviewsList(folder):

    reviewsList = []
    IDdict = []

    for fileName in os.listdir(dataFolder+folder):

        f = open(os.path.join(dataFolder+folder, fileName), "r")
        
        xml = f.read()
        root = ET.fromstring(xml)

        for r in root.iter('review'):

            id = r.find('id').text
            rating = int(r.find('rating').text)
            body = r.find('body').text
            
            review = Review(id,rating,body.encode('utf-8'))

            if not id in IDdict:
                reviewsList.append(review)
                IDdict.append(id)

    return reviewsList

def getAllReviews():

    return getReviewsList("original/") + getReviewsList("individual/")

def printReviews(reviewsList):


    positiveReviews = open(dataFolder+'divided/positive.data','w')
    negativeReviews = open(dataFolder+'divided/negative.data','w')
    neutralReviews = open(dataFolder+'divided/neutral.data','w')

    total = 0
    positive = 0
    negative = 0
    neutral = 0

    for review in reviewsList:
        
        rating = review.rating
        body = review.body.rstrip()

        if (rating > 3):
            positiveReviews.write(body)
            positive += 1

        elif (rating == 3):
            neutralReviews.write(body)
            neutral += 1

        elif (rating < 3):
            negativeReviews.write(body)
            negative += 1

        total += 1

    positiveReviews.close()
    negativeReviews.close()
    neutralReviews.close()

    print "Total: %s, Positive: %s, Negative: %s, Neutral: %s" %(total,positive,negative,neutral)

# getRecentReviews()
reviewsList = getAllReviews()
printReviews(reviewsList)
