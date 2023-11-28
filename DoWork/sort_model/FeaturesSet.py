import numpy as np
import paddle
import pandas as pd
from paddle.io import Dataset

from utils import parseFeatureString, splitTrainAndVal


class FeaturesSet(Dataset):
    def __init__(self):
        super(FeaturesSet, self).__init__()
        self.dataset = list()

    def set_offline_data(self, userCollections, bookFeaturesPath, userFeaturesPath):
        bookFeatures = pd.read_csv(bookFeaturesPath)
        bookFeatures = bookFeatures.set_index("id")
        userFeatures = pd.read_csv(userFeaturesPath)
        userFeatures = userFeatures.set_index("uid")

        sumScore = userCollections["score"].sum()

        for index, row in userCollections.iterrows():
            book_id = row["bid"]
            user_id = row["uid"]
            label = row["score"]

            book_feature = np.array(parseFeatureString(bookFeatures.loc[book_id, 'feature']), dtype=np.float)
            book_feature = paddle.to_tensor(book_feature, dtype=paddle.float32)
            user_feature = np.array(parseFeatureString(userFeatures.loc[user_id, 'feature']), dtype=np.float)
            user_feature = paddle.to_tensor(user_feature, dtype=paddle.float32)

            feature = np.concatenate([book_feature, user_feature])
            label = np.array([label / sumScore], dtype=np.float)
            label = paddle.to_tensor(label, dtype=paddle.float32)
            self.dataset.append((feature, label))

    def add_online_data(self,user_feature,book_feature,label):
            book_feature = paddle.to_tensor(book_feature, dtype=paddle.float32)
            user_feature = paddle.to_tensor(user_feature, dtype=paddle.float32)
            feature = np.concatenate([book_feature, user_feature])
            label = paddle.to_tensor(label, dtype=paddle.float32)
            self.dataset.append((feature,label))


    def __getitem__(self, index):
        feature, label = self.dataset[index]
        return feature, label

    def __len__(self):
        return len(self.dataset)


if __name__ == '__main__':
    print("Test FeatureSet")

    train, val = splitTrainAndVal("../data/trainData/UserCollections.csv")
    data_dir = "../data/trainData"
    trainSet = FeaturesSet()
    trainSet.set_offline_data(train, data_dir + "/BookFeatures.csv", data_dir + "/UserFeatures.csv")
    valSet = FeaturesSet()
    valSet.set_offline_data(val, data_dir + "/BookFeatures.csv", data_dir + "/UserFeatures.csv")
    train_loader = paddle.io.DataLoader(trainSet, batch_size=20, shuffle=True)
