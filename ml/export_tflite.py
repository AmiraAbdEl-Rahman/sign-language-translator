"""Convert the Keras model to TFLite (for a future on-device mode)."""
import os
import tensorflow as tf
from common import MODELS_DIR

model = tf.keras.models.load_model(os.path.join(MODELS_DIR, "sign_model.keras"))
conv = tf.lite.TFLiteConverter.from_keras_model(model)
conv.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS, tf.lite.OpsSet.SELECT_TF_OPS]
conv._experimental_lower_tensor_list_ops = False  # needed for LSTM
open(os.path.join(MODELS_DIR, "sign_model.tflite"), "wb").write(conv.convert())
print("saved sign_model.tflite")
