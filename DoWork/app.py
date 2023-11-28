from enum import Enum
from typing import Optional

import uvicorn
import multiprocessing
from fastapi import FastAPI, HTTPException
from starlette.middleware.cors import CORSMiddleware
from starlette.middleware.gzip import GZipMiddleware

from service import personal_recommend, high_score_recommend, high_degree_recommend
from service import RealTimeRecommend
from service import OnlineTrain
from service import BooksDataCollectProcess
from service import UsersDataCollectProcess

model_lock = multiprocessing.Lock()

app = FastAPI()

origins = [
    "http://47.117.112.114:5000"
]

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# gzip
app.add_middleware(
    GZipMiddleware,
    minimum_size=500
)


class RecommendType(str, Enum):
    highRating = "highRating"
    personal = "personal"
    popular = "popular"

@app.get("/recommend/{type}")
def read_root(type:RecommendType,uid:Optional[int] = None,tags:Optional[str] = None):
    if type == RecommendType.highRating:
        res = high_score_recommend()
    elif type == RecommendType.popular:
        res = high_degree_recommend()
    elif type == RecommendType.personal:
        if uid is not None:
            if tags is not None:
                try:
                    with model_lock:
                        res = personal_recommend(uid,tags)
                except AttributeError as e:
                    print(e)
                    raise HTTPException(status_code=500,detail="redis active-model key error")
            else:
                try:
                    res = personal_recommend(uid)
                except AttributeError as e:
                    print(e)
                    raise HTTPException(status_code=500,detail="redis active-model key error")
        
            if res is None:
                raise HTTPException(status_code=400, detail="no tags specified with a new user")
        else:
            raise HTTPException(status_code=400, detail="uid can't be null")
    else:
        res = None
    return res



if __name__ == '__main__':
    realtime = RealTimeRecommend(model_lock)
    online_train = OnlineTrain(model_lock)
    collect_books_data = BooksDataCollectProcess(model_lock)
    collect_users_data = UsersDataCollectProcess(model_lock,"./data/misc/occupation.csv")

    realtime.start()
    online_train.start()
    collect_books_data.start()
    collect_users_data.start()

    uvicorn.run("app:app", host="0.0.0.0", port=9000)

    realtime.join()
    online_train.join()
    collect_books_data.join()
    collect_users_data.join()