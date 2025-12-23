"""
VideoRecorderLibrary - Robot Framework Library for Screen Recording
Provides screen recording capabilities with HTML report embedding
"""

import os
import cv2
import numpy as np
import threading
import time
from datetime import datetime
from pathlib import Path
from typing import Optional
from PIL import ImageGrab
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn


class VideoRecorderLibrary:
    """Library for recording screen during test execution and embedding in reports.
    
    This library provides keywords for starting and stopping video recording,
    with results embedded in Robot Framework HTML reports.
    """
    
    ROBOT_LIBRARY_SCOPE = 'TEST'
    ROBOT_LIBRARY_VERSION = '1.0.0'
    
    def __init__(self):
        self.recording = False
        self.video_writer = None
        self.record_thread = None
        self.output_dir = None
        self.current_video_path = None
        self.fps = 10.0
        
    def _get_output_dir(self) -> Path:
        """Get the Robot Framework output directory."""
        if self.output_dir is None:
            builtin = BuiltIn()
            try:
                output_dir = builtin.get_variable_value('${OUTPUT DIR}')
                self.output_dir = Path(output_dir)
            except:
                self.output_dir = Path.cwd() / 'results'
        
        self.output_dir.mkdir(parents=True, exist_ok=True)
        return self.output_dir
    
    def start_video_recording(self, filename: Optional[str] = None, fps: float = 10.0):
        """Start recording the screen.
        
        Args:
            filename: Optional filename for the video (without extension). 
                     If not provided, will use timestamp.
            fps: Frames per second for the recording (default: 10.0)
        
        Example:
            | Start Video Recording |
            | Start Video Recording | my_test_video |
            | Start Video Recording | my_test_video | 15.0 |
        """
        if self.recording:
            logger.warn("Video recording is already in progress. Stopping previous recording.")
            self.stop_video_recording()
        
        self.fps = fps
        output_dir = self._get_output_dir()
        
        # Create video subdirectory
        video_dir = output_dir / 'video'
        video_dir.mkdir(parents=True, exist_ok=True)
        
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"video_{timestamp}"
        
        # Ensure filename doesn't have extension
        filename = Path(filename).stem
        
        self.current_video_path = video_dir / f"{filename}.mp4"
        
        # Get screen size
        screen = ImageGrab.grab()
        screen_size = screen.size
        
        # Initialize video writer
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        self.video_writer = cv2.VideoWriter(
            str(self.current_video_path),
            fourcc,
            self.fps,
            screen_size
        )
        
        if not self.video_writer.isOpened():
            raise RuntimeError(f"Failed to open video writer for {self.current_video_path}")
        
        self.recording = True
        
        # Start recording in a separate thread
        self.record_thread = threading.Thread(target=self._record_screen, daemon=True)
        self.record_thread.start()
        
        logger.info(f"Started video recording: {self.current_video_path}")
    
    def _record_screen(self):
        """Internal method to capture screen frames in a loop."""
        frame_interval = 1.0 / self.fps
        
        while self.recording:
            start_time = time.time()
            
            try:
                # Capture screen
                screen = ImageGrab.grab()
                frame = np.array(screen)
                # Convert RGB to BGR for OpenCV
                frame = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
                
                # Write frame
                if self.video_writer is not None:
                    self.video_writer.write(frame)
                
            except Exception as e:
                logger.warn(f"Error capturing frame: {e}")
            
            # Wait for next frame
            elapsed = time.time() - start_time
            sleep_time = max(0, frame_interval - elapsed)
            time.sleep(sleep_time)
    
    def stop_video_recording(self):
        """Stop recording and embed video in the report.
        
        Example:
            | Stop Video Recording |
        """
        if not self.recording:
            logger.warn("No video recording in progress.")
            return None
        
        self.recording = False
        
        # Wait for recording thread to finish
        if self.record_thread is not None:
            self.record_thread.join(timeout=2.0)
        
        # Release video writer
        if self.video_writer is not None:
            self.video_writer.release()
            self.video_writer = None
        
        logger.info(f"Stopped video recording: {self.current_video_path}")
        
        # Embed video in report
        if self.current_video_path and self.current_video_path.exists():
            self._embed_video_in_report(self.current_video_path)
            return str(self.current_video_path)
        
        return None
    
    def _embed_video_in_report(self, video_path: Path):
        """Embed video in Robot Framework HTML report."""
        try:
            # Get relative path for embedding
            output_dir = self._get_output_dir()
            try:
                rel_path = video_path.relative_to(output_dir)
            except ValueError:
                rel_path = Path('video') / video_path.name
            
            # Create HTML for video player
            video_html = f'''
            <div style="margin: 10px 0; padding: 10px; border: 1px solid #ddd; border-radius: 5px; background-color: #f9f9f9;">
                <h4 style="margin-top: 0;">Test Execution Video</h4>
                <video width="800" controls style="max-width: 100%;">
                    <source src="{rel_path}" type="video/mp4">
                    Your browser does not support the video tag.
                </video>
                <p style="margin-bottom: 0; font-size: 12px; color: #666;">
                    Video: {video_path.name} | Size: {video_path.stat().st_size / (1024*1024):.2f} MB
                </p>
            </div>
            '''
            
            logger.info(video_html, html=True)
            
        except Exception as e:
            logger.warn(f"Failed to embed video in report: {e}")
    
    def get_video_path(self) -> Optional[str]:
        """Get the path of the current/last recorded video.
        
        Returns:
            Path to the video file, or None if no recording exists.
        
        Example:
            | ${video_path}= | Get Video Path |
        """
        if self.current_video_path and self.current_video_path.exists():
            return str(self.current_video_path)
        return None
