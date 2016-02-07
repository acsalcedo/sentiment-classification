import requests
import xml.etree.ElementTree as ET
import time
import os

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

    payload = {'key': key}
    response = requests.get("https://www.goodreads.com/review/recent_reviews.xml?", params=payload,stream=True)

    with open(dataFolder+fileName+timestr+extension, "w") as reviewsFile:
        reviewsFile.write(response.content)


def getReviewsList():

    reviewsList = []

    for fileName in os.listdir(dataFolder):

        f = open(os.path.join(dataFolder, fileName), "r")
        
        xml = f.read()
        root = ET.fromstring(xml)

        for r in root.iter('review'):

            id = r.find('id').text
            rating = r.find('rating').text
            body = r.find('body').text
            
            review = Review(id,rating,body.encode('utf-8'))
            
            reviewsList.append(review)

    return reviewsList

def printReviews(reviewsList):

    for review in reviewsList:
        print review


getRecentReviews()
reviewsList = getReviewsList()
printReviews(reviewsList)


