import numpy as np
from pymongo import MongoClient

from .config import mongo_connction_string


def process_user_tag_features():
    dbClient = MongoClient(mongo_connction_string)
    booker = dbClient["booker"]

    users = booker["UsersData"]

    users = users.find()

    tagVectors = booker["TagVectors"]

    userTagFeatures = booker["UserTagFeatures"]

    userTagFeatures.drop()

    feature_list = list()

    # Convert user features
    for user in users:
        print("Do user tag feature task:", user["uid"])
        vectors = list()
        for favor in user["favors"]:
            vectors.append(np.array(tagVectors.find_one({"tag": favor})["vector"]))

        if len(vectors) == 0:
            vectors.append(np.zeros(100))
        vector_array = np.array(vectors)
        feature = np.mean(vector_array, axis=0).tolist()

        feature_list.append({
            "uid": user["uid"],
            "feature": feature
        })

    userTagFeatures.insert_many(feature_list)
