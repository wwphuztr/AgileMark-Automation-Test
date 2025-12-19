# AgileMark Automation Test

A comprehensive test automation framework using **Robot Framework** and **SikuliX** for image-based UI testing, with advanced **Image Comparison** capabilities for visual testing and validation.

## 📁 Project Structure

```
AgileMark-Automation-Test/
├── tests/                          # Test suite files
│   ├── demo-agilemark-examples.robot      # AgileMark installation/uninstallation tests
│   └── image-comparison-examples.robot    # ✨ NEW: Image comparison examples
├── keywords/                       # Reusable custom keywords
│   └── sikuli_keywords.robot       # SikuliX-specific keywords
├── resources/                      # Resource files
│   ├── common.robot                # Common resources and setup/teardown
│   ├── variables.robot             # Global variables and configurations
│   └── Images/
│       └── expected/               # ✨ NEW: Expected reference images for visual testing
├── libraries/                      # Custom Python libraries
│   ├── SikuliHelper.py             # Helper functions for SikuliX
│   ├── ImageComparisonLibrary.py   # ✨ NEW: Image comparison library
│   └── IMAGE_COMPARISON_GUIDE.md   # ✨ NEW: Comprehensive guide
├── images/                         # Reference images for SikuliX
│   └── (place your PNG images here)
├── results/                        # Test execution results and logs
│   ├── actual_screenshots/         # ✨ NEW: Captured screenshots
│   ├── diff_*.png                  # ✨ NEW: Visual difference images
│   ├── report.html                 # HTML report with visual comparisons
│   └── log.html
├── requirements.txt                # Python dependencies
├── robot.config                    # Robot Framework configuration
├── QUICK_START_IMAGE_COMPARISON.md # ✨ NEW: Quick reference guide
├── HOW_TO_USE_IMAGE_COMPARISON.md  # ✨ NEW: Integration guide
└── IMPLEMENTATION_SUMMARY.md       # ✨ NEW: Feature summary
```

## 🚀 Getting Started

### Prerequisites

1. **Python 3.8+** installed
2. **Java JDK 11+** installed (required for SikuliX)
3. **SikuliX** installed ([Download here](http://sikulix.com/))

### Installation

1. **Clone or navigate to the project directory:**
   ```powershell
   cd C:\Users\aioz\Desktop\Agilemark\AgileMark-Automation-Test
   ```

2. **Install Python dependencies:**
   ```powershell
   pip install -r requirements.txt
   ```

3. **Verify SikuliX installation:**
   - Ensure `sikulixide.jar` is accessible
   - Update the path in `robot.config` if needed

## 📝 Usage

### Running Tests

**Run all tests:**
```powershell
robot tests/
```

**Run specific test suite:**
```powershell
robot tests/demo-agilemark-examples.robot
```

**Run image comparison examples:**
```powershell
robot tests/image-comparison-examples.robot
```

**Run tests with specific tags:**
```powershell
robot --include sikuli tests/
robot --include visual-test tests/
robot --include image-comparison tests/
```

**Run tests with custom output directory:**
```powershell
robot --outputdir results tests/
```

### Parallel Execution

Run tests in parallel using pabot:
```powershell
pabot --processes 4 tests/
```

## 🖼️ Working with Images

### Capturing Reference Images (SikuliX)

1. Use SikuliX IDE to capture UI elements
2. Save images with descriptive names (e.g., `login_button.png`, `menu_icon.png`)
3. Place images in the `images/` directory
4. Reference in tests using `${IMAGE_DIR}/image_name.png`

## ✨ NEW: Image Comparison Feature

### Visual Testing with Expected vs Actual Comparison

This framework now includes a powerful **ImageComparisonLibrary** that enables visual regression testing with beautiful reports.

#### Quick Start

```robotframework
*** Settings ***
Library    ../libraries/ImageComparisonLibrary.py

*** Test Cases ***
Verify UI Appearance
    ${actual}=    Capture Screen Region    100    100    600    400
    Compare Images And Fail If Different    
    ...    ${EXPECTED_DIR}/dialog.png    
    ...    ${actual}    
    ...    95.0
```

#### Key Features

- ✅ **Side-by-side comparison** in HTML reports
- ✅ **Visual difference highlighting** (red markers show changes)
- ✅ **Multiple comparison algorithms** (MSE and SSIM)
- ✅ **Configurable similarity thresholds** (0-100%)
- ✅ **Screen region capture** functionality
- ✅ **Automatic image resizing** for dimension mismatches
- ✅ **Base64 image embedding** in reports (no external files needed)

#### Available Keywords

| Keyword | Description |
|---------|-------------|
| `Compare Images` | Compare two images and return True/False |
| `Compare Images And Fail If Different` | Compare and auto-fail test if different |
| `Capture Screen Region` | Capture specific screen area |
| `Get Image Similarity Score` | Get similarity percentage without pass/fail |

#### What You Get in Reports

When you run tests with image comparison, the HTML report displays:
- Expected image (your reference)
- Actual image (captured during test)
- Difference image (red highlights show what changed)
- Similarity score percentage
- Pass/Fail status with color coding

#### Documentation

- **Quick Start**: `QUICK_START_IMAGE_COMPARISON.md` - Get started in 3 steps
- **How to Use**: `HOW_TO_USE_IMAGE_COMPARISON.md` - Real-world integration examples
- **Full Guide**: `libraries/IMAGE_COMPARISON_GUIDE.md` - Comprehensive documentation
- **Examples**: `tests/image-comparison-examples.robot` - Working test examples
- **Summary**: `IMPLEMENTATION_SUMMARY.md` - Complete feature overview

#### Example Usage

```robotframework
*** Settings ***
Library    ../libraries/ImageComparisonLibrary.py

*** Test Cases ***
Verify AgileMark Installer Dialog
    [Tags]    visual-test    installation
    
    # Open installer
    Open Application    installer.msi
    Sleep    2s
    
    # Capture the dialog
    ${actual}=    Capture Screen Region    200    150    600    400
    
    # Compare with expected (shows in HTML report with images)
    Compare Images And Fail If Different    
    ...    ${EXPECTED_DIR}/installer_dialog.png    
    ...    ${actual}    
    ...    95.0
```

#### Try It Now

```powershell
# Run image comparison examples
robot --outputdir results tests/image-comparison-examples.robot

# View the beautiful visual comparison report
Start-Process results\report.html
```

### Image Naming Convention

- Use lowercase with underscores
- Be descriptive: `submit_button.png` not `btn1.png`
- Include context: `login_username_field.png`

## 🔧 Configuration

### Variables (`resources/variables.robot`)

Update these variables for your environment:
- `${APP_PATH}` - Path to your application
- `${SIKULI_TIMEOUT}` - Default timeout for image recognition
- `${SIMILARITY}` - Image matching similarity (0.0 to 1.0)

### SikuliX Settings (`robot.config`)

Configure SikuliX paths and settings:
- `sikuli_jar_path` - Path to sikulixide.jar
- `similarity_threshold` - Image matching threshold

## 📊 Test Reports

After execution, find reports in the `results/` directory:
- `report.html` - Detailed test report
- `log.html` - Execution log with keywords
- `output.xml` - Machine-readable results

## 🎯 Example Test Cases

### Basic Image Click
```robot
*** Test Cases ***
Click Button Example
    Click Image    ${IMAGE_DIR}/button.png
    Wait Until Screen Contain    ${IMAGE_DIR}/result.png
```

### Form Filling
```robot
*** Test Cases ***
Fill Login Form
    Click Image    ${IMAGE_DIR}/username_field.png
    Input Text    myusername
    Click Image    ${IMAGE_DIR}/password_field.png
    Input Text    mypassword
    Click Image    ${IMAGE_DIR}/login_button.png
```

## 🛠️ Custom Keywords

Create reusable keywords in `keywords/sikuli_keywords.robot`:

```robot
*** Keywords ***
Login To Application
    [Arguments]    ${username}    ${password}
    Click Image    ${IMAGE_DIR}/username_field.png
    Input Text    ${username}
    Click Image    ${IMAGE_DIR}/password_field.png
    Input Text    ${password}
    Click Image    ${IMAGE_DIR}/login_button.png
```

## 🐛 Troubleshooting

### SikuliX Issues

1. **Java not found**: Ensure Java is in PATH
2. **Image not recognized**: Adjust `${SIMILARITY}` value
3. **Timeout errors**: Increase `${SIKULI_TIMEOUT}`

### Common Solutions

- **Screen resolution**: Capture images at target resolution
- **Image quality**: Use PNG format with good contrast
- **Dynamic UI**: Use multiple image variants or regions

## 📚 Additional Resources

- [Robot Framework Documentation](https://robotframework.org/)
- [SikuliX Documentation](http://sikulix.com/)
- [Robot Framework User Guide](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html)

## 🤝 Contributing

1. Create descriptive test cases
2. Use meaningful variable names
3. Add documentation to custom keywords
4. Keep images organized in subdirectories
5. Follow Robot Framework style guide

## 📄 License

This project is for internal use at AgileMark.

---

**Happy Testing! 🎉**
