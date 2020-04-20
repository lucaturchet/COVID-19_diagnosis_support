#!/usr/bin/python3
"""
This file contains the implementation of an interface and a sample implementation with Tensorflow

Author: Leonardo Lucio Custode
Date: 13/3/2020
"""

# Remove all the unused imports
import os
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
        
        self.model = tf.keras.models.load_model("model.hdf5")
        print("Model loaded: {}".format(self.model))

    def predict(self, json_input):
        input_data = json.loads(json_input)
        output = input_data
        
        for file in os.listdir(input_data['working_dir']):
            if ".avi" in file:
                cap = cv2.VideoCapture(os.path.join(input_data['working_dir'], file))

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
                    #print("Analizzato frame {} di {}".format(ctr, max_))
                    if ctr == max_:
                        break

                output[file] = str(np.argmax(clf_output))
        output['name'] = output['working_dir'].split("/")[-1]

        output.update(
            {
                'left-anterior-apical': 0,
                'left-anterior-basal': 1,
                'left-lateral-apical': 2,
                'left-lateral-basal': 3,
                'left-posterior-apical': 4,
                'left-posterior-medial': 0,
                'left-posterior-basal': 1,
                'right-anterior-apical': 2,
                'right-anterior-basal': 3,
                'right-lateral-apical': 4,
                'right-lateral-basal': 0,
                'right-posterior-apical': 1,
                'right-posterior-medial': 2,
                'right-posterior-basal': 3,
                'pathological_areas': 4,
                'n_score_0': 4,
                'n_score_1': 3,
                'n_score_2': 2,
                'n_score_3': 1,
                'n_not_measured': 10,
            }
        )

        output = json.dumps(output)
        return output

