from PIL import Image
import numpy as np
import cv2
import onnxruntime as ort
from pathlib import Path

class BgRemover:
    def __init__(self):
        self._session = ort.InferenceSession(Path(__file__).parent / "models/isnet-1024.onnx")
        self._input_name = self._session.get_inputs()[0].name
        self._output_name = self._session.get_outputs()[0].name

    def remove_bg(self, image: Image.Image, bg_color: str = "", crop: bool = False):
        """Remove background from image"""
        img = np.array(image)
        original_height, original_width = img.shape[:2]

        # Convert image to RGB if it's not already
        if img.shape[2] == 4:
            img = img[:, :, :3]
        
        # Resize to (1024, 1024)
        img = cv2.resize(img, (1024, 1024))

        # Convert image to float32 and normalize to [0, 1]
        img = img.astype(np.float32) / 255.0
        img = (img - 0.5) / 1.0

        # Tranpose image to (C, H, W)
        img = img.transpose(2, 0, 1)

        # Add batch dimension
        img = np.expand_dims(img, axis=0)

        # Run inference
        output = self._session.run([self._output_name], {self._input_name: img})[0]

        # Reshape output to (H, W)
        output = output[0][0]
        mi = output.min()
        ma = output.max()
        output = (output - mi) / (ma - mi)
        output = (output * 255).astype(np.uint8)
        
        # Resize output to original size
        alpha = cv2.resize(output, (original_width, original_height))
        alpha_pil = Image.fromarray(alpha)

        empty = Image.new("RGBA", (original_width, original_height), 0)          
        cutout = Image.composite(image, empty, alpha_pil)

        # if crop:
        #     cutout = cutout.crop(cutout.getbbox())
        
        if bg_color != "":
            bg_color = (255, 255, 255)
            background = Image.new("RGBA", (original_width, original_height), tuple(bg_color))
            cutout = Image.alpha_composite(background, cutout)      

        return cutout
        