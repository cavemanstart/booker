from string import punctuation

import jieba
import numpy as np
import pandas as pd
from pymongo import MongoClient

from utils.utils import parseFeatureString, publishTimeToTimestamp
from ..config import mongo_connction_string


def process_book_features(books_data_path, book_tag_features_path):
    dbClient = MongoClient(mongo_connction_string)
    booker = dbClient["booker"]
    dbBookFeatures = booker["BookFeatures"]
    dbBookFeatures.drop()

    # Prepare for data
    booksData = pd.read_csv(books_data_path)
    booksData["publishTime"] = booksData["publishTime"].apply(publishTimeToTimestamp)
    publisherTable = dict()
    publisherGroup = booksData.groupby("publisher")

    count = 1
    for name, groups in publisherGroup:
        publisherTable[name] = count
        count += 1

    def encodePublisher(publisher):
        if not pd.isna(publisher):
            return publisherTable[publisher]
        else:
            return 0

    booksData["publisher"] = booksData["publisher"].apply(encodePublisher)

    wordList = list()
    my_punctuation = punctuation + "，。、（）¥'：。."

    def splitTitle(title):
        if not pd.isna(title):
            for p in my_punctuation:
                title = title.replace(p, "").strip()
            words = jieba.lcut(title)
            wordList.extend(words)
            return words
        else:
            return list()

    booksData["title"] = booksData["title"].apply(splitTitle)
    booksData["subtitle"] = booksData["subtitle"].apply(splitTitle)

    wordList = set(wordList)
    wordTableLen = len(wordList)
    titleWordTable = dict()
    count = 1
    for word in wordList:
        titleWordTable[word] = count / wordTableLen
        count += 1

    maxLength = 0

    def catTitle(row):
        global maxLength
        title = row["title"]
        subtitle = row["subtitle"]

        full_title = title + subtitle

        if len(full_title) > maxLength:
            maxLength = len(full_title)
        return full_title

    booksData["fullTitle"] = booksData.apply(catTitle, axis=1)

    FULL_TITLE_DIM = maxLength + 1

    def encodeTitle(full_title):
        if len(full_title) == 0:
            return np.zeros(FULL_TITLE_DIM)
        else:
            vector = [titleWordTable[elem] for elem in full_title]
            padding = FULL_TITLE_DIM - len(vector)
            vector.extend(np.zeros(padding))
            return np.array(vector)

    booksData["encodeTitle"] = booksData["fullTitle"].apply(encodeTitle)

    id_sum = booksData["id"].sum()

    degree_sum = booksData["degree"].sum()
    booksData["degree"] = booksData["degree"].apply(lambda cell: cell / degree_sum)

    publishTime_sum = booksData["publishTime"].sum()
    booksData["publishTime"] = booksData["publishTime"].apply(lambda cell: cell / publishTime_sum)

    publisher_sum = booksData["publisher"].sum()
    booksData["publisher"] = booksData["publisher"].apply(lambda cell: cell / publisher_sum)

    bookTagFeatures = pd.read_csv(book_tag_features_path)
    bookTagFeatures["feature"] = bookTagFeatures["feature"].apply(
        lambda elem: np.array(parseFeatureString(elem), dtype="double"))

    for index, elem in booksData.iterrows():
        print("doing feature concat:", index)
        vector = np.array([
            elem["id"] / id_sum,
            np.square(elem["id"] / id_sum),
            elem["degree"],
            np.sqrt(elem["degree"]),
            np.square(elem["degree"]),
            elem["publishTime"],
            np.square(elem["publishTime"]),
            elem["publisher"],
            np.sqrt(elem["publisher"]),
            np.square(elem["publisher"]),

        ])
        encode_title = elem["encodeTitle"]
        tag_feature = bookTagFeatures[bookTagFeatures["id"] == elem["id"]]["feature"].mean()
        feature = np.concatenate([vector, encode_title, tag_feature], axis=0)
        dbBookFeatures.insert_one({
            "id": elem["id"],
            "feature": feature.tolist()
        })
