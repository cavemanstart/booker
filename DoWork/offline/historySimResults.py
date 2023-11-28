import random

import numpy as np
import pandas as pd
from pymongo import MongoClient
from sklearn.metrics.pairwise import cosine_similarity

from .config import mongo_connction_string

FIRST_RECALL_NUM = 500
SECOND_RECALL_NUM = 250
LAST_RECALL_NUM = 100


def process_history_sim_results(books_data_path):
    dbClient = MongoClient(mongo_connction_string)
    booker = dbClient["booker"]

    pdBooksData = pd.read_csv(books_data_path)
    booksData = pd.DataFrame()
    booksData["id"] = pdBooksData["id"]
    booksData["degree"] = pdBooksData["degree"]

    dbUserHistoryFeatures = booker["UserHistoryFeatures"]
    dbBookTagFeatures = booker["BookTagFeatures"]

    userHistoryfeatures = dbUserHistoryFeatures.find()

    dbHistorySimResults = booker["HistorySimResults"]
    dbHistorySimResults.drop()

    print("Reading user history features")
    user_id = list()
    user_features = list()
    for elem in userHistoryfeatures:
        print("uid:", elem["uid"])
        user_id.append(elem["uid"])
        user_features.append(elem["feature"])

    print("reading book tag features")
    bookTagFeatures = dbBookTagFeatures.find()
    book_id = list()
    book_features = list()
    for elem in bookTagFeatures:
        print("bookId:", elem["id"])
        book_id.append(elem["id"])
        book_features.append(elem["feature"])

    book_features = np.array(book_features)

    print("Compute task started!")
    results = cosine_similarity(user_features, book_features)
    print("Compute task done!")

    print(len(results))
    for i in range(0, len(results)):
        print(i, "save task:")
        simResults = list()
        for j in range(0, len(results[i])):
            print(j, "Recalling..")
            simResults.append({
                "bookId": book_id[j],
                "similarity": float(results[i, j]),
                "degree": float(booksData.where(booksData["id"] == book_id[j])["degree"].iloc[j])
            })
        simResults.sort(key=lambda elem: elem["similarity"], reverse=True)
        simResults = simResults[:FIRST_RECALL_NUM]
        simResults.sort(key=lambda elem: elem["degree"], reverse=True)
        simResults = simResults[:SECOND_RECALL_NUM]
        random.shuffle(simResults)
        dbHistorySimResults.insert_one({
            "userid": user_id[i],
            "recall": simResults[:LAST_RECALL_NUM]
        })

    print("done!")
