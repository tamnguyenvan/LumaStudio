import os
import json

from PySide6.QtCore import QObject, Slot, QUrl, Signal, Property
from PIL import Image
from .models.tool_model import ToolModel
from .processors.resize_processor import ResizeProcessor
from .processors.crop_processor import CropProcessor
from .processors.compress_processor import CompressProcessor
from .processors.convert_processor import ConvertProcessor
from .processors.blur_face_processor import BlurFaceProcessor
from .processors.remove_bg_processor import RemoveBgProcessor
from .processors.upscale_processor import UpscaleProcessor

class AppController(QObject):
    # Signals for the UI
    imageLoaded = Signal(int, int, str)  # width, height, size
    processingStarted = Signal(str)  # operation name
    processingProgress = Signal(float)  # progress
    processingCompleted = Signal(str)  # result url
    processingFailed = Signal(str)  # error message
    processedImageInfoChanged = Signal()
    processorChanged = Signal(str)
    loadedImageInfoChanged = Signal()

    # Map tool IDs to processor classes
    PROCESSOR_MAP = {
        'resize': ResizeProcessor,
        'crop': CropProcessor,
        'compress': CompressProcessor,
        'convert': ConvertProcessor,
        'blur_face': BlurFaceProcessor,
        'remove_bg': RemoveBgProcessor,
        'upscale': UpscaleProcessor,
    }

    def __init__(self):
        super().__init__()
        self._image = None
        self._loaded_image_info = {
            'width': 0,
            'height': 0,
            'size': '0 KB'
        }
        self._processed_image_info = {
            'width': 0,
            'height': 0,
            'size': '0 KB'
        }
        
        # Initialize processors
        self._current_processor = None
        self._processors = {}
        for tool in ToolModel.get_tools():
            processor_name = tool.code_name
            processor_cls = self.PROCESSOR_MAP.get(processor_name)
            if processor_cls:
                self._processors[processor_name] = processor_cls()
        
        # Connect processor signals
        for processor in self._processors.values():
            processor.processingStarted.connect(self.processingStarted)
            processor.processingProgress.connect(self.processingProgress)
            processor.processingCompleted.connect(self._on_processing_completed)
            processor.processingFailed.connect(self.processingFailed)
    
    @Property("QVariant", notify=loadedImageInfoChanged)
    def loadedImageInfo(self):
        return self._loaded_image_info

    @Property("QVariant", notify=processedImageInfoChanged)
    def processedImageInfo(self):
        return self._processed_image_info

    def _on_processing_completed(self, result_url):
        """Update processed image info and emit completion signal"""
        try:
            # Get processed image info
            path = QUrl(result_url).toLocalFile()
            if os.path.exists(path):
                print(f"Processing completed. Path: {path}")
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
    def setProcessor(self, tool_id: str):
        """Set the current processor"""
        print(f"Setting processor to: {tool_id}")
        tool = ToolModel.get_tool_by_id(tool_id)
        print(f"Tool: {tool}")
        processor_name = tool.code_name
        if processor_name in self._processors:
            print(f"Switching to processor: {processor_name}")
            self._current_processor = self._processors[processor_name]
            self.processorChanged.emit(processor_name)
        
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
                self._loaded_image_info = {
                    'width': self._image.width,
                    'height': self._image.height,
                    'size': size_text
                }
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

    @Slot(int)
    def compressImage(self, quality: int):
        """Compress the loaded image"""
        if not self._image:
            self.processingFailed.emit("No image loaded")
            return ""
        
        self._current_processor.compress_image(quality)
        return ""
    
    @Slot(str)
    def convertImage(self, format: str):
        """Convert the loaded image"""
        if not self._image:
            self.processingFailed.emit("No image loaded")
            return ""
        
        self._current_processor.convert_image(format)
        return ""
    
    @Slot(float, str, str)
    def blurFaces(self, opacity: float = 0.5, mask_color: str = "#3b82f6", mask_shape: str = "rectangle"):
        """Blur the loaded image"""
        if not self._image:
            self.processingFailed.emit("No image loaded")
            return ""
        
        self._current_processor.blur_faces(opacity, mask_color, mask_shape)
        return ""
    
    @Slot(str, bool)
    def removeBgImage(self, bg_color: str = "#ffffff", crop: bool = False):
        """Remove background from the loaded image"""
        if not self._image:
            self.processingFailed.emit("No image loaded")
            return ""
        
        self._current_processor.remove_bg(bg_color, crop)
        return ""
    
    @Slot(int)
    def upscaleImage(self, scale: int):
        """Upscale the loaded image"""
        if not self._image:
            self.processingFailed.emit("No image loaded")
            return ""
        
        self._current_processor.upscale_image(scale)
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