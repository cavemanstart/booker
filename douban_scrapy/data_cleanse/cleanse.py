import logging

import pandas as pd
from pymongo import MongoClient

dbClient = MongoClient("mongodb://39.103.210.93:27017/")
db = dbClient["booker"]

def delete_duplicate(collection):
    db[collection].aggregate([
        {'$group': {
            '_id': "$id",
            'uniqueIds': {'$addToSet': "$_id"},
            'count': {'$sum': 1}
        }
        },
        {'$match': {
            'count': {'$gt': 1}
        }
        }, {'$out': collection+"Temp"}
    ], allowDiskUse=True)

    deleteData=db[collection+"Temp"].find()

    counter = 1
    for elem in deleteData:
        print("epoch:",counter)
        first=True
        for id in elem['uniqueIds']:
            if first==False:
                db[collection].delete_one({'_id':id})
            first=False
        counter+=1
    db[collection+"Temp"].drop()

def save_data_to_csv(filename:str, collection:str, project:dict):
    rough = []
    collection = db[collection].find({}, project)
    for elem in collection:
        print("id:"+str(elem['id']))
        rough.append(elem)
    df =  pd.DataFrame(rough)

    df.to_csv(filename)

def read_and_rename(filename:str):
    df = pd.read_csv(filename)
    labels = ["index","oid"]
    labels.extend(df.columns[2:])
    df.columns = labels
    print(len(df))
    print(df.columns)
    return df

def parse_list(list_str:str)->list:
    raw_list = list()
    if list_str:
        raw_list = list_str[1:-1].split(", ")
    if len(raw_list)!=0:
        return [elem[1:-1] for elem in raw_list]
    else:
        return raw_list

if __name__ == '__main__':
#   delete_duplicate("BooksMisc")
#   save_data_to_csv("../data/Books.csv","Books",{"image":0})
    pass

