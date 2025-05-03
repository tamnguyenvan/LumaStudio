from pathlib import Path
from PIL import Image
import uuid
from .base_processor import BaseImageProcessor
from PySide6.QtCore import QUrl

class CompressProcessor(BaseImageProcessor):
    """Processor for compressing images with quality control"""

    def __init__(self):
        super().__init__()
        self._quality = 85  # Default quality

    def compress_image(self, quality: int) -> None:
        job_id = f"compress_{uuid.uuid4()}"
        self._job_manager.submit_job(
            job_id,
            self._compress_image_job,
            quality
        )
    
    def _compress_image_job(self, quality: int) -> None:
        """Actual compress operation running in a separate thread"""
        if not self._image:
            self.processingFailed.emit("No image loaded")
            return

        try:
            self.processingStarted.emit("Compressing image...")
            
            # Create a copy for compression
            compressed = self._image.copy()
            
            # Get original format, default to JPEG if unknown
            output_format = self._image.format or "JPEG"
            
            # Create temp path with correct extension
            temp_path = Path(self._temp_dir) / f"compressed_{uuid.uuid4()}.{output_format.lower()}"
            
            # Save with compression
            compressed.save(
                temp_path,
                format=output_format,
                quality=quality,
                optimize=True
            )
            
            # Load the compressed image to get its dimensions
            self._result_image = Image.open(temp_path)
            
            # Convert to URL and return
            result_url = QUrl.fromLocalFile(str(temp_path)).toString()
            print(f"Generated URL: {result_url}")
            return result_url

        except Exception as e:
            error_msg = f"Failed to compress image: {str(e)}"
            print(error_msg)
            raise Exception(error_msg)

    def _on_job_started(self, job_id: str) -> None:
        if job_id.startswith("compress_"):
            self.processingStarted.emit("Compressing image...")

    def _on_job_progress(self, job_id: str, progress: float) -> None:
        if job_id.startswith("compress_"):
            self.processingProgress.emit(progress)

    def _on_job_completed(self, job_id: str, result: str) -> None:
        if job_id.startswith("compress_"):
            print(f"Compress job completed. Result URL: {result}")
            self.processingCompleted.emit(result)

    def _on_job_failed(self, job_id: str, error: str) -> None:
        if job_id.startswith("compress_"):
            print(f"Compress job failed: {error}")
            self.processingFailed.emit(error)
