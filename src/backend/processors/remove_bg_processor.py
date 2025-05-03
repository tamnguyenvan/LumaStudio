from pathlib import Path
import uuid
from PIL import Image
from PySide6.QtCore import QUrl

from .base_processor import BaseImageProcessor
from ..utils.bg_remover.bg_remover import BgRemover

class RemoveBgProcessor(BaseImageProcessor):
    """Handles image remove background operations"""

    def remove_bg(self, bg_color: str = "#ffffff", crop: bool = False) -> None:
        """Remove background from the current image"""
        if not self._image:
            self.processingFailed.emit("No image loaded")
            return

        print(f"Starting remove bg job")
        print(f"Current image size: {self._image.size}")
        
        job_id = f"remove_bg_{uuid.uuid4()}"
        self._job_manager.submit_job(
            job_id,
            self._remove_bg_job,
            self._image,
            bg_color,
            crop
        )
    
    def _remove_bg_job(self, image: Image.Image, bg_color: str, crop: bool) -> str:
        """Actual remove background operation running in a separate thread"""
        try:
            # Get original format, default to PNG if unknown
            output_format = "PNG"
            
            # Create temp path with correct extension
            temp_path = Path(self._temp_dir) / f"removed_{uuid.uuid4()}.{output_format.lower()}"
            
            # Remove background
            remover = BgRemover()
            removed = remover.remove_bg(image, bg_color, crop)
            
            # Save result
            removed.save(temp_path)
            return QUrl.fromLocalFile(temp_path).toString() 
        except Exception as e:
            error_msg = f"Failed to remove background: {str(e)}"
            print(error_msg)
            raise Exception(error_msg)
    
    def _on_job_started(self, job_id: str) -> None:
        if job_id.startswith("remove_bg_"):
            self.processingStarted.emit("Removing background...")
        
    def _on_job_progress(self, job_id: str, progress: float) -> None:
        if job_id.startswith("remove_bg_"):
            self.processingProgress.emit(progress)
        
    def _on_job_completed(self, job_id: str, result: str) -> None:
        if job_id.startswith("remove_bg_"):
            self.processingCompleted.emit(result)
        
    def _on_job_failed(self, job_id: str, error: str) -> None:
        if job_id.startswith("remove_bg_"):
            self.processingFailed.emit(error)
        