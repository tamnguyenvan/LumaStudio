from pathlib import Path
import onnxruntime as ort
import math
import numpy as np
from PIL import Image

class Upscaler:
    def __init__(self):
        self._session = ort.InferenceSession(Path(__file__).parent / "models/real_esrgan_general_x4v3.onnx")
        self._input_name = self._session.get_inputs()[0].name
        self._output_name = self._session.get_outputs()[0].name
    
    def upscale(self, image: Image.Image, scale: int = 4):
        """Upscale the image"""
        image = np.array(image)
        h0, w0 = image.shape[:2]
        tile_size = 128
        h, w = math.ceil(h0 / tile_size) * tile_size, math.ceil(w0 / tile_size) * tile_size
        expaned_image = np.zeros((h, w, 3), dtype=np.uint8)
        expaned_image[:h0, :w0] = image
        output = np.zeros((h * scale, w * scale, 3), dtype=np.uint8)
        print(f"h0: {h0}, w0: {w0}, h: {h}, w: {w}")
        print(f"output shape: {output.shape}")
        for y in range(0, h, tile_size):
            for x in range(0, w, tile_size):
                print(f'y: {y}, x: {x}')
                tile = expaned_image[y:y + tile_size, x:x + tile_size]
                upsampled_tile = self._upscale(tile, scale)
                output[y * scale:(y + tile_size) * scale, x * scale:(x + tile_size) * scale] = upsampled_tile
        
        output = output[:h0 * scale, :w0 * scale]
        output = Image.fromarray(output)
        return output

    def _upscale(self, image: np.ndarray, scale: int = 4):
        """Real function to upscale the image"""
        inputs = np.transpose(image, (2, 0, 1))[np.newaxis].astype(np.float32) / 255.0
        output = self._session.run(None, {self._input_name: inputs})[0]
        output = np.transpose(output[0], (1, 2, 0))
        output = (output * 255.0).clip(0, 255).astype(np.uint8)
        return output
    