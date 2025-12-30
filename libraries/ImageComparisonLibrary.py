"""
ImageComparisonLibrary - Robot Framework Library for Visual Testing
Provides image comparison capabilities with detailed reporting
"""

import os
import base64
from datetime import datetime
from pathlib import Path
from typing import Tuple, Optional
from io import BytesIO

try:
    from PIL import Image, ImageDraw, ImageFont, ImageChops
    import cv2
    import numpy as np
except ImportError as e:
    raise ImportError(f"Required libraries not installed: {e}. Please install Pillow and opencv-python.")

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn


class ImageComparisonLibrary:
    """Library for comparing images and generating visual comparison reports.
    
    This library provides keywords for comparing expected and actual images,
    with results embedded in Robot Framework HTML reports.
    """
    
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = '1.0.0'
    
    def __init__(self):
        self.comparison_results = []
        self.output_dir = None
        
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
    
    def _encode_image_to_base64(self, image_path: str) -> str:
        """Encode image to base64 for embedding in HTML."""
        with open(image_path, 'rb') as f:
            return base64.b64encode(f.read()).decode('utf-8')
    
    def _calculate_similarity_ssim(self, img1: np.ndarray, img2: np.ndarray) -> float:
        """Calculate Structural Similarity Index (SSIM) between two images."""
        if img1.shape != img2.shape:
            raise ValueError("Images must have the same dimensions for SSIM")
        
        # Convert to grayscale if needed
        if len(img1.shape) == 3:
            img1 = cv2.cvtColor(img1, cv2.COLOR_BGR2GRAY)
        if len(img2.shape) == 3:
            img2 = cv2.cvtColor(img2, cv2.COLOR_BGR2GRAY)
        
        # Compute SSIM
        from skimage.metrics import structural_similarity
        score, diff = structural_similarity(img1, img2, full=True)
        return score * 100
    
    def _calculate_similarity_mse(self, img1: np.ndarray, img2: np.ndarray) -> float:
        """Calculate Mean Squared Error based similarity."""
        mse = np.mean((img1.astype(float) - img2.astype(float)) ** 2)
        max_pixel_value = 255.0
        max_mse = max_pixel_value ** 2
        similarity = (1 - (mse / max_mse)) * 100
        return max(0, similarity)
    
    def _create_diff_image(self, img1_path: str, img2_path: str, output_path: str) -> str:
        """Create a highly detailed visual difference image with pixel-by-pixel comparison."""
        img1 = cv2.imread(img1_path)
        img2 = cv2.imread(img2_path)
        
        # Ensure images are the same size
        if img1.shape != img2.shape:
            img2 = cv2.resize(img2, (img1.shape[1], img1.shape[0]))
        
        h, w = img1.shape[:2]
        
        # Create a comparison image (2 panels side by side: Heatmap and Overlay)
        comparison_height = h + 60  # Extra space for labels
        comparison_width = w * 2 + 90  # Two panels with margins
        comparison = np.ones((comparison_height, comparison_width, 3), dtype=np.uint8) * 255
        
        # Panel positions
        margin = 30
        
        # Calculate pixel differences
        diff_abs = cv2.absdiff(img1, img2)
        diff_gray = cv2.cvtColor(diff_abs, cv2.COLOR_BGR2GRAY)
        
        # Count different pixels
        diff_mask = diff_gray > 0  # Any difference at all
        diff_pixels = np.sum(diff_mask)
        total_pixels = h * w
        diff_percentage = (diff_pixels / total_pixels) * 100
        
        # --- Panel 1: Pixel-Perfect Absolute Difference Heatmap (Left) ---
        diff_heatmap = cv2.applyColorMap(diff_gray, cv2.COLORMAP_JET)
        comparison[margin:margin+h, margin:margin+w] = diff_heatmap
        label = f'DIFFERENCE HEATMAP ({diff_pixels} pixels, {diff_percentage:.2f}%)'
        cv2.putText(comparison, label, (margin+5, margin-10), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 0), 2)
        
        # --- Panel 2: High-Contrast Difference Overlay (Right) ---
        diff_overlay = img1.copy()
        
        # Create mask with different thresholds for different colors
        # Very subtle differences (1-10): Yellow
        subtle_diff = (diff_gray > 0) & (diff_gray <= 10)
        diff_overlay[subtle_diff] = [0, 255, 255]  # Yellow
        
        # Moderate differences (11-50): Orange
        moderate_diff = (diff_gray > 10) & (diff_gray <= 50)
        diff_overlay[moderate_diff] = [0, 165, 255]  # Orange
        
        # Significant differences (>50): Red
        significant_diff = diff_gray > 50
        diff_overlay[significant_diff] = [0, 0, 255]  # Red
        
        # Add bounding boxes around difference regions
        contours, _ = cv2.findContours(diff_gray, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        for contour in contours:
            if cv2.contourArea(contour) > 5:  # Filter very small noise
                x, y, w_box, h_box = cv2.boundingRect(contour)
                cv2.rectangle(diff_overlay, (x, y), (x + w_box, y + h_box), (255, 0, 255), 2)
        
        comparison[margin:margin+h, margin*2+w:margin*2+w*2] = diff_overlay
        cv2.putText(comparison, 'DIFFERENCES OVERLAY', (margin*2+w+5, margin-10), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 0), 2)
        
        # Add legend for overlay at the bottom
        legend_y = margin + h + 10
        legend_x = margin*2 + w + 10
        
        cv2.rectangle(comparison, (legend_x, legend_y), (legend_x+20, legend_y+15), (0, 255, 255), -1)
        cv2.putText(comparison, 'Subtle (1-10)', (legend_x+25, legend_y+12), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.4, (0, 0, 0), 1)
        
        cv2.rectangle(comparison, (legend_x+150, legend_y), (legend_x+170, legend_y+15), (0, 165, 255), -1)
        cv2.putText(comparison, 'Moderate (11-50)', (legend_x+175, legend_y+12), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.4, (0, 0, 0), 1)
        
        cv2.rectangle(comparison, (legend_x+330, legend_y), (legend_x+350, legend_y+15), (0, 0, 255), -1)
        cv2.putText(comparison, 'Significant (>50)', (legend_x+355, legend_y+12), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.4, (0, 0, 0), 1)
        
        cv2.imwrite(output_path, comparison)
        
        # Also save individual diff files for detailed analysis
        output_dir = Path(output_path).parent
        base_name = Path(output_path).stem
        
        # Save raw difference image
        cv2.imwrite(str(output_dir / f"{base_name}_raw_diff.png"), diff_abs)
        
        # Save difference mask (binary)
        diff_binary = np.zeros_like(img1)
        diff_binary[diff_mask] = [255, 255, 255]
        cv2.imwrite(str(output_dir / f"{base_name}_mask.png"), diff_binary)
        
        # Log statistics
        logger.info(f"Pixel-by-pixel comparison: {diff_pixels}/{total_pixels} pixels differ ({diff_percentage:.4f}%)")
        
        return output_path
    
    def _log_comparison_html(self, expected_path: str, actual_path: str, diff_path: str,
                            similarity: float, method: str, passed: bool):
        """Log comparison results as HTML in Robot Framework report."""
        
        expected_b64 = self._encode_image_to_base64(expected_path)
        actual_b64 = self._encode_image_to_base64(actual_path)
        diff_b64 = self._encode_image_to_base64(diff_path)
        
        status_color = "green" if passed else "red"
        status_text = "PASS" if passed else "FAIL"
        
        html = f"""
        <div style="border: 2px solid {status_color}; padding: 15px; margin: 10px 0; border-radius: 5px;">
            <h3 style="color: {status_color}; margin-top: 0;">Image Comparison: {status_text}</h3>
            <p><strong>Similarity Score:</strong> {similarity:.2f}% (Method: {method})</p>
            <p><strong>Expected Image:</strong> {os.path.basename(expected_path)}</p>
            <p><strong>Actual Image:</strong> {os.path.basename(actual_path)}</p>
            
            <div style="display: flex; gap: 10px; flex-wrap: wrap; margin-top: 15px;">
                <div style="flex: 1; min-width: 250px;">
                    <h4>Expected</h4>
                    <img src="data:image/png;base64,{expected_b64}" 
                         style="max-width: 100%; border: 1px solid #ccc;" 
                         alt="Expected Image"/>
                </div>
                <div style="flex: 1; min-width: 250px;">
                    <h4>Actual</h4>
                    <img src="data:image/png;base64,{actual_b64}" 
                         style="max-width: 100%; border: 1px solid #ccc;" 
                         alt="Actual Image"/>
                </div>
                <div style="flex: 1; min-width: 250px;">
                    <h4>Differences (Red)</h4>
                    <img src="data:image/png;base64,{diff_b64}" 
                         style="max-width: 100%; border: 1px solid #ccc;" 
                         alt="Difference Image"/>
                </div>
            </div>
        </div>
        """
        
        logger.info(html, html=True)
    
    def compare_images(self, expected_image: str, actual_image: str, 
                      threshold: float = 95.0, method: str = 'mse') -> bool:
        """Compare two images and return True if similarity is above threshold.
        
        Args:
            expected_image: Path to the expected/reference image
            actual_image: Path to the actual/captured image
            threshold: Minimum similarity percentage (0-100) for test to pass
            method: Comparison method - 'mse' (default) or 'ssim'
        
        Returns:
            True if images are similar above threshold, False otherwise
            
        Examples:
        | ${result}= | Compare Images | ${EXPECTED_IMG} | ${ACTUAL_IMG} | 95.0 |
        | Should Be True | ${result} | Images do not match expected |
        """
        
        expected_path = Path(expected_image)
        actual_path = Path(actual_image)
        
        if not expected_path.exists():
            raise FileNotFoundError(f"Expected image not found: {expected_image}")
        if not actual_path.exists():
            raise FileNotFoundError(f"Actual image not found: {actual_image}")
        
        # Load images
        img1 = cv2.imread(str(expected_path))
        img2 = cv2.imread(str(actual_path))
        
        if img1 is None:
            raise ValueError(f"Could not load expected image: {expected_image}")
        if img2 is None:
            raise ValueError(f"Could not load actual image: {actual_image}")
        
        # Resize if dimensions don't match
        if img1.shape != img2.shape:
            logger.warn(f"Image dimensions differ. Resizing actual image to match expected. "
                       f"Expected: {img1.shape}, Actual: {img2.shape}")
            img2 = cv2.resize(img2, (img1.shape[1], img1.shape[0]))
        
        # Calculate similarity
        if method.lower() == 'ssim':
            try:
                from skimage.metrics import structural_similarity
                similarity = self._calculate_similarity_ssim(img1, img2)
            except ImportError:
                logger.warn("scikit-image not installed. Falling back to MSE method.")
                similarity = self._calculate_similarity_mse(img1, img2)
        else:
            similarity = self._calculate_similarity_mse(img1, img2)
        
        # Create difference image
        output_dir = self._get_output_dir()

        # Create diff subdirectory
        diff_dir = output_dir / 'diff'
        diff_dir.mkdir(parents=True, exist_ok=True)

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        diff_filename = f"diff_{timestamp}.png"
        diff_path = diff_dir / diff_filename
        
        self._create_diff_image(str(expected_path), str(actual_path), str(diff_path))
        
        # Determine pass/fail
        passed = similarity >= threshold
        
        # Log results with embedded images
        self._log_comparison_html(
            str(expected_path), 
            str(actual_path), 
            str(diff_path),
            similarity, 
            method.upper(), 
            passed
        )
        
        # Log text summary
        logger.info(f"Image Comparison Result: Similarity={similarity:.2f}%, "
                   f"Threshold={threshold}%, Status={'PASS' if passed else 'FAIL'}")
        
        return passed
    
    def compare_images_and_fail_if_different(self, expected_image: str, actual_image: str,
                                            threshold: float = 95.0, method: str = 'mse',
                                            message: Optional[str] = None):
        """Compare images and fail the test if similarity is below threshold.
        
        This is a convenience keyword that combines comparison and assertion.
        
        Args:
            expected_image: Path to the expected/reference image
            actual_image: Path to the actual/captured image
            threshold: Minimum similarity percentage (0-100) for test to pass
            method: Comparison method - 'mse' (default) or 'ssim'
            message: Custom failure message (optional)
            
        Examples:
        | Compare Images And Fail If Different | ${EXPECTED} | ${ACTUAL} | 95.0 |
        | Compare Images And Fail If Different | ${EXPECTED} | ${ACTUAL} | 90.0 | ssim | Custom error message |
        """
        
        result = self.compare_images(expected_image, actual_image, threshold, method)
        
        if not result:
            if message is None:
                message = (f"Image comparison failed: Similarity below {threshold}%. "
                          f"Expected: {expected_image}, Actual: {actual_image}")
            raise AssertionError(message)
    
    def capture_screen_region(self, x: int, y: int, width: int, height: int, 
                             output_path: Optional[str] = None) -> str:
        """Capture a specific region of the screen.
        
        Args:
            x: X coordinate of top-left corner
            y: Y coordinate of top-left corner
            width: Width of the region
            height: Height of the region
            output_path: Path to save the screenshot (optional)
            
        Returns:
            Path to the captured screenshot
            
        Examples:
        | ${screenshot}= | Capture Screen Region | 100 | 100 | 400 | 300 |
        | ${screenshot}= | Capture Screen Region | 0 | 0 | 800 | 600 | ${OUTPUT_DIR}/screenshot.png |
        """
        try:
            import pyautogui
        except ImportError:
            raise ImportError("pyautogui not installed. Install it with: pip install pyautogui")
        
        screenshot = pyautogui.screenshot(region=(x, y, width, height))
        
        if output_path is None:
            output_dir = self._get_output_dir()
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_path = output_dir / f"screen_capture_{timestamp}.png"
        
        screenshot.save(str(output_path))
        
        # Log the captured image to the report
        img_b64 = self._encode_image_to_base64(str(output_path))
        html = f"""
        <div style="border: 2px solid #2196F3; padding: 15px; margin: 10px 0; border-radius: 5px;">
            <h3 style="color: #2196F3; margin-top: 0;">Screen Capture</h3>
            <p><strong>Region:</strong> x={x}, y={y}, width={width}, height={height}</p>
            <p><strong>Saved to:</strong> {os.path.basename(str(output_path))}</p>
            <div style="margin-top: 10px;">
                <img src="data:image/png;base64,{img_b64}" 
                     style="max-width: 100%; border: 1px solid #ccc;" 
                     alt="Captured Screenshot"/>
            </div>
        </div>
        """
        logger.info(html, html=True)
        logger.info(f"Screen region captured: {output_path}")
        
        return str(output_path)
    
    def get_image_similarity_score(self, image1: str, image2: str, method: str = 'mse') -> float:
        """Get the similarity score between two images without passing/failing.
        
        Args:
            image1: Path to first image
            image2: Path to second image
            method: Comparison method - 'mse' (default) or 'ssim'
            
        Returns:
            Similarity score as a percentage (0-100)
            
        Examples:
        | ${score}= | Get Image Similarity Score | ${IMG1} | ${IMG2} |
        | Log | Similarity: ${score}% |
        """
        
        img1 = cv2.imread(str(image1))
        img2 = cv2.imread(str(image2))
        
        if img1 is None or img2 is None:
            raise ValueError("Could not load one or both images")
        
        if img1.shape != img2.shape:
            img2 = cv2.resize(img2, (img1.shape[1], img1.shape[0]))
        
        if method.lower() == 'ssim':
            try:
                from skimage.metrics import structural_similarity
                similarity = self._calculate_similarity_ssim(img1, img2)
            except ImportError:
                logger.warn("scikit-image not installed. Falling back to MSE method.")
                similarity = self._calculate_similarity_mse(img1, img2)
        else:
            similarity = self._calculate_similarity_mse(img1, img2)
        
        return similarity
