import os
from PySide6.QtCore import QObject, Slot, QUrl, Signal, Property
from PIL import Image
from .models.tool_model import TOOLS
from .processors.resize_processor import ResizeProcessor
from .processors.crop_processor import CropProcessor

class AppController(QObject):
    # Signals for the UI
    imageLoaded = Signal(int, int, str)  # width, height, size
    processingStarted = Signal(str)  # operation name
    processingProgress = Signal(float)  # progress
    processingCompleted = Signal(str)  # result url
    processingFailed = Signal(str)  # error message
    processedImageInfoChanged = Signal()

    # Map tool IDs to processor classes
    PROCESSOR_MAP = {
        'resize': ResizeProcessor,
        'crop': CropProcessor
    }

    def __init__(self):
        super().__init__()
        self._image = None
        self._processed_image_info = {
            'width': 0,
            'height': 0,
            'size': '0 KB'
        }
        
        # Initialize processors
        self._current_processor = None
        self._processors = {}
        for tool in TOOLS:
            processor_name = tool.tool_id.lower()
            processor_cls = self.PROCESSOR_MAP.get(processor_name)
            if processor_cls:
                self._processors[processor_name] = processor_cls()
        
        # Connect processor signals
        for processor in self._processors.values():
            processor.processingStarted.connect(self.processingStarted)
            processor.processingProgress.connect(self.processingProgress)
            processor.processingCompleted.connect(self._on_processing_completed)
            processor.processingFailed.connect(self.processingFailed)

    @Property('QVariantMap', notify=processedImageInfoChanged)
    def processedImageInfo(self):
        return self._processed_image_info

    def _on_processing_completed(self, result_url):
        """Update processed image info and emit completion signal"""
        try:
            # Get processed image info
            path = QUrl(result_url).toLocalFile()
            if os.path.exists(path):
                img = Image.open(path)
                size_bytes = os.path.getsize(path)
                size_text = "%.1f KB" % (size_bytes / 1024) if size_bytes < 1024 * 1024 else "%.1f MB" % (size_bytes / (1024 * 1024))
                
                self._processed_image_info = {
                    'width': img.width,
                    'height': img.height,
                    'size': size_text
                }
                self.processedImageInfoChanged.emit()
                
                # Emit completion with result URL
                self.processingCompleted.emit(result_url)
        except Exception as e:
            self.processingFailed.emit(f"Failed to get processed image info: {str(e)}")

    @Slot(str)
    def setProcessor(self, processor_name):
        """Set the current processor"""
        processor_name = processor_name.lower()
        if processor_name in self._processors:
            print(f"Switching to processor: {processor_name}")
            self._current_processor = self._processors[processor_name]
            # Share current image with new processor if one is loaded
            if self._image:
                print(f"Sharing image with {processor_name} processor")
                self._current_processor.set_image(self._image)
        else:
            print(f"Warning: Unknown processor {processor_name}")
            self._current_processor = None

    @Slot(str)
    def loadImage(self, file_url):
        """Load image from file URL"""
        path = QUrl(file_url).toLocalFile()
        print(f"Loading image from: {path}")
        
        if os.path.exists(path):
            try:
                self._image = Image.open(path)
                print(f"Image loaded successfully. Size: {self._image.size}")
                
                self._current_processor.set_image(self._image)
                
                # Calculate size
                size_bytes = os.path.getsize(path)
                size_text = "%.1f KB" % (size_bytes / 1024) if size_bytes < 1024 * 1024 else "%.1f MB" % (size_bytes / (1024 * 1024))
                
                # Emit loaded signal
                self.imageLoaded.emit(self._image.width, self._image.height, size_text)
                return file_url
            except Exception as e:
                error_msg = f"Failed to load image: {str(e)}"
                print(error_msg)
                self.processingFailed.emit(error_msg)
        else:
            print(f"File not found: {path}")
        return ""

    @Slot(int, int)
    def resizeImage(self, width, height):
        """Resize the loaded image"""
        if not self._image:
            self.processingFailed.emit("No image loaded")
            return ""
        

        self._current_processor.resize_image(width, height)
        return ""
    
    @Slot(int, int, int, int)
    def cropImage(self, x, y, width, height):
        """Crop the loaded image"""
        if not self._image:
            self.processingFailed.emit("No image loaded")
            return ""
        
        self._current_processor.crop_image(x, y, width, height)
        return ""

    @Slot(str)
    def saveImage(self, file_url):
        """Save the processed image to the specified location"""
        if not self._current_processor._image:
            self.processingFailed.emit("No image to save")
            return
        
        path = QUrl(file_url).toLocalFile()
        try:
            self._current_processor.save_result_image(path)
        except Exception as e:
            self.processingFailed.emit(f"Failed to save image: {str(e)}")

    def __del__(self):
        """Cleanup on deletion"""
        if hasattr(self, '_processors'):
            # for processor in self._processors.values():
            #     processor.cleanup_temp_files()
            pass