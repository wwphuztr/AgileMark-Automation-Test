"""
Custom Python library for SikuliX integration with Robot Framework
Provides additional helper functions for image-based automation
"""

from robot.api import logger
from robot.api.deco import keyword
import os
import time


class SikuliHelper:
    """Custom library extending SikuliX functionality"""
    
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    
    def __init__(self):
        """Initialize SikuliHelper library"""
        self.image_dir = None
        logger.info("SikuliHelper library initialized")
    
    @keyword
    def set_image_directory(self, directory):
        """Set the default directory for image files
        
        Args:
            directory: Path to the image directory
        """
        if not os.path.exists(directory):
            raise ValueError(f"Directory does not exist: {directory}")
        self.image_dir = directory
        logger.info(f"Image directory set to: {directory}")
    
    @keyword
    def get_image_path(self, image_name):
        """Get full path for an image file
        
        Args:
            image_name: Name of the image file
            
        Returns:
            Full path to the image file
        """
        if self.image_dir is None:
            raise ValueError("Image directory not set. Use 'Set Image Directory' keyword first.")
        
        image_path = os.path.join(self.image_dir, image_name)
        if not os.path.exists(image_path):
            logger.warn(f"Image file not found: {image_path}")
        
        return image_path
    
    @keyword
    def wait_and_retry(self, keyword_name, *args, max_retries=3, retry_interval=2):
        """Retry a keyword multiple times if it fails
        
        Args:
            keyword_name: Name of the keyword to retry
            args: Arguments for the keyword
            max_retries: Maximum number of retry attempts
            retry_interval: Seconds to wait between retries
        """
        from robot.libraries.BuiltIn import BuiltIn
        builtin = BuiltIn()
        
        for attempt in range(max_retries):
            try:
                logger.info(f"Attempt {attempt + 1} of {max_retries}")
                builtin.run_keyword(keyword_name, *args)
                logger.info(f"Keyword '{keyword_name}' succeeded on attempt {attempt + 1}")
                return True
            except Exception as e:
                logger.warn(f"Attempt {attempt + 1} failed: {str(e)}")
                if attempt < max_retries - 1:
                    time.sleep(retry_interval)
                else:
                    raise
        
        return False
    
    @keyword
    def verify_image_exists(self, image_path):
        """Verify that an image file exists on disk
        
        Args:
            image_path: Path to the image file
            
        Returns:
            True if image exists, False otherwise
        """
        exists = os.path.exists(image_path)
        if exists:
            logger.info(f"Image file exists: {image_path}")
        else:
            logger.error(f"Image file not found: {image_path}")
        return exists
    
    @keyword
    def list_images_in_directory(self, directory=None):
        """List all image files in a directory
        
        Args:
            directory: Directory to search (uses default if None)
            
        Returns:
            List of image filenames
        """
        if directory is None:
            directory = self.image_dir
        
        if directory is None or not os.path.exists(directory):
            raise ValueError(f"Invalid directory: {directory}")
        
        image_extensions = ['.png', '.jpg', '.jpeg', '.bmp', '.gif']
        images = [f for f in os.listdir(directory) 
                 if os.path.splitext(f)[1].lower() in image_extensions]
        
        logger.info(f"Found {len(images)} images in {directory}")
        return images
    
    @keyword
    def create_timestamped_filename(self, prefix, extension='.png'):
        """Create a filename with timestamp
        
        Args:
            prefix: Prefix for the filename
            extension: File extension
            
        Returns:
            Filename with timestamp
        """
        timestamp = time.strftime("%Y%m%d_%H%M%S")
        filename = f"{prefix}_{timestamp}{extension}"
        logger.info(f"Generated filename: {filename}")
        return filename
