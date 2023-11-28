import random

import numpy as np

from database import redis_client
from database import getCollections
from sort_model import predict, set_config, MODEL_BASE_PATH

RECOMMEND_NUM = 50
RECALL_NUM = 100


def cold_startup(uid: int, favor_tags: str) -> list:
    db_recommend_results = getCollections("RecommendResults")
    db_tag_sim_results = getCollections("TagSimResults")
    if favor_tags is not None:
        favor_tags = ''.join(favor_tags)
        favor_tags = favor_tags.split("|")
    tag_sim_results = db_tag_sim_results.find({"tag": {"$in": favor_tags}})
    recommend_list = list()
    for elem in tag_sim_results:
        recommend_list = recommend_list + elem["recall"]
    recommend_list = [elem["bookId"] for elem in recommend_list]
    recommend_results = db_recommend_results.find_one({"uid": uid})
    if recommend_results is not None:
        recommend_results = recommend_results["result"]
        recommend_list = list(set(recommend_list + recommend_results))
    random.shuffle(recommend_list)
    if len(recommend_list) > RECOMMEND_NUM:
        recommend_list = recommend_list[:RECOMMEND_NUM]
    return recommend_list


def offline_recall(uid: int) -> list:
    db_favor_sim_results = getCollections("FavorSimResults")
    db_history_sim_results = getCollections("HistorySimResults")

    favor_sim_results = db_favor_sim_results.find_one({"userid": uid})
    if favor_sim_results is None:
        favor_sim_results = list()
    else:
        favor_sim_results = favor_sim_results["recall"]
    favor_sim_results = [elem["bookId"] for elem in favor_sim_results]

    history_sim_results = db_history_sim_results.find_one({"userid": uid})
    if history_sim_results is None:
        history_sim_results = list()
    else:
        history_sim_results = history_sim_results["recall"]
    history_sim_results = [elem["bookId"] for elem in history_sim_results]

    sim_results = favor_sim_results + history_sim_results

    return sim_results


def recommend_by_features(uid: int, user_feature, recall_list) -> list:
    db_recommend_results = getCollections("RecommendResults")
    db_book_features = getCollections("BookFeatures")

    recommend_results = db_recommend_results.find_one({"uid": uid})
    if recommend_results is not None:
        recommend_list = recommend_results["result"]
        recommend_list = list(set(recommend_list + recall_list))
    else:
        recommend_list = list(set(recall_list))

    if len(recommend_list) > RECALL_NUM:
        random.shuffle(recommend_list)
        recommend_list = recommend_list[:RECALL_NUM]

    inputs = list()
    book_features = db_book_features.find({"id": {"$in": recommend_list}})
    for elem in book_features:
        inputs.append(np.concatenate([elem["feature"], user_feature["feature"]]))

    inputs = np.array(inputs, dtype="float32")
    active_model =  redis_client.get("active-model")
    if active_model is not None:
        config = set_config(f'{MODEL_BASE_PATH}/{active_model}/{active_model}.pdmodel',
                                f'{MODEL_BASE_PATH}/{active_model}/{active_model}.pdiparams')
        results = predict(inputs, config)

        results = [{
            "id": recommend_list[i],
            "similarity": results[i]
        } for i in range(0, len(results))]
        results.sort(key=lambda elem: elem["similarity"])

        if len(results) > RECOMMEND_NUM:
            results = results[:RECOMMEND_NUM]
        recommend_list = [elem["id"] for elem in results]
    else:
        raise AttributeError("active-model is None")

    return recommend_list


def personal_recommend(uid: int, favor_tags=None):
    db_recommend_results = getCollections("RecommendResults")
    db_user_features = getCollections("UserFeatures")

    user_feature = db_user_features.find_one({"uid": uid})
    if user_feature is not None:
        recall_list = offline_recall(uid)
        if len(recall_list) == 0:
            if favor_tags is not None and len(favor_tags) != 0:
                recommend_list = cold_startup(uid, favor_tags)
            else:
                return None
        else:
            recommend_list = recommend_by_features(uid, user_feature, recall_list)
    else:
        if favor_tags is not None and len(favor_tags) != 0:
            recommend_list = cold_startup(uid, favor_tags)
        else:
            return None

    if len(recommend_list) != 0:
        db_recommend_results.update_one({"uid": uid}, {
            "$set": {
                "result": recommend_list
            }
        }, upsert=True)

    return recommend_list


def high_score_recommend() -> list:
    db_books_data = getCollections("BooksData")

    results = db_books_data.aggregate([
        {"$lookup": {
            "localField": "id",
            "from": "UserCollections",
            "foreignField": "bid",
            "as": "info"
        }
        },
        {'$unwind': {
            'path': "$info",
            'preserveNullAndEmptyArrays': True}
        },
        {'$group': {
                '_id': "$id",
                'avg': {'$avg': "$info.score"}
            }
        },
        {"$sort": {"avg": -1}},
        {"$limit": 250},
        {'$project':
                {
                    "mean": "$avg",
                }
        }, ])
    results = [elem["_id"] for elem in results]
    random.shuffle(results)
    if len(results) > RECOMMEND_NUM:
        results = results[:RECOMMEND_NUM]
    return results


def high_degree_recommend() -> list:
    db_books_data = getCollections("BooksData")

    results = db_books_data.find().sort("degree", -1).limit(250)
    results = [elem["id"] for elem in results]
    random.shuffle(results)
    if len(results) > RECOMMEND_NUM:
        results = results[:RECOMMEND_NUM]
    return results
