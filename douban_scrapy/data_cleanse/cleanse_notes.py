import datetime
import re

import wordninja

from cleanse import *

"""
This notes cleanse the Books Data.
"""

#%%
#read Books data and drop nan id rows to convert id type to int
df = read_and_rename("../data/Books.csv")
df = df.drop(labels=["index"],axis=1)
df = df.dropna(subset=["id"])
df = df.dropna(subset=["title"])
df["id"] = df["id"].astype("int")

#%%
# handle subtitle column
subtitles = df["subtitle"]
def cut_en_word(item):
    if not pd.isna(item):
        words = wordninja.split(item)
        if len(words) != 0:
            if not words[0].isdigit() or not words[-1].isdigit():
                return " ".join(words)

    return item
# fix subtitle English sentences
subtitles = subtitles.apply(cut_en_word)
df["subtitle"] = subtitles



#%%
#pubTimes = df["publishTime"]
# decide which row to delete
#def validate_pubdate(elem):
#    if not pd.isna(elem):
#        if re.match(".+?-.+?-.+?",elem) or re.match(".+?-.+?",elem) or re.match(r"^[0-9]*$",elem):
#            return False
#        return True
#    else:
#        return False
#
## drop rows that do not match "1-1-1" or "1-1" or "1" pattern
#df = df.drop(df[pubTimes.apply(validate_pubdate)].index)

#%%
# publish time unified
# rows that do not match "1-1-1" or "1-1" or "1" pattern:set None
pubTimes = df["publishTime"]
def unify_pubdate(elem):
    if not pd.isna(elem):
        if re.match(".+?-.+?-.+?",elem):
            try:
                trans_date =  datetime.datetime.strptime(elem,"%Y-%m-%d").date()
            except ValueError:
                trans_date = None
        elif re.match(".+?-.+?",elem):
            try:
                trans_date =  datetime.datetime.strptime(elem+"-1","%Y-%m-%d").date()
            except ValueError:
                trans_date = None
        else:
            try:
                trans_date =  datetime.datetime.strptime(elem+"-1-1","%Y-%m-%d").date()
            except ValueError:
                trans_date = None
        return trans_date
    return None

df["publishTime"] = pubTimes.apply(unify_pubdate)

#%%
# valid pageNum formats: 14 or 14页 or 14頁
pageNums = df["pageNum"]
def validate_pageNum(elem):
    if re.match(r"^[0-9]*$",elem):
        return False
    else:
        if elem[-1] == "页" or elem[-1] =="頁":
            return False
        return True

temp = pageNums[pageNums.apply(validate_pageNum)]


#%%
# unify pageNum column
def unify_pageNum(elem):
    if not pd.isna(elem):
        if elem[-1] == "页" or elem[-1] == "頁":
            try:
                num = int(elem[:-1])
            except Exception:
                num = 0
        else:
            try:
                num = int(elem)
            except Exception:
                num = 0
        return num
    return 0

df["pageNum"] = pageNums.apply(unify_pageNum)

#%%
rows = [row.to_dict() for index,row in df.iterrows()]

#%%
# write result to database
def trans_property(property):
   return property if not pd.isna(property) else None

for row in rows:
    print("saving:",row["id"])
    pubTime = row["publishTime"]
    if pubTime:
        pubTime = datetime.datetime(pubTime.year,pubTime.month,pubTime.day,0,0,0)
    bookData = {
        "id":row["id"],
        "title":row["title"],
        "subtitle": trans_property(row["subtitle"]),
        "author":trans_property(row["author"]),
        "publisher":trans_property(row["publisher"]),
        "publishTime":pubTime,
        "pageNum":trans_property(row["pageNum"]),
        "price":trans_property(row["price"]),
        "initDegree":trans_property(row["initDegree"]),
        "brief":parse_list(row["brief"]),
        "tags":parse_list(row["tags"])
    }

    raw_book = db["Books"].find_one({"id":str(row["id"])})

    bookImage = {
        "id":row["id"],
        "image":raw_book["image"]
    }

    db["BooksData"].insert_one(bookData)
    db["BooksImage"].insert_one(bookImage)

db.drop_collection("Books")