import datetime
import json
import logging
from json import JSONDecodeError
from multiprocessing import Process

import pika

from database import getCollections


class BooksDataCollectProcess(Process):
    queue_name = "booksData"
    hostname = '39.103.210.93'
    credentials = pika.PlainCredentials('admin', '123456')
    port = 5672

    def __init__(self, model_lock):
        super().__init__()
        self.model_lock = model_lock

    def update_books_data(self, bid, tags,degree):
        db_books_data = getCollections("BooksData")
        db_books_data.update_one({"id": bid}, {
            "$set": {
                "tags": tags,
                "degree":degree
            }
        })


    def process_message(self, bid, tags,degree):
        self.update_books_data(bid, tags,degree)
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
            bid = msg["bid"]
            tags = msg["tags"]
            degree = msg["degree"]
            try:
                self.process_message(bid, tags,degree)
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
            logging.log(logging.WARNING, "stop collecting books data")
