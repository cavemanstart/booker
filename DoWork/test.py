import multiprocessing

from database import redis_client
from service import RealTimeRecommend,OnlineTrain,BooksDataCollectProcess,UsersDataCollectProcess
import os

model_lock = multiprocessing.Lock()

if __name__ == '__main__':
    tester = OnlineTrain(model_lock)
    tester.process_message("update",1234,9787301316979,5)