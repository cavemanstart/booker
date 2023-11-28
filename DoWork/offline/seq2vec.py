import numpy as np
from gensim.models import word2vec
from pymongo import MongoClient

from .config import mongo_connction_string


def process_seq2vec(save_path):
    dbClient = MongoClient(mongo_connction_string)
    booker = dbClient["booker"]

    dbUsers = booker["UsersData"]
    dbUserCollections = booker["UserCollections"]

    users = dbUsers.find()

    print("Train book seq vectors")
    book_sequence = list()
    maxLength = 0
    for user in users:
        print("get sequence:", user["uid"])
        ucs = dbUserCollections.find({"uid": user["uid"]})
        bids = [elem["bid"] for elem in ucs]
        if maxLength < len(bids):
            maxLength = len(bids)
        book_sequence.append(bids)

    model = word2vec.Word2Vec(book_sequence, hs=1, min_count=1, window=maxLength)
    model.save(save_path + "/seq2vec.model")
    words_vectors = model.wv
    words_vectors.save_word2vec_format(save_path + "/bookSeq_vectors.bin", binary=True)

    dbBookSeqVectors = booker["BookSeqVectors"]
    dbBookSeqVectors.drop()

    for bid in words_vectors.index_to_key:
        print("saving vector:", bid)
        dbBookSeqVectors.insert_one({
            "id": bid,
            "vector": words_vectors[bid].tolist()
        })

    print("Compute userSeqFeatures")
    dbUserSeqFeatures = booker["UserSeqFeatures"]
    dbUserSeqFeatures.drop()

    users = dbUsers.find()
    for user in users:
        print("saving features:", user["uid"])
        vectors = list()
        for bid in words_vectors.index_to_key:
            vectors.append(words_vectors[bid])

        if len(vectors) != 0:
            vectors = np.array(vectors)
        else:
            vectors = np.zeros(100)
        feature = np.mean(vectors, axis=0).tolist()

        dbUserSeqFeatures.insert_one({
            "uid": user["uid"],
            "feature": feature
        })
