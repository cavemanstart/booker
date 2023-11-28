import datetime
import json
import logging
import random
from json import JSONDecodeError
from multiprocessing import Process

import numpy as np
import pika
from database import redis_client,getCollections
from service.recommend_service import MODEL_BASE_PATH
from sort_model import set_config, predict


class RealTimeRecommend(Process):
    USER_BASIC_FEATURE_DIM = 10
    USER_HISTORY_FEATURE_DIM = 100
    USER_TAG_FEATURE_DIM = 100
    USER_SEQ_FEATURE_DIM = 100
    queue_name = "realtime"
    hostname = '39.103.210.93'
    credentials = pika.PlainCredentials('admin', '123456')
    HISTORY_LENGTH = 20
    port = 5672
    RECALL_NUM = 250
    UPDATE_NUM = 20
    RECOMMEND_NUM = 50
    def __init__(self, model_lock):
        super().__init__()
        self.model_lock = model_lock

    def process_message(self, uid, bid):
        db_book_features = getCollections("BookFeatures")
        db_book_sim_results = getCollections("BookSimResults")
        db_book_tag_features = getCollections("BookTagFeatures")
        db_recommend_results = getCollections("RecommendResults")
        db_user_features = getCollections("UserFeatures")

        print(f"{datetime.datetime.now()}:Process realtime recommend", uid, bid)
        active_model = redis_client.get("active-model")
        if active_model is  None:
            return

        recall_list = db_book_sim_results.find_one({"xid":bid})
        if recall_list is not None:
            recall = recall_list["recall"]
            history = redis_client.lrange(uid,0,self.HISTORY_LENGTH)
            if history is not None:
                user_feature = db_user_features.find_one({"uid": uid})
                if user_feature is not None:
                    user_feature = user_feature["feature"]
                    history = [int(elem) for elem in history]
                    recall = [elem["yid"] for elem in recall]
                    recall = list(set(history+recall))
                    random.shuffle(recall)
                    if len(recall) > self.RECALL_NUM:
                        recall = recall[:self.RECALL_NUM]

                    book_tag_features = db_book_tag_features.find({"id":{"$in":history}})
                    features = list()
                    for feature in book_tag_features:
                        features.append(feature["feature"])
                    if len(features) != 0:
                        user_history_feature = np.mean(features, axis=0)
                        user_feature[
                        self.USER_BASIC_FEATURE_DIM:self.USER_BASIC_FEATURE_DIM + self.USER_HISTORY_FEATURE_DIM] = user_history_feature.tolist()

                    user_feature = np.array(user_feature)
                    book_features = db_book_features.find({"id": {"$in": recall}})

                    inputs = list()
                    for book in book_features:
                        inputs.append(np.concatenate([book["feature"], np.array(user_feature)]))
                    inputs = np.array(inputs, dtype="float32")
                    with self.model_lock:
                        config = set_config(f'{MODEL_BASE_PATH}/{active_model}/{active_model}.pdmodel',
                                            f'{MODEL_BASE_PATH}/{active_model}/{active_model}.pdiparams')
                        try:
                            results = predict(inputs, config)
                        except Exception:
                            return
                    results = [{
                        "id": recall[i],
                        "similarity": results[i]
                    } for i in range(0, len(results))]
                    results.sort(key=lambda elem: elem["similarity"])
                    if len(recall) > self.UPDATE_NUM:
                        results = results[:self.UPDATE_NUM]

                    results = [elem["id"] for elem in results]

                    recommend_list = db_recommend_results.find_one({"uid":uid})
                    if recommend_list is not None:
                        recommend_list = recommend_list["result"]
                        recommend_list = list(set(recommend_list+results))
                        if len(recommend_list)>self.RECOMMEND_NUM:
                            recommend_list = recommend_list[:self.RECOMMEND_NUM]

                        if len(recommend_list) != 0:
                            db_recommend_results.update_one({"uid": uid}, {
                                "$set": {
                                    "result": recommend_list
                                }
                            }, upsert=True)

                if len(history) >= self.HISTORY_LENGTH:
                    redis_client.delete(uid)
                redis_client.lpush(uid,bid)

    def recv_message(self, ch, method, properties, body):
        if body is not None:
            msg = body.decode("utf-8")
        else:
            return
        print(f"{datetime.datetime.now()}:Received {msg}")
        logging.log(logging.INFO,f"{datetime.datetime.now()}:Received {msg}")
        try:
            msg = json.loads(msg)
            uid = msg["uid"]
            bid = msg["bid"]
            try:
                self.process_message(uid, bid)
            except Exception as e:
                print(e)
                return
        except JSONDecodeError:
            return
        except TypeError:
            return
        except KeyError:
            return


    def run(self) -> None:
        connection = pika.BlockingConnection(pika.ConnectionParameters(
            host=self.hostname, port=self.port, virtual_host='/', credentials=self.credentials))

        channel = connection.channel()
        channel.queue_declare(queue=self.queue_name, durable=True)

        channel.basic_qos(prefetch_count=1)
        try:
            channel.basic_consume(
                on_message_callback=self.recv_message,
                queue=self.queue_name,
                auto_ack=True
            )
            channel.start_consuming()
        except KeyboardInterrupt:
            channel.stop_consuming()
        finally:
            channel.stop_consuming()
            logging.log(logging.WARNING,"stop Realtime Recommend Service")
