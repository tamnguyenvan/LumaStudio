from PIL import Image
from .base_processor import BaseImageProcessor
import uuid

class CropProcessor(BaseImageProcessor):
    """Handles image cropping operations"""

    def crop_image(self, x: int, y: int, width: int, height: int) -> None:
        """Crop the current image to the specified dimensions"""
        if not self._image:
            self.processingFailed.emit("No image loaded")
            return

        print(f"Starting crop job with dimensions: {width}x{height} at position ({x},{y})")
        print(f"Current image size: {self._image.size}")
        
        job_id = f"crop_{uuid.uuid4()}"
        self._job_manager.submit_job(
            job_id,
            self._crop_image_job,
            self._image,
            x, y, width, height
        )

    def _crop_image_job(self, image: Image.Image, x: int, y: int, width: int, height: int) -> str:
        """Actual crop operation running in a separate thread"""
        try:
            # Create a copy to avoid modifying the original
            img = image.copy()
            
            # Calculate crop box (left, top, right, bottom)
            box = (x, y, x + width, y + height)
            
            # Ensure crop box is within image bounds
            img_width, img_height = img.size
            box = (
                max(0, box[0]),
                max(0, box[1]),
                min(img_width, box[2]),
                min(img_height, box[3])
            )
            
            # Perform crop
            cropped = img.crop(box)
            
            # Save and return URL
            return self.save_processed_image(cropped, "cropped")
                
        except Exception as e:
            error_msg = f"Failed to crop image: {str(e)}"
            print(error_msg)
            raise Exception(error_msg)

    def _on_job_started(self, job_id: str) -> None:
        if job_id.startswith("crop_"):
            self.processingStarted.emit("Cropping image...")

    def _on_job_progress(self, job_id: str, progress: float) -> None:
        if job_id.startswith("crop_"):
            self.processingProgress.emit(progress)

    def _on_job_completed(self, job_id: str, result: str) -> None:
        if job_id.startswith("crop_"):
            print(f"Crop job completed. Result URL: {result}")
            self.processingCompleted.emit(result)

    def _on_job_failed(self, job_id: str, error: str) -> None:
        if job_id.startswith("crop_"):
            print(f"Crop job failed: {error}")
            self.processingFailed.emit(error)
