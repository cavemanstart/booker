from gensim.models import word2vec
from pymongo import MongoClient

from utils import readBookAndTagsData, parseTagsString
from .config import mongo_connction_string


def train(datafile, save_path):
    sentences = list()
    rows = readBookAndTagsData(datafile)
    maxLength = 0
    for row in rows:
        sentence = parseTagsString(row["tags"])
        if len(sentence) > maxLength:
            maxLength = len(sentence)
        sentences.append(sentence)
    model = word2vec.Word2Vec(sentences, hs=1, min_count=15, window=maxLength)
    model.save(save_path + "/tags2vec.model")
    words_vectors = model.wv
    words_vectors.save_word2vec_format(save_path + "/tags_vectors.bin", binary=True)
    return words_vectors


def saveToMongo(words_vectors):
    count = 1
    # save tag vectors to mongo
    dbClient = MongoClient(mongo_connction_string)
    booker = dbClient["booker"]
    booker["TagVectors"].drop()
    for word in words_vectors.index_to_key:
        print("Do work word:", count, word)
        count += 1
        t2v = {
            "tag": word,
            "vector": words_vectors[word].tolist()
        }
        if booker["TagVectors"].find_one({"tag": word}) is None:
            booker["TagVectors"].insert_one(t2v)


def process_tags2vec(books_data_path, save_path):
    tags_vectors = train(books_data_path, save_path)
    saveToMongo(tags_vectors)
