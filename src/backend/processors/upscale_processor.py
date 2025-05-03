from .base_processor import BaseImageProcessor
from PIL import Image
import uuid
from pathlib import Path
from PySide6.QtCore import QUrl
from ..utils.upscaler.upscaler import Upscaler

class UpscaleProcessor(BaseImageProcessor):
    def __init__(self):
        super().__init__()
    
    def upscale_image(self, scale: int):
        """Upscale the loaded image"""
        if not self._image:
            self.processingFailed.emit("No image loaded")
            return ""
        
        job_id = f"upscale_{uuid.uuid4()}"
        self._job_manager.submit_job(
            job_id,
            self._upscale_image_job,
            self._image,
            scale
        )
        return ""
    
    def _upscale_image_job(self, image: Image.Image, scale: int):
        """Upscale the image"""
        try:
            temp_path = Path(self._temp_dir) / f"upscaled_{uuid.uuid4()}.png"
            upscaler = Upscaler()
            print(f"Upscaling image with scale: {scale}")
            result = upscaler.upscale(image, scale)
            result.save(temp_path)
            return QUrl.fromLocalFile(temp_path).toString()
        except Exception as e:
            self.processingFailed.emit(str(e))
            return ""

    def _on_job_started(self, job_id: str) -> None:
        if job_id.startswith("upscale_"):
            self.processingStarted.emit("Upscaling...")
        
    def _on_job_progress(self, job_id: str, progress: float) -> None:
        if job_id.startswith("upscale_"):
            self.processingProgress.emit(progress)
        
    def _on_job_completed(self, job_id: str, result: str) -> None:
        if job_id.startswith("upscale_"):
            self.processingCompleted.emit(result)
        
    def _on_job_failed(self, job_id: str, error: str) -> None:
        if job_id.startswith("upscale_"):
            self.processingFailed.emit(error)