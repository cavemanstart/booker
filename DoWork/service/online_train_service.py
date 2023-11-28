import datetime
import json
import logging
from json import JSONDecodeError
from multiprocessing import Process

import bson
import pika
from pymongo import MongoClient

from database import redis_client
from sort_model import FeaturesSet, MODEL_BASE_PATH
from sort_model.train import online_train, model_save


class OnlineTrain(Process):
    queue_name = "onlinetraining"
    hostname = '39.103.210.93'
    credentials = pika.PlainCredentials('admin', '123456')
    port = 5672

    USE_MODEL_1 = "sortModel-1"
    USE_MODEL_2 = "sortModel-2"

    BASIC_SCORE = 5
    TRAIN_DATA_NUM = 100


    def __init__(self, model_lock):
        super().__init__()
        self.model_lock = model_lock

    def update_user_collection(self, uid, bid, score):
        dbClient = MongoClient("mongodb://39.103.210.93:27017/", connect=False)
        admin = dbClient["admin"]

        booker = dbClient["booker"]
        admin.authenticate("bookerAdmin", "123456")
        db_user_collections = booker["UserCollections"]

        db_user_collections.update_one({"uid": uid, "bid": bid}, {
            "$set": {
                "score": score,
                "addTime": bson.Timestamp(int(datetime.datetime.now().timestamp()), 1)
            }
        }, upsert=True)

    def delete_user_collection(self, uid, bid):
        dbClient = MongoClient("mongodb://39.103.210.93:27017/", connect=False)
        admin = dbClient["admin"]

        booker = dbClient["booker"]
        admin.authenticate("bookerAdmin", "123456")
        db_user_collections = booker["UserCollections"]

        db_user_collections.delete_one({"uid": uid, "bid": bid})

    def process_message(self, command, uid, bid, score):
        dbClient = MongoClient("mongodb://39.103.210.93:27017/", connect=False)
        admin = dbClient["admin"]

        booker = dbClient["booker"]
        admin.authenticate("bookerAdmin", "123456")
        db_user_collections = booker["UserCollections"]

        if command == "update":
            self.update_user_collection(uid, bid, score)
        elif command == "delete":
            self.delete_user_collection(uid, bid)

        active_model = redis_client.get("active-model")
        if active_model is None:
            return
        features_collection = db_user_collections.aggregate([
            {"$lookup": {
                "localField": "bid",
                "from": "BookFeatures",
                "foreignField": "id",
                "as": "bookField"
            }
            },
            {"$unwind": {
                "path": "$bookField",
                "preserveNullAndEmptyArrays": False
            }
            },
            {
                "$sort": {
                    "addTime": -1
                }
            },
            {"$project": {
                "bookFeature": "$bookField.feature",
                "uid": "$uid",
                "score": "$score"
            }
            },
            {"$lookup": {
                "localField": "uid",
                "from": "UserFeatures",
                "foreignField": "uid",
                "as": "userField"
            }
            },
            {"$unwind": {
                "path": "$userField",
                "preserveNullAndEmptyArrays": False
            }
            },
            {"$limit": self.TRAIN_DATA_NUM},
            {"$project": {
                "bookFeature": "$bookFeature",
                "userFeature": "$userField.feature",
                "score": "$score"
            }
            },
        ])

        dataset = FeaturesSet()
        sum_score_cursor = list(db_user_collections.aggregate([{
            "$group": {
                "_id": None,
                "sumScore": {
                    "$sum": "$score"
                }
            }
        }]))
        sum_score = sum_score_cursor[0]["sumScore"]

        for elem in features_collection:
            score = elem["score"]
            label = score / sum_score
            dataset.add_online_data(elem["userFeature"], elem["bookFeature"], label)
        if len(dataset) == 0:
            return
        if active_model == self.USE_MODEL_1:
            train_model = self.USE_MODEL_2
        elif active_model == self.USE_MODEL_2:
            train_model = self.USE_MODEL_1
        else:
            raise AssertionError("redis crash: no active model found!")
        with self.model_lock:
            try:
                model = online_train(f"{MODEL_BASE_PATH}/{train_model}/{train_model}", dataset)
                model_save(model, f"{MODEL_BASE_PATH}/{train_model}/{train_model}")
                redis_client.set("active-model", train_model)
            except ValueError as e:
                print(e)
                return
            except Exception as exp:
                print(exp)

    def recv_message(self, ch, method, properties, body):
        headers = properties.headers
        command = ""
        try:
            command = headers["command"]
        except KeyError:
            return
        if body is not None:
            msg = body.decode("utf-8")
        else:
            return
        print(f"{datetime.datetime.now()}:Received {msg}")
        logging.log(logging.INFO, f"{datetime.datetime.now()}:Received {msg}")
        try:
            msg = json.loads(msg)
            uid = msg["uid"]
            bid = msg["bid"]
            if "score" in msg:
                score = int(msg["score"])
            else:
                score = self.BASIC_SCORE
            try:
                self.process_message(command, uid, bid, score)
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
            logging.log(logging.WARNING, "stop online training Service")
