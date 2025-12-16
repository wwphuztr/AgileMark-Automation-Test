# AgileMark Automation Test

A comprehensive test automation framework using **Robot Framework** and **SikuliX** for image-based UI testing.

## 📁 Project Structure

```
AgileMark-Automation-Test/
├── tests/                          # Test suite files
│   ├── example_sikuli_test.robot   # Basic SikuliX examples
│   └── ui_automation_test.robot    # UI automation test cases
├── keywords/                       # Reusable custom keywords
│   └── sikuli_keywords.robot       # SikuliX-specific keywords
├── resources/                      # Resource files
│   ├── common.robot                # Common resources and setup/teardown
│   └── variables.robot             # Global variables and configurations
├── libraries/                      # Custom Python libraries
│   └── SikuliHelper.py             # Helper functions for SikuliX
├── images/                         # Reference images for SikuliX
│   └── (place your PNG images here)
├── results/                        # Test execution results and logs
├── requirements.txt                # Python dependencies
└── robot.config                    # Robot Framework configuration
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
robot tests/example_sikuli_test.robot
```

**Run tests with specific tags:**
```powershell
robot --include sikuli tests/
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

### Capturing Reference Images

1. Use SikuliX IDE to capture UI elements
2. Save images with descriptive names (e.g., `login_button.png`, `menu_icon.png`)
3. Place images in the `images/` directory
4. Reference in tests using `${IMAGE_DIR}/image_name.png`

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
