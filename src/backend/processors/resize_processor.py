from PIL import Image
from .base_processor import BaseImageProcessor
import uuid

class ResizeProcessor(BaseImageProcessor):
    """Handles image resizing operations"""

    def resize_image(self, width: int, height: int) -> None:
        """Resize the current image to the specified dimensions"""
        if not self._image:
            self.processingFailed.emit("No image loaded")
            return

        print(f"Starting resize job with dimensions: {width}x{height}")
        print(f"Current image size: {self._image.size}")
        
        job_id = f"resize_{uuid.uuid4()}"
        self._job_manager.submit_job(
            job_id,
            self._resize_image_job,
            self._image,
            width,
            height
        )

    def _resize_image_job(self, image: Image.Image, width: int, height: int) -> str:
        """Actual resize operation running in a separate thread"""
        try:
            # Create a copy to avoid modifying the original
            img = image.copy()
            
            # Perform resize
            resized = img.resize((width, height), Image.Resampling.LANCZOS)
            
            # Save and return URL
            return self.save_processed_image(resized, "resized")
                
        except Exception as e:
            error_msg = f"Failed to resize image: {str(e)}"
            print(error_msg)
            raise Exception(error_msg)

    def _on_job_started(self, job_id: str) -> None:
        if job_id.startswith("resize_"):
            self.processingStarted.emit("Resizing image...")

    def _on_job_progress(self, job_id: str, progress: float) -> None:
        if job_id.startswith("resize_"):
            self.processingProgress.emit(progress)

    def _on_job_completed(self, job_id: str, result: str) -> None:
        if job_id.startswith("resize_"):
            print(f"Resize job completed. Result URL: {result}")
            self.processingCompleted.emit(result)

    def _on_job_failed(self, job_id: str, error: str) -> None:
        if job_id.startswith("resize_"):
            print(f"Resize job failed: {error}")
            self.processingFailed.emit(error)
