import os
from pathlib import Path
from PIL import Image
from PySide6.QtCore import QObject, Signal, QUrl
from ..jobs.job_manager import JobManager
import uuid

class BaseImageProcessor(QObject):
    """Base class for image processing operations"""
    
    # Progress signals
    processingStarted = Signal(str)  # operation_name
    processingProgress = Signal(float)  # progress (0-1)
    processingCompleted = Signal(str)  # result_url
    processingFailed = Signal(str)  # error_message

    # def __init__(self, job_manager: JobManager):
    def __init__(self):
        super().__init__()
        self._job_manager = JobManager()
        self._image = None
        self._result_image = None
        self._temp_dir = Path("/tmp/luma-studio")
        self._temp_dir.mkdir(exist_ok=True)

        # Connect job signals
        self._job_manager.jobStarted.connect(self._on_job_started)
        self._job_manager.jobProgress.connect(self._on_job_progress)
        self._job_manager.jobCompleted.connect(self._on_job_completed)
        self._job_manager.jobFailed.connect(self._on_job_failed)

    def set_image(self, image: Image.Image):
        """Set the current image to process"""
        self._image = image

    def save_processed_image(self, image: Image.Image, operation: str) -> str:
        """Save processed image to temp directory and return URL"""
        temp_path = str(self._temp_dir / f"{operation}_{uuid.uuid4()}.png")
        print(f"Saving {operation} image to: {temp_path}")
        
        try:
            # Ensure directory exists
            if not self._temp_dir.exists():
                print(f"Creating temp directory: {self._temp_dir}")
                self._temp_dir.mkdir(parents=True, exist_ok=True)
            
            # Save image
            image.save(temp_path)
            print(f"Image saved successfully. File exists: {Path(temp_path).exists()}")

            if not Path(temp_path).exists():
                raise Exception(f"Failed to save {operation} image")
            
            # Convert to URL
            url = QUrl.fromLocalFile(temp_path).toString()
            print(f"Generated URL: {url}")

            # Set result image
            self._result_image = image
            return url
            
        except Exception as e:
            print(f"Error saving image: {str(e)}")
            raise
    
    def save_result_image(self, file_path: str) -> None:
        """Save processed image to file path"""
        try:
            # Save image
            if not self._result_image:
                raise Exception("No result image to save")
            
            self._result_image.save(file_path)
            print(f"Image saved successfully. File exists: {Path(file_path).exists()}")

            if not Path(file_path).exists():
                raise Exception(f"Failed to save {file_path}")
            
        except Exception as e:
            print(f"Error saving image: {str(e)}")
            raise

    def cleanup_temp_files(self) -> None:
        """Clean up temporary files"""
        for file in os.listdir(self._temp_dir):
            try:
                os.remove(str(self._temp_dir / file))
            except:
                pass

    def _on_job_started(self, job_id: str) -> None:
        pass

    def _on_job_progress(self, job_id: str, progress: float) -> None:
        pass

    def _on_job_completed(self, job_id: str, result: str) -> None:
        pass

    def _on_job_failed(self, job_id: str, error: str) -> None:
        pass
