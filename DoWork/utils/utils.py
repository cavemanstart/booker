import datetime

import pandas as pd
import numpy as np

# "['a','b','c']" -> ['a','b','c']:list
def parseTagsString(tags: str) -> list:
    tags = "".join(tags.split())
    return tags.replace('"', '')[1:-1].split(",")

def parseFeatureString(feature:str)->list:
    feature = "".join(feature.split())
    return feature[1:-1].split(",")

def readBookAndTagsData(datafile):
    booksDataDf = pd.read_csv(datafile)

    booksAndtags = pd.DataFrame()

    booksAndtags["id"] = booksDataDf["id"]
    booksAndtags["tags"] = booksDataDf["tags"]

    rows = [row.to_dict() for index, row in booksAndtags.iterrows()]
    return rows

def publishTimeToTimestamp(time):
    if not pd.isna(time):
        index = time.find("T")
        time = time[:index]
        time = datetime.datetime.strptime(time,"%Y-%m-%d")
        return time.timestamp()
    else:
        return 0

def splitTrainAndVal(path, tranin_rate = 0.8):
    data = pd.read_csv(path)

    data_num = len(data)
    train_num = int(np.ceil(data_num*tranin_rate))
    val_num = data_num - train_num

    train_data = data[:train_num]
    if val_num <= 0:
        val_data = data[:train_num]
    else:
        val_data = data[train_num:]

    return train_data,val_data