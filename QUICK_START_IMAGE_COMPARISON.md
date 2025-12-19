# Image Comparison - Quick Start Guide

## ✅ Installation Complete!

All required packages have been installed:
- ✅ Pillow (Image processing)
- ✅ OpenCV (Computer vision)
- ✅ scikit-image (SSIM algorithm)
- ✅ PyAutoGUI (Screen capture)
- ✅ NumPy (Array operations)

## 🚀 Quick Start - 3 Steps

### Step 1: Import the Library
Add to your test file's Settings section:
```robotframework
Library    ../libraries/ImageComparisonLibrary.py
```

### Step 2: Capture a Screenshot
```robotframework
${actual}=    Capture Screen Region    100    100    400    300    ${OUTPUT_DIR}/screenshot.png
```

### Step 3: Compare with Expected Image
```robotframework
Compare Images And Fail If Different    expected.png    ${actual}    95.0
```

## 📊 What You'll See in Reports

After running tests with image comparison, your `report.html` will show:

```
┌──────────────────────────────────────────────────────────┐
│ Image Comparison: PASS ✓                                 │
│ Similarity Score: 97.5% (Method: MSE)                    │
├──────────────────────────────────────────────────────────┤
│                                                           │
│  Expected          Actual           Differences          │
│  ┌────────┐       ┌────────┐       ┌────────┐          │
│  │ [IMG]  │       │ [IMG]  │       │ [IMG]  │          │
│  │        │       │        │       │  (red  │          │
│  └────────┘       └────────┘       │ marks) │          │
│                                     └────────┘          │
└──────────────────────────────────────────────────────────┘
```

## 📝 Available Keywords

| Keyword | Purpose | Example |
|---------|---------|---------|
| `Compare Images` | Compare two images | `${result}=  Compare Images  exp.png  act.png  95.0` |
| `Compare Images And Fail If Different` | Compare and auto-fail | `Compare Images And Fail If Different  exp.png  act.png  95.0` |
| `Capture Screen Region` | Capture screen area | `${img}=  Capture Screen Region  0  0  800  600` |
| `Get Image Similarity Score` | Get score only | `${score}=  Get Image Similarity Score  img1.png  img2.png` |

## 🎯 Common Use Cases

### Use Case 1: Verify UI Element Appearance
```robotframework
*** Test Cases ***
Verify Login Dialog
    ${actual}=    Capture Screen Region    200    150    400    300
    Compare Images And Fail If Different    
    ...    ${EXPECTED_DIR}/login_dialog.png
    ...    ${actual}
    ...    95.0
```

### Use Case 2: Verify Button State Change
```robotframework
*** Test Cases ***
Verify Button Changes Color
    ${before}=    Capture Screen Region    300    400    100    50
    Click    ${SOME_BUTTON}
    ${after}=    Capture Screen Region    300    400    100    50
    ${score}=    Get Image Similarity Score    ${before}    ${after}
    Should Be True    ${score} < 90    Button didn't change
```

### Use Case 3: Integration with SikuliX
```robotframework
*** Test Cases ***
Verify Installation Window
    Wait Until Screen Contain    ${PATTERN}
    Sleep    1s
    ${actual}=    Capture Screen Region    100    100    600    400
    Compare Images And Fail If Different    expected_window.png    ${actual}    95.0
```

## 🎨 Similarity Thresholds Guide

| Threshold | Use For | Example |
|-----------|---------|---------|
| 99-100% | Exact match required | Company logos, icons |
| 95-98% | High similarity | Dialog boxes, buttons |
| 90-94% | Moderate similarity | Text areas with minor changes |
| 80-89% | Low similarity | Screens with dynamic content |

## 🔧 Comparison Methods

### MSE (Mean Squared Error) - Default ✅
- **Fast** - Good for most cases
- **Pixel-perfect** - Detects any pixel differences
- Use when: Speed matters or exact pixel match needed

### SSIM (Structural Similarity Index)
- **Perceptual** - More like human vision
- **Structural** - Focuses on patterns and structure
- Use when: Visual appearance matters more than exact pixels

Change method in any keyword:
```robotframework
Compare Images    img1.png    img2.png    95.0    ssim
```

## 📁 Directory Structure

Create this structure in your project:

```
AgileMark-Automation-Test/
├── resources/
│   └── Images/
│       └── expected/              ← Put expected images here
│           ├── login_dialog.png
│           ├── main_window.png
│           └── button_enabled.png
│
├── results/                       ← Test results go here
│   ├── actual_screenshots/        ← Captured images
│   ├── diff_*.png                ← Difference images
│   └── report.html               ← Visual comparison reports
│
├── libraries/
│   └── ImageComparisonLibrary.py ← Already created ✓
│
└── tests/
    ├── demo-agilemark-examples.robot
    └── image-comparison-examples.robot ← Try this example!
```

## 🧪 Try the Examples

We've created example tests you can run:

```bash
# Run the image comparison examples
robot tests/image-comparison-examples.robot

# Then open report.html to see the visual comparisons
```

## 💡 Tips

1. **Capture Timing**: Wait for UI to fully load before capturing
   ```robotframework
   Sleep    1s    # Wait for animation to complete
   ${img}=    Capture Screen Region    x    y    w    h
   ```

2. **Use Absolute Coordinates**: Ensure consistent window positions
   ```robotframework
   # Bad: Window might move
   ${img}=    Capture Screen Region    100    100    400    300
   
   # Good: Maximize window first
   Maximize Window
   ${img}=    Capture Screen Region    0    0    1920    1080
   ```

3. **Store Expected Images**: Keep a clean set of reference images
   ```robotframework
   ${EXPECTED_DIR}/
       ├── test1_expected.png
       ├── test2_expected.png
       └── ...
   ```

4. **Check Reports**: Always review the HTML report to see visual diffs
   - Red highlights show exactly what changed
   - Similarity score helps debug threshold issues

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| "File not found" | Check paths are correct, use `${CURDIR}` for relative paths |
| Low similarity scores | Check timing, ensure UI loaded, verify resolution |
| Images different sizes | Library auto-resizes, but check capture coordinates |
| SSIM not working | Fallback to MSE is automatic, or verify scikit-image installed |

## 📚 Full Documentation

For detailed documentation, see: `libraries/IMAGE_COMPARISON_GUIDE.md`

## ✨ Ready to Use!

You're all set! Add image comparison to your existing tests:

```robotframework
*** Settings ***
Library    ../libraries/ImageComparisonLibrary.py

*** Test Cases ***
Your Test With Image Comparison
    # Your existing test steps...
    Open Application    installer.msi
    
    # Add image comparison
    ${screenshot}=    Capture Screen Region    100    100    600    400
    Compare Images And Fail If Different    expected.png    ${screenshot}    95.0
```

Happy Testing! 🎉
