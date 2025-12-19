@echo off
REM Run Robot Framework tests

echo ===================================
echo AgileMark Automation Test Runner
echo ===================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    exit /b 1
)

REM Check if Robot Framework is installed
robot --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Robot Framework is not installed
    echo Please run: pip install -r requirements.txt
    exit /b 1
)

REM Create results directory if it doesn't exist
if not exist "results" mkdir results

REM Run tests
echo Running tests with TRACE level for detailed debugging...
echo Console output will be saved to: results\console.log
echo.

robot --outputdir results --loglevel TRACE --listener RobotStackTracer tests/ > results\console.log 2>&1

echo.
echo ===================================
echo Test execution completed!
echo ===================================
echo.
echo View results in: results\report.html
echo Console log saved to: results\console.log
echo.

pause
