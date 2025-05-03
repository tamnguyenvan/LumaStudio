import cv2
from pathlib import Path
import numpy as np
from .import box_utils

import onnxruntime as ort

class FaceDetector:
    def __init__(self):
        self._session = ort.InferenceSession(Path(__file__).parent / "models/version-RFB-320.onnx")
        self._input_name = self._session.get_inputs()[0].name
        self._output_name = self._session.get_outputs()[0].name
        self._threshold = 0.7
    
    def detect(self, image):
        """Predict faces in the image"""
        original_height, original_width = image.shape[:2]
        image = cv2.resize(image, (320, 240))
        image = image.astype(np.float32)
        image_mean = np.array([127, 127, 127], dtype=np.float32)
        image = (image - image_mean) / 128.0
        image = np.transpose(image, [2, 0, 1])
        image = np.expand_dims(image, axis=0)
        confidences, boxes = self._session.run(None, {self._input_name: image})
        boxes, labels, probs = self._predict(original_width,
                                            original_height,
                                            confidences,
                                            boxes,
                                            self._threshold)
        return boxes, labels, probs

    def _predict(self, width, height, confidences, boxes, prob_threshold, iou_threshold=0.3, top_k=-1):
        """Real prediction"""
        boxes = boxes[0]
        confidences = confidences[0]
        picked_box_probs = []
        picked_labels = []
        for class_index in range(1, confidences.shape[1]):
            probs = confidences[:, class_index]
            mask = probs > prob_threshold
            probs = probs[mask]
            if probs.shape[0] == 0:
                continue
            subset_boxes = boxes[mask, :]
            box_probs = np.concatenate([subset_boxes, probs.reshape(-1, 1)], axis=1)
            box_probs = box_utils.hard_nms(box_probs,
                                        iou_threshold=iou_threshold,
                                        top_k=top_k,
                                        )
            picked_box_probs.append(box_probs)
            picked_labels.extend([class_index] * box_probs.shape[0])
        if not picked_box_probs:
            return np.array([]), np.array([]), np.array([])
        picked_box_probs = np.concatenate(picked_box_probs)
        picked_box_probs[:, 0] *= width
        picked_box_probs[:, 1] *= height
        picked_box_probs[:, 2] *= width
        picked_box_probs[:, 3] *= height
        return picked_box_probs[:, :4].astype(np.int32), np.array(picked_labels), picked_box_probs[:, 4]
