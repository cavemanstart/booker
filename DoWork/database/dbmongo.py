from pymongo import MongoClient

def getdbBooker():
    dbClient = MongoClient("mongodb://172.31.225.73:27017/",connect=False)
    admin = dbClient["admin"]
    booker = dbClient["booker"]
    admin.authenticate("bookerAdmin","123456")
    return booker

def closeDB(dbClient):
    dbClient.close()

def getCollections(collection:str):
    booker = getdbBooker()
    return booker[collection]