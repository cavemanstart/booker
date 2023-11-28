import numpy as np
from pymongo import MongoClient

from .config import mongo_connction_string


HISTORY_LENGTH = 100

def process_user_history_features():
    dbClient = MongoClient(mongo_connction_string)
    booker = dbClient["booker"]

    dbUsers = booker["UsersData"]
    dbUserCollections = booker["UserCollections"]
    dbBookTagFeatures = booker["BookTagFeatures"]

    users = dbUsers.find()
    print("Compute User History Features:")
    dbUserHistoryFeatures = booker["UserHistoryFeatures"]
    dbUserHistoryFeatures.drop()

    for user in users:
        print("get history feature:", user["uid"])
        ucs = dbUserCollections.find({"uid": user["uid"]}).sort("addTime",-1).limit(HISTORY_LENGTH)
        history_vectors = list()
        for elem in ucs:
            tagFeature = dbBookTagFeatures.find_one({"id": elem["bid"]})["feature"]
            history_vectors.append(np.array(tagFeature))
        if len(history_vectors) == 0:
            feature = np.zeros(100)
        else:
            feature = np.mean(history_vectors, axis=0).tolist()

        dbUserHistoryFeatures.insert_one({
            "uid": user["uid"],
            "feature": feature
        })
