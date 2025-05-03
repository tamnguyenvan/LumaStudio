import uuid
import numpy as np
import cv2
from pathlib import Path
from PIL import Image
from PySide6.QtCore import QUrl
from ..utils.face_detector.detector import FaceDetector
from .base_processor import BaseImageProcessor
from ..utils.color import hex_to_rgb

class BlurFaceProcessor(BaseImageProcessor):
    """Processor for blurring faces in images"""

    def blur_faces(self,
        opacity: float = 0.5,
        mask_color: str = "#3b82f6",
        mask_shape: str = "rectangle"
    ) -> None:
        job_id = f"blur_{uuid.uuid4()}"
        self._job_manager.submit_job(
            job_id,
            self._blur_faces_job,
            self._image,
            opacity,
            mask_color,
            mask_shape
        )
    
    def _blur_faces_job(self,
        image: Image.Image,
        opacity: float = 0.5,
        mask_color: str = "#3b82f6",
        mask_shape: str = "rectangle"
    ) -> None:
        """Actual blur operation running in a separate thread"""
        try:
            self.processingStarted.emit("Blurring faces...")
            
            # Create a copy for blurring
            blurred = image.copy()
            
            # Get original format, default to JPEG if unknown
            output_format = image.format or "JPEG"
            
            # Create temp path with correct extension
            temp_path = Path(self._temp_dir) / f"blurred_{uuid.uuid4()}.{output_format.lower()}"
            
            # Detect faces
            detector = FaceDetector()
            image_np = np.array(image)
            boxes, labels, probs = detector.detect(image_np)
            
            # Blur faces
            for box in boxes:
                x1, y1, x2, y2 = box
                print(f"Box: {box}")

                # Create a mask for blurring
                crop = image_np[y1:y2, x1:x2]
                mask = np.zeros_like(crop)
                # mask_color = hex_to_rgb(mask_color)
                mask_color = (255, 255, 255)

                print(mask.dtype, mask_color, type(mask_color), crop.shape[1], crop.shape[0])
                if mask_shape == "rectangle":
                    cv2.rectangle(mask, (0, 0), (crop.shape[1] - 1, crop.shape[0] - 1), mask_color, -1)
                elif mask_shape == "circle":
                    center = (crop.shape[1] // 2, crop.shape[0] // 2)
                    radius = min(crop.shape[1] // 2, crop.shape[0] // 2)
                    cv2.circle(mask, center, radius, mask_color, -1)
                
                # Added weighted blur
                cv2.addWeighted(crop, 1 - opacity, mask, opacity, 0, crop)
                image_np[y1:y2, x1:x2] = crop
                
            # Save with compression
            blurred = Image.fromarray(image_np)
            blurred.save(temp_path)
            
            # Load the compressed image to get its dimensions
            self._result_image = Image.open(temp_path)
            
            # Convert to URL and return
            result_url = QUrl.fromLocalFile(str(temp_path)).toString()
            print(f"Generated URL: {result_url}")
            return result_url
        except Exception as e:
            error_msg = f"Failed to blur faces: {str(e)}"
            print(error_msg)
            raise Exception(error_msg)
    
    def _on_job_started(self, job_id: str) -> None:
        if job_id.startswith("blur_"):
            self.processingStarted.emit("Blurring faces...")
        
    def _on_job_progress(self, job_id: str, progress: float) -> None:
        if job_id.startswith("blur_"):
            self.processingProgress.emit(progress)
        
    def _on_job_completed(self, job_id: str, result: str) -> None:
        if job_id.startswith("blur_"):
            self.processingCompleted.emit(result)
        
    def _on_job_failed(self, job_id: str, error: str) -> None:
        if job_id.startswith("blur_"):
            self.processingFailed.emit(error)