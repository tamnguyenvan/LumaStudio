from .base_processor import BaseImageProcessor
import uuid
from PIL import Image
from PySide6.QtCore import QUrl

class ConvertProcessor(BaseImageProcessor):
    """Handles image conversion operations"""

    def convert_image(self, format: str) -> None:
        """Convert the current image to the specified format"""
        if not self._image:
            self.processingFailed.emit("No image loaded")
            return

        print(f"Starting convert job with format: {format}")
        print(f"Current image size: {self._image.size}")
        
        job_id = f"convert_{uuid.uuid4()}"
        self._job_manager.submit_job(
            job_id,
            self._convert_image_job,
            self._image,
            format
        )
    
    def _convert_image_job(self, image: Image.Image, format: str) -> str:
        """Actual convert operation running in a separate thread"""
        try:
            # Create a copy to avoid modifying the original
            img = image.copy()
            
            # Convert the image
            img = img.convert(format)
            
            # Save the converted image
            temp_path = f"temp_{uuid.uuid4()}.{format.lower()}"
            img.save(temp_path)
            
            return QUrl.fromLocalFile(temp_path).toString()
        except Exception as e:
            self.processingFailed.emit(f"Failed to convert image: {str(e)}")
            return ""
    
    def _on_job_started(self, job_id: str) -> None:
        if job_id.startswith("convert_"):
            self.processingStarted.emit("Converting image...")
        
    def _on_job_progress(self, job_id: str, progress: float) -> None:
        if job_id.startswith("convert_"):
            self.processingProgress.emit(progress)
        
    def _on_job_completed(self, job_id: str, result: str) -> None:
        if job_id.startswith("convert_"):
            self.processingCompleted.emit(result)
        
    def _on_job_failed(self, job_id: str, error: str) -> None:
        if job_id.startswith("convert_"):
            self.processingFailed.emit(error)