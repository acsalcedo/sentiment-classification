import requests
import xml.etree.ElementTree as ET
import time
import os
import csv

key = 'HGmnXC4msdSA8LNb7ejQ'
secret = '8oSbMVVrHxKDZblIpjR7xwqsPcbdyRO3zS8FRfBiRQ'
dataFolder = "../data/"

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


def getReviewsList():

    reviewsList = []
    IDdict = []
    folder = "original/"

    for fileName in os.listdir(dataFolder+folder):

        f = open(os.path.join(dataFolder+folder, fileName), "r")
        
        xml = f.read()
        root = ET.fromstring(xml)

        for r in root.iter('review'):

            id = r.find('id').text
            rating = int(r.find('rating').text)
            body = r.find('body').text
            
            review = Review(id,rating,body.encode('utf-8'))

            # if (rating == 3):
            #     print review 
            
            if not id in IDdict:
                reviewsList.append(review)
                IDdict.append(id)


    return reviewsList

def printReviews(reviewsList):


    positiveReviews = open(dataFolder+'divided/positive.data','w')
    negativeReviews = open(dataFolder+'divided/negative.data','w')
    neutralReviews = open(dataFolder+'divided/neutral.data','w')

    # f.close() 

    total = 0
    positive = 0
    negative = 0
    neutral = 0

    NUMREVIEWS = 8000

    for review in reviewsList:
        
        rating = review.rating
        body = review.body.rstrip()
        if (rating > 3 and positive < NUMREVIEWS):
            positiveReviews.write(body)
            positive += 1

        elif (rating == 3):
            neutralReviews.write(body)
            neutral += 1

        elif (rating < 3 and negative < NUMREVIEWS):
        # elif (rating < 3 and rating > 0 and negative < NUMREVIEWS):
            negativeReviews.write(body)
            negative += 1

        total += 1

    print "Total: %s, Positive: %s, Negative: %s, Neutral: %s" %(total,positive,negative,neutral)


def printReviews2(reviewsList):


    positiveReviews = open(dataFolder+'divided/positive.csv','w')
    negativeReviews = open(dataFolder+'divided/negative.csv','w')
    neutralReviews = open(dataFolder+'divided/neutral.csv','w')
    allReviews = open(dataFolder+'divided/all.csv','w')

    NUMREVIEWS = 8000
    # f.close() 

    fieldnames = ['review', 'class']
    posWriter = csv.DictWriter(positiveReviews, fieldnames=fieldnames)
    negWriter = csv.DictWriter(negativeReviews, fieldnames=fieldnames)
    neuWriter = csv.DictWriter(neutralReviews, fieldnames=fieldnames)
    posWriter.writeheader()
    negWriter.writeheader()

    total = 0
    positive = 0
    negative = 0
    neutral = 0


    for review in reviewsList:
        
        rating = review.rating
        body = review.body.rstrip()
        if (rating > 3 and positive < NUMREVIEWS):
            posWriter.writerow({'review': body, 'class': 'positive'})
            positive += 1

        elif (rating == 3):
            neuWriter.writerow({'review': body, 'class': 'negative'})
            neutral += 1

        # elif (rating < 3 and rating > 0 and negative < NUMREVIEWS):
        elif (rating < 3 and negative < NUMREVIEWS):
            negWriter.writerow({'review': body, 'class': 'negative'})
            negative += 1
            
        total += 1

    print "Total: %s, Positive: %s, Negative: %s, Neutral: %s" %(total,positive,negative,neutral)

getRecentReviews()
reviewsList = getReviewsList()
printReviews2(reviewsList)
printReviews(reviewsList)


