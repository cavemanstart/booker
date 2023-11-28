import random

import numpy as np
import pandas as pd
from pymongo import MongoClient
from sklearn.metrics.pairwise import cosine_similarity

from .config import mongo_connction_string

FIRST_RECALL_NUM = 500
SECOND_RECALL_NUM = 250
LAST_RECALL_NUM = 200


def process_tag_sim_results(books_data_path, cold_tag_path):
    dbClient = MongoClient(mongo_connction_string)
    booker = dbClient["booker"]

    pdBooksData = pd.read_csv(books_data_path)
    booksData = pd.DataFrame()
    booksData["id"] = pdBooksData["id"]
    booksData["degree"] = pdBooksData["degree"]

    # %%
    tagSimResults = booker["TagSimResults"]
    tagSimResults.drop()

    dbTagVectors = booker["TagVectors"]

    tags = list()
    print("reading tag vectors")
    with open(cold_tag_path) as tagsFile:
        lines = tagsFile.readlines()
        for line in lines:
            tags.append(line.strip())

    tag_vectors = list()
    for elem in tags:
        print("tag:", elem)
        tag_vectors.append(dbTagVectors.find_one({"tag": elem})["vector"])

    tag_features = np.array(tag_vectors)

    dbBookTagFeatures = booker["BookTagFeatures"]
    bookTagFeatures = dbBookTagFeatures.find()

    print("reading book tag features")
    book_id = list()
    book_features = list()
    for elem in bookTagFeatures:
        print("bookId:", elem["id"])
        book_id.append(elem["id"])
        book_features.append(elem["feature"])

    book_features = np.array(book_features)

    print("Compute task started!")
    results = cosine_similarity(tag_features, book_features)
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
        tagSimResults.insert_one({
            "tag": tags[i],
            "recall": simResults[:LAST_RECALL_NUM]
        })

    print("done!")
