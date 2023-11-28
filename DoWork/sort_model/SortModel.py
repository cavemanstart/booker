import paddle
import paddle.nn.functional as F
from paddle.nn import Linear


class SortModel(paddle.nn.Layer):
    def __init__(self, dimension):
        super(SortModel, self).__init__()

        self.dimension = dimension
        self.fc1 = Linear(in_features=self.dimension, out_features=300)
        self.fc2 = Linear(in_features=300, out_features=150)
        self.fc3 = Linear(in_features=150, out_features=75)
        self.fc4 = Linear(in_features=75, out_features=1)

    def forward(self, inputs):
        outputs1 = self.fc1(inputs)
        outputs1 = F.relu(outputs1)
        outputs2 = self.fc2(outputs1)
        outputs2 = F.relu(outputs2)
        outputs3 = self.fc3(outputs2)
        outputs3 = F.relu(outputs3)
        outputs_final = self.fc4(outputs3)
        outputs_final = F.sigmoid(outputs_final)
        return outputs_final
