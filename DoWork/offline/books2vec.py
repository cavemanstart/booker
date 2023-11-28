import numpy as np
from gensim.models import KeyedVectors
from pymongo import MongoClient
from sklearn.metrics.pairwise import cosine_similarity

from utils import readBookAndTagsData, parseTagsString
from .config import mongo_connction_string

VECTOR_DIMS = 100
RECALL_NUM = 1000


def process_books2vec(tags_vector_path, books_data_path):
    dbClient = MongoClient(mongo_connction_string)
    booker = dbClient["booker"]

    bookTagFeature = booker["BookTagFeatures"]

    bookTagFeature.drop()

    tags_vectors = KeyedVectors.load_word2vec_format(tags_vector_path, binary=True)

    books_list = list()

    books_id = list()
    books_matrix = list()

    rows = readBookAndTagsData(books_data_path)
    count = 0
    for row in rows:
        print(count, "Do work:", row["id"])
        tags = parseTagsString(row["tags"])
        vectors = list()
        for tag in tags:
            try:
                vector = tags_vectors[tag]
            except Exception:
                continue
            vectors.append(vector)

        if len(vectors) == 0:
            feature = np.zeros(VECTOR_DIMS).tolist()
        else:
            vectors_array = np.array(vectors)
            feature = vectors_array.mean(axis=0).tolist()

        books_list.append({
            "id": row["id"],
            "feature": feature
        })
        books_matrix.append(feature)
        books_id.append(row["id"])
        count += 1

    books_matrix = np.array(books_matrix)

    bookTagFeature.insert_many(books_list)

    # compute BookSimResults
    bookSimResults = booker["BookSimResults"]
    bookSimResults.drop()

    print("tough task starts!")

    results = cosine_similarity(books_matrix, books_matrix)

    print("computation task done")

    print(len(results))
    for i in range(0, len(results)):
        print(i, "save task:")
        simResults = list()
        for j in range(0, len(results)):
            simResults.append({
                "yid": books_id[j],
                "similarity": float(results[i, j])
            })
        simResults.sort(key=lambda elem: elem["similarity"], reverse=True)

        bookSimResults.insert_one({
            "xid": books_id[i],
            "recall": simResults[:RECALL_NUM]
        })
    bookSimResults.create_index({'xid':1}, unique = True)
    print("done!")
