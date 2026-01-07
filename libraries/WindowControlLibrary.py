"""
Window Control Library for Robot Framework
Provides keywords to control Windows window states (minimize, maximize, restore)
"""
import ctypes
import time
from ctypes import wintypes


class WindowControlLibrary:
    """Library for controlling Windows window states"""
    
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    
    # Windows API constants
    SW_MINIMIZE = 6
    SW_MAXIMIZE = 3
    SW_RESTORE = 9
    SW_SHOW = 5
    
    def __init__(self):
        self.user32 = ctypes.windll.user32
        
    def minimize_window_by_title(self, title_substring):
        """
        Minimize a window that contains the specified text in its title.
        
        Arguments:
            title_substring: Part of the window title to search for
            
        Example:
            | Minimize Window By Title | Chrome |
            | Minimize Window By Title | dev.agilemark.io |
        """
        hwnd = self._find_window_by_title(title_substring)
        if hwnd:
            self.user32.ShowWindow(hwnd, self.SW_MINIMIZE)
            return True
        else:
            raise Exception(f"Window with title containing '{title_substring}' not found")
    
    def maximize_window_by_title(self, title_substring):
        """
        Maximize a window that contains the specified text in its title.
        
        Arguments:
            title_substring: Part of the window title to search for
            
        Example:
            | Maximize Window By Title | Chrome |
        """
        hwnd = self._find_window_by_title(title_substring)
        if hwnd:
            self.user32.ShowWindow(hwnd, self.SW_MAXIMIZE)
            return True
        else:
            raise Exception(f"Window with title containing '{title_substring}' not found")
    
    def restore_window_by_title(self, title_substring):
        """
        Restore a minimized/maximized window to normal state.
        
        Arguments:
            title_substring: Part of the window title to search for
            
        Example:
            | Restore Window By Title | Chrome |
        """
        hwnd = self._find_window_by_title(title_substring)
        if hwnd:
            self.user32.ShowWindow(hwnd, self.SW_RESTORE)
            self.user32.SetForegroundWindow(hwnd)
            return True
        else:
            raise Exception(f"Window with title containing '{title_substring}' not found")
    
    def minimize_all_browsers(self):
        """
        Minimize all common browser windows (Chrome, Firefox, Edge).
        
        Example:
            | Minimize All Browsers |
        """
        browsers = ['Chrome', 'Firefox', 'Edge', 'Chromium']
        minimized = []
        
        for browser in browsers:
            try:
                hwnd = self._find_window_by_title(browser)
                if hwnd:
                    self.user32.ShowWindow(hwnd, self.SW_MINIMIZE)
                    minimized.append(browser)
            except:
                pass
        
        return minimized
    
    def get_window_title(self, title_substring):
        """
        Get the full title of a window containing the specified text.
        
        Arguments:
            title_substring: Part of the window title to search for
            
        Returns:
            Full window title
            
        Example:
            | ${title}= | Get Window Title | Chrome |
            | Log | ${title} |
        """
        hwnd = self._find_window_by_title(title_substring)
        if hwnd:
            length = self.user32.GetWindowTextLengthW(hwnd)
            buff = ctypes.create_unicode_buffer(length + 1)
            self.user32.GetWindowTextW(hwnd, buff, length + 1)
            return buff.value
        else:
            raise Exception(f"Window with title containing '{title_substring}' not found")
    
    def _find_window_by_title(self, title_substring):
        """Find window handle by partial title match"""
        found_hwnd = [None]
        
        def enum_windows_callback(hwnd, lparam):
            if self.user32.IsWindowVisible(hwnd):
                length = self.user32.GetWindowTextLengthW(hwnd)
                if length > 0:
                    buff = ctypes.create_unicode_buffer(length + 1)
                    self.user32.GetWindowTextW(hwnd, buff, length + 1)
                    if title_substring.lower() in buff.value.lower():
                        found_hwnd[0] = hwnd
                        return False  # Stop enumeration
            return True  # Continue enumeration
        
        # Define callback type
        EnumWindowsProc = ctypes.WINFUNCTYPE(
            wintypes.BOOL,
            wintypes.HWND,
            wintypes.LPARAM
        )
        
        # Enumerate windows
        self.user32.EnumWindows(EnumWindowsProc(enum_windows_callback), 0)
        
        return found_hwnd[0]
    
    def list_all_windows(self):
        """
        List all visible window titles.
        
        Returns:
            List of window titles
            
        Example:
            | ${windows}= | List All Windows |
            | Log List | ${windows} |
        """
        windows = []
        
        def enum_windows_callback(hwnd, lparam):
            if self.user32.IsWindowVisible(hwnd):
                length = self.user32.GetWindowTextLengthW(hwnd)
                if length > 0:
                    buff = ctypes.create_unicode_buffer(length + 1)
                    self.user32.GetWindowTextW(hwnd, buff, length + 1)
                    if buff.value.strip():
                        windows.append(buff.value)
            return True
        
        EnumWindowsProc = ctypes.WINFUNCTYPE(
            wintypes.BOOL,
            wintypes.HWND,
            wintypes.LPARAM
        )
        
        self.user32.EnumWindows(EnumWindowsProc(enum_windows_callback), 0)
        
        return windows
