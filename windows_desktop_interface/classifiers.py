#!/usr/bin/python3
"""
This file contains the implementation of an interface and a sample implementation with Tensorflow

Author: Leonardo Lucio Custode
Date: 13/3/2020
"""

# Remove all the unused imports
import cv2
import json
# import torch
import numpy as np
import tensorflow as tf
# from torchvision.models import resnet18


class Classifier:
    """ Interface for the classifiers """
    def predict(self, json_input):
        """
        Predicition function.

        :param json_input: a json dictionary which contains the needed parameters
        :returns a dictionary containing the same fields plus the ones regarding the results
        """
        raise NotImplementedError("This method must be implemented by the extending class")


class TFClassifier(Classifier):
    def __init__(self):
        # Load the default model
        self.img_shape = (224, 224, 3)
        # self.model = tf.keras.applications.MobileNetV2(input_shape=self.img_shape, include_top=True, weights='imagenet')
        # self.model.save("model.hdf5")
        self.model = tf.keras.models.load_model("model.hdf5")
        print("Model loaded: {}".format(self.model))

    def predict(self, json_input):
        input_data = json.loads(json_input)
        output = input_data
        
        for file in input_data['avi_files']:
            cap = cv2.VideoCapture(file)

            clf_output = np.zeros((1, 1000))
            ctr = 0
            max_ = 16
            while cap.isOpened():
                _, frame = cap.read()

                if frame is None or len(frame) == 0:
                    break
                frame = cv2.resize(frame, (self.img_shape[1], self.img_shape[0]))
                curr_output = self.model.predict(frame.reshape(-1, *self.img_shape))
                clf_output += curr_output.reshape((1, 1000))

                ctr += 1
                print("Analizzato frame {} di {}".format(ctr, max_))
                if ctr == max_:
                    break

            output[file] = str(np.argmax(clf_output))
        output['paziente'] = input_data['avi_files'][0].split("/")[-1].split("\\")[0]
        output['esito classificazione'] = "TBI"
        output['dettagli classificazione'] = "Nessuno"
        output = json.dumps(output)
        return output
