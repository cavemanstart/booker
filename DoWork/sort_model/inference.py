import numpy as np
import paddle.inference as paddle_infer


def set_config(model_path: str, params_path: str):
    config = paddle_infer.Config(model_path, params_path)
    config.disable_gpu()
    return config


def predict(input_data, config):
    predictor = paddle_infer.Predictor(config)

    input_names = predictor.get_input_names()
    input_tensor = predictor.get_input_handle(input_names[0])

    inputs = np.array([elem for elem in input_data])
    input_tensor.copy_from_cpu(inputs)

    predictor.run()

    output_names = predictor.get_output_names()
    output_tensor = predictor.get_output_handle(output_names[0])
    output_data = output_tensor.copy_to_cpu()

    return output_data
