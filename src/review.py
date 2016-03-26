import requests
import xml.etree.ElementTree as ET
import time
import os
import csv

key = 'HGmnXC4msdSA8LNb7ejQ'
secret = '8oSbMVVrHxKDZblIpjR7xwqsPcbdyRO3zS8FRfBiRQ'
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
    
def getReviewsList():

    reviewsList = []
    IDdict = []
    folder = "original/"

    for fileName in os.listdir(dataFolder+folder):

        f = open(os.path.join(dataFolder+folder, fileName), "r")
        
        # print fileName
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

    folder = "individual/"

    for fileName in os.listdir(dataFolder+folder):

        f = open(os.path.join(dataFolder+folder, fileName), "r")
        
        # print fileName
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

# getRecentReviews()
reviewsList = getReviewsList()
printReviews2(reviewsList)
printReviews(reviewsList)

# 377358643,1548502321,746865698,
# 1569055692,1577315128,1566245477,
# 1561843533,1451748576,1542175171,
# 1583310336,1582974384,1360072687,
# 1063773072,1059502467,1059483839,
# 21231663,1251967947,1189419307,
# 1183458732,941508925

# idList = [34309215,7478942,5589709,
#         5546013,158864113,154964194,
#         1555369413,1532353051,1349125869,
#         1282950057,1272048203,1237177100,
#         1166760739,1166755502,1166746044,
#         1249888450,1179687088,1167379055,
#         1166730306,1112477094,1112477073,
#         1523827452,1468886860,1516634386,
#         1495482218,1176243792,1127079191,
#         491009615,513898435,67396109,
#         52797224,40925132,38067634,
#         18037183,15702592,10834229,
#         7601879,6442362,6184434,
#         6101314,6069952,723058380,
#         42000372,40375436,37196743,
#         21622303,9627988,8218815,
# #         42614989]


# idList = [1583101020,1416674989,1560541347,
#         1278970311,850881820,35272288,
#         737606973,363645711,188642096,
#         64059313,1397645608,22779567,
#         115912781,281408391,281408391,
#         657546617,549733504]
# for id in idList:
#     getReview(id)
