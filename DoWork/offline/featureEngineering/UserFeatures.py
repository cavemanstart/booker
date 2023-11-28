import numpy as np
import pandas as pd
from pymongo import MongoClient

from utils.utils import parseFeatureString
from ..config import mongo_connction_string


def process_user_features(users_data_path, user_history_features_path, user_seq_features_path, user_tag_features_path,
                          occupation_path):
    dbClient = MongoClient(mongo_connction_string)

    booker = dbClient["booker"]
    dbUserFeatures = booker["UserFeatures"]
    dbUserFeatures.drop()

    # Prepare for data
    usersData = pd.read_csv(users_data_path)
    userHistoryFeatures = pd.read_csv(user_history_features_path)
    userHistoryFeatures["feature"] = userHistoryFeatures["feature"].apply(
        lambda elem: np.array(parseFeatureString(elem), dtype="double"))

    userSeqFeatures = pd.read_csv(user_seq_features_path)
    userSeqFeatures["feature"] = userSeqFeatures["feature"].apply(
        lambda elem: np.array(parseFeatureString(elem), dtype="double"))

    userTagFeatures = pd.read_csv(user_tag_features_path)
    userTagFeatures["feature"] = userTagFeatures["feature"].apply(
        lambda elem: np.array(parseFeatureString(elem), dtype="double"))

    occupation = pd.read_csv(occupation_path)
    occupation_sum = occupation["id"].sum()

    occupation = {
        elem["occupation"]: elem["id"] / occupation_sum
        for index, elem in occupation.iterrows()
    }

    # Normalization to get basic features
    usersData["occupation"] = usersData["occupation"].apply(lambda elem: occupation[elem])

    age_sum = usersData["age"].sum()

    uid_sum = usersData["uid"].sum()

    for index, elem in usersData.iterrows():
        age_feature = elem["age"] / age_sum
        uid_feature = elem["uid"] / uid_sum
        occupation_feature = elem["occupation"]
        vector = np.array([
            age_feature,
            np.sqrt(age_feature),
            np.square(age_feature),
            0 if elem["gender"] == 'F' else 1,
            occupation_feature,
            np.sqrt(occupation_feature),
            np.square(occupation_feature),
            uid_feature,
            np.sqrt(uid_feature),
            np.square(uid_feature)
        ], dtype="double")
        history_feature = userHistoryFeatures[userHistoryFeatures["uid"] == elem["uid"]]["feature"].mean()
        tag_feature = userTagFeatures[userTagFeatures["uid"] == elem["uid"]]["feature"].mean()
        seq_feature = userSeqFeatures[userSeqFeatures["uid"] == elem["uid"]]["feature"].mean()
        vector = np.concatenate([vector, history_feature, tag_feature, seq_feature], axis=0)

        dbUserFeatures.insert_one({
            "uid": elem["uid"],
            "feature": vector.tolist()
        })
