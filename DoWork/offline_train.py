import subprocess
import os

from database import redis_client
from offline.books2vec import process_books2vec
from offline.favorSimResults import process_favor_sim_results
from offline.featureEngineering.BookFeatures import process_book_features
from offline.featureEngineering.UserFeatures import process_user_features
from offline.historySimResults import process_history_sim_results
from offline.seq2vec import process_seq2vec
from offline.tagSimResults import process_tag_sim_results
from offline.tags2vec import process_tags2vec
from offline.userHistoryFeatures import process_user_history_features
from offline.userTagFeatures import process_user_tag_features
from sort_model import offline_train, model_save

hostname = "39.103.210.93"
mongo_port = "27017"

books_data_path = "./data/BooksData.csv"
users_data_path = "./data/UsersData.csv"
user_collections_path = "./data/trainData/UserCollections.csv"
book_tag_features_path = "./data/features/BookTagFeatures.csv"
user_history_features_path = "./data/features/UserHistoryFeatures.csv"
user_seq_features_path = "./data/features/UserSeqFeatures.csv"
user_tag_features_path = "./data/features/UserTagFeatures.csv"
book_features_path = "./data/trainData/BookFeatures.csv"
user_features_path = "./data/trainData/UserFeatures.csv"
cold_tags_path = "./data/misc/coldTags.txt"

models_base_path = "./models"

occupation_path = "./data/misc/occupation.csv"

export_template_cmd = 'mongoexport --host {hostname} -u bookerAdmin -p 123456 -d booker -c {collection} -f {fields} --csv -o {path}'

if __name__ == '__main__':
    #step 0: mkdir to store data
    if not os.path.exists("./data"):
        os.mkdir("./data")
    if not os.path.exists("./data/features"):
        os.mkdir("./data/features")
    if not os.path.exists("./data/trainData"):
        os.mkdir("./data/trainData")
    if not os.path.exists("./models"):
        os.mkdir("./models")

    # step 1: export train data of BooksData from Mongo to ./data/BooksData.csv
    print("step 1: export train data of BooksData from Mongo to ./data/BooksData.csv")
    export_BooksData_cmd = export_template_cmd.format(
        hostname=hostname,
        collection="BooksData",
        fields="author,degree,id,initDegree,pageNum,publishTime,publisher,subtitle,tags,title",
        path=books_data_path
    )
    subprocess.run(export_BooksData_cmd.split())

    # step 2: export train data of UsersData from Mongo to ./data/UsersData.csv
    print("step 2: export train data of UsersData from Mongo to ./data/UsersData.csv")
    export_UsersData_cmd = export_template_cmd.format(
        hostname=hostname,
        collection="UsersData",
        fields="uid,age,gender,occupation,favors",
        path=users_data_path
    )
    subprocess.run(export_UsersData_cmd.split())

    #step 3: export train data of UserCollections from Mongo to ./data/trainData/UserCollections.csv
    print("step 3: export train data of UserCollections from Mongo to ./data/trainData/UserCollections.csv")
    export_UserCollections_cmd = export_template_cmd.format(
        hostname=hostname,
        collection="UserCollections",
        fields="uid,bid,addTime,scoreTime,score,isReaded",
        path=user_collections_path
    )
    subprocess.run(export_UserCollections_cmd)

    #step 4: run process_tags2vec
    print("step 4: run process_tags2vec")
    process_tags2vec(books_data_path, models_base_path)

    #step 5: run process_books2vec
    print("run process_books2vec")
    process_books2vec(models_base_path+"/tags_vectors.bin",books_data_path)

    #step 6: run process_seq2vec
    print("run process_seq2vec")
    process_seq2vec(models_base_path)

    #step 7: run process_user_history_features
    print("step 7: run process_user_history_features")
    process_user_history_features()

    #step 8: run process_user_tag_features
    print("run process_user_tag_features")
    process_user_tag_features()

    #step 9: export BookTagFeatures, UserHistoryFeatures, UserSeqFeatures, UserTagFeatures to ./data/features as csv file
    print("step 9: export BookTagFeatures, UserHistoryFeatures, UserSeqFeatures, UserTagFeatures to ./data/features as csv file")
    export_BookTagFeatures_cmd = export_template_cmd.format(
        hostname=hostname,
        collection="BookTagFeatures",
        fields="id,feature",
        path=book_tag_features_path
    )
    subprocess.run(export_BookTagFeatures_cmd.split())

    export_UserHistoryFeatures_cmd = export_template_cmd.format(
        hostname=hostname,
        collection="UserHistoryFeatures",
        fields="uid,feature",
        path=user_history_features_path
    )
    subprocess.run(export_UserHistoryFeatures_cmd)

    export_UserHistoryFeatures_cmd = export_template_cmd.format(
        hostname=hostname,
        collection="UserSeqFeatures",
        fields="uid,feature",
        path=user_seq_features_path
    )
    subprocess.run(export_UserHistoryFeatures_cmd.split())

    export_UserTagFeatures_cmd = export_template_cmd.format(
        hostname=hostname,
        collection="UserTagFeatures",
        fields="uid,feature",
        path=user_tag_features_path
    )
    subprocess.run(export_UserTagFeatures_cmd.split())

    #step 10: run process_book_features
    print("step 10: run process_book_features")
    process_book_features(books_data_path,book_tag_features_path)

    #step 11: run process_user_features
    print("run process_user_features")
    process_user_features(users_data_path,user_history_features_path,user_seq_features_path,user_tag_features_path,occupation_path)

    #step 12: export BookFeatures, UserFeatures to ./data/trainData as csv file
    print("step 12: export BookFeatures, UserFeatures to ./data/trainData as csv file")
    export_BookFeatures_cmd = export_template_cmd.format(
        hostname=hostname,
        collection="BookFeatures",
        fields="id,feature",
        path=book_features_path
    )
    subprocess.run(export_BookFeatures_cmd.split())

    export_UserFeatures_cmd = export_template_cmd.format(
        hostname=hostname,
        collection="UserFeatures",
        fields="uid,feature",
        path=user_features_path
    )
    subprocess.run(export_UserFeatures_cmd.split())

    #step 13: train the model
    print("train the model")
    model = offline_train(book_features_path,user_features_path,user_collections_path)
    model_save(model,"./models/sortModel-1/sortModel-1")
    model_save(model,"./models/sortModel-2/sortModel-2")
    redis_client.set("active-model","sortModel-1")

    #step 14: run process_history_sim_results
    print("run process_history_sim_results")
    process_history_sim_results(books_data_path)

    #step 15: run process_tag_sim_results
    print("run process_tag_sim_results")
    process_tag_sim_results(books_data_path,cold_tags_path)

    #step 16: run process_favor_sim_results
    print("step 16: run process_favor_sim_results")
    process_favor_sim_results(books_data_path)






