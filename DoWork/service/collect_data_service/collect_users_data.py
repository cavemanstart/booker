import datetime
import json
import logging
from json import JSONDecodeError
from multiprocessing import Process

import numpy as np
import pandas as pd
import pika

from database import getCollections

class UsersDataCollectProcess(Process):
    USER_BASIC_FEATURE_DIM = 10
    USER_HISTORY_FEATURE_DIM = 100
    USER_TAG_FEATURE_DIM = 100
    USER_SEQ_FEATURE_DIM = 100

    queue_name = "usersData"
    hostname = '39.103.210.93'
    credentials = pika.PlainCredentials('admin', '123456')
    port = 5672

    def __init__(self, model_lock, occupation_path):
        super().__init__()
        self.model_lock = model_lock
        occupation = pd.read_csv(occupation_path)
        occupation_sum = occupation["id"].sum()

        self.occupation_table = {
            elem["occupation"]: elem["id"] / occupation_sum
            for index, elem in occupation.iterrows()
        }

    def update_users_data(self, uid, age, favors, gender, occupation):
        db_users_data = getCollections("UsersData")
        db_users_data.update_one({"uid": uid}, {
            "$set": {
                "age": age,
                "favors": favors,
                "gender": gender,
                "occupation": occupation
            }
        }, upsert=True)

    def calc_user_feature(self, uid, age, favors, gender, occupation):
        db_tag_vectors = getCollections("TagVectors")
        db_user_features = getCollections("UserFeatures")
        db_users_data = getCollections("UsersData")
        tag_vectors = list(db_tag_vectors.find({"tag": {"$in": favors}}))
        try:
            tag_vectors = [np.array(elem["vector"], dtype="double") for elem in tag_vectors]
            tag_vectors = np.array(tag_vectors)
            user_tag_feature = np.mean(tag_vectors, axis=0)
        except Exception:
            user_tag_feature = np.zeros(100)

        uid_sum = list(db_users_data.aggregate([{
            "$group": {
                "_id": None,
                "uidSum": {
                    "$sum": "$uid"
                }
            }
        }]))
        uid_sum = uid_sum[0]["uidSum"]
        age_sum = list(db_users_data.aggregate([{
            "$group": {
                "_id": None,
                "ageSum": {
                    "$sum": "$age"
                }
            }
        }]))
        age_sum = age_sum[0]["ageSum"]

        age_feature = age / age_sum
        uid_feature = uid / uid_sum
        occupation_feature = self.occupation_table[occupation]
        vector = np.array([
            age_feature,
            np.sqrt(age_feature),
            np.square(age_feature),
            0 if gender == 'F' else 1,
            occupation_feature,
            np.sqrt(occupation_feature),
            np.square(occupation_feature),
            uid_feature,
            np.sqrt(uid_feature),
            np.square(uid_feature)
        ], dtype="double")
        vector = np.concatenate([vector, np.zeros(self.USER_HISTORY_FEATURE_DIM),
                                 user_tag_feature, np.zeros(self.USER_SEQ_FEATURE_DIM)], axis=0)
        db_user_features.update_one({"uid":uid},{
            "$set":{
                "feature":vector.tolist()
            }
        },upsert=True)

    def process_message(self, uid, age, favors, gender, occupation):
        try:
            self.update_users_data(uid, age, favors, gender, occupation)
            self.calc_user_feature(uid, age, favors, gender, occupation)
        except Exception as e:
            print(e)
        pass

    def recv_message(self, ch, method, properties, body):
        if body is not None:
            msg = body.decode("utf-8")
        else:
            return
        print(f"{datetime.datetime.now()}:Received {msg}")
        logging.log(logging.INFO, f"{datetime.datetime.now()}:Received {msg}")
        try:
            msg = json.loads(msg)
            uid = msg["uid"]
            age = msg["age"]
            favors = msg["favors"]
            gender = msg["gender"]
            occupation = msg["occupation"]
            try:
                self.process_message(uid, age, favors, gender, occupation)
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
            logging.log(logging.WARNING, "stop collecting users data")
