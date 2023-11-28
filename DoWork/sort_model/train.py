import paddle
from paddle.static import InputSpec

from .FeaturesSet import FeaturesSet
from .SortModel import SortModel
from utils import splitTrainAndVal

DIMENSION = 540


def offline_train(book_features_path, user_features_path, collections_path,learning_rate=0.0003,epochs=100):
    train, val = splitTrainAndVal(collections_path)
    trainSet = FeaturesSet()
    trainSet.set_offline_data(train, book_features_path, user_features_path)
    valSet = FeaturesSet()
    valSet.set_offline_data(val, book_features_path, user_features_path)

    train_loader = paddle.io.DataLoader(trainSet, batch_size=20, shuffle=True)
    val_loader = paddle.io.DataLoader(valSet, batch_size=20, shuffle=True)

    model = SortModel(DIMENSION)
    model = paddle.Model(model)

    optimizer = paddle.optimizer.Adam(parameters=model.parameters(), learning_rate=learning_rate)
    loss = paddle.nn.BCELoss()

    model.prepare(optimizer, loss)
    model.fit(train_data=train_loader, eval_data=val_loader, epochs=epochs, verbose=1)

    results = model.predict(train_loader)
    model.predict_batch([data[0] for data in train_loader])
    print(results)

    return model

def online_train(path,dataset,learning_rate=0.0003,epochs=25):
    model = SortModel(DIMENSION)
    state_dict = paddle.load(path)
    model.state_dict(state_dict)
    model = paddle.Model(model,inputs=InputSpec(shape=[None, DIMENSION], dtype='float32',name="inputs"))

    optimizer = paddle.optimizer.Adam(parameters=model.parameters(), learning_rate=learning_rate)
    loss = paddle.nn.BCELoss()
    train_loader = paddle.io.DataLoader(dataset, batch_size=20, shuffle=True)
    model.prepare(optimizer, loss)
    model.fit(train_data=train_loader, epochs=epochs, verbose=1)
    return model


def model_save(model,path):
    paddle.jit.save(model.network, path,
                    input_spec=[InputSpec(shape=[None, DIMENSION], dtype='float32')])
