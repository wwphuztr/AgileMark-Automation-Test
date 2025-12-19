# Image Comparison Library Guide

## Overview
The `ImageComparisonLibrary` provides powerful image comparison capabilities for Robot Framework tests with beautiful visual reports embedded directly in your test results.

## Features
- ✅ Compare expected vs actual screenshots
- ✅ Multiple comparison algorithms (MSE and SSIM)
- ✅ Visual difference highlighting in reports
- ✅ Side-by-side image comparison in HTML reports
- ✅ Screen region capture functionality
- ✅ Configurable similarity thresholds
- ✅ Automatic image resizing for dimension mismatches

## Installation

1. Install required dependencies:
```bash
pip install -r requirements.txt
```

## Available Keywords

### 1. Compare Images
Compares two images and returns True/False based on similarity threshold.

```robotframework
${result}=    Compare Images    ${EXPECTED_IMG}    ${ACTUAL_IMG}    95.0    mse
Should Be True    ${result}    Images don't match
```

**Parameters:**
- `expected_image`: Path to expected/reference image
- `actual_image`: Path to actual/captured image
- `threshold`: Minimum similarity % (default: 95.0)
- `method`: Comparison method - 'mse' or 'ssim' (default: 'mse')

### 2. Compare Images And Fail If Different
Convenience keyword that automatically fails the test if images don't match.

```robotframework
Compare Images And Fail If Different    ${EXPECTED}    ${ACTUAL}    95.0
```

**Parameters:**
- Same as Compare Images
- `message`: Optional custom failure message

### 3. Capture Screen Region
Captures a specific region of the screen.

```robotframework
${screenshot}=    Capture Screen Region    100    100    400    300
${screenshot}=    Capture Screen Region    0    0    800    600    ${OUTPUT_DIR}/screenshot.png
```

**Parameters:**
- `x`: X coordinate of top-left corner
- `y`: Y coordinate of top-left corner
- `width`: Width of region
- `height`: Height of region
- `output_path`: Optional save path

### 4. Get Image Similarity Score
Returns similarity score without pass/fail logic.

```robotframework
${score}=    Get Image Similarity Score    ${IMG1}    ${IMG2}    mse
Log    Similarity: ${score}%
```

## Comparison Methods

### MSE (Mean Squared Error) - Default
- Fast and efficient
- Good for general purpose comparison
- Best for detecting pixel-level differences
- Range: 0-100% (higher is more similar)

### SSIM (Structural Similarity Index)
- More sophisticated algorithm
- Better for perceptual similarity
- Considers luminance, contrast, and structure
- Requires scikit-image library
- Range: 0-100% (higher is more similar)

## Practical Examples

### Example 1: Verify Application UI After Installation
```robotframework
*** Test Cases ***
Verify Installation Dialog
    Start Sikuli Process
    Open Application    installer.msi
    Sleep    2s
    
    # Capture the dialog
    ${actual}=    Capture Screen Region    100    100    600    400    ${OUTPUT_DIR}/dialog.png
    
    # Compare with expected
    Compare Images And Fail If Different    
    ...    ${EXPECTED_IMAGES_DIR}/expected_dialog.png
    ...    ${actual}
    ...    95.0
    ...    mse
    ...    Installation dialog doesn't match expected appearance
```

### Example 2: Verify Button State Changes
```robotframework
*** Test Cases ***
Verify Button Enabled State
    # Capture button in disabled state
    ${disabled_btn}=    Capture Screen Region    200    300    100    50
    
    # Perform action to enable button
    Click    ${ENABLE_BUTTON}
    Sleep    1s
    
    # Capture button in enabled state
    ${enabled_btn}=    Capture Screen Region    200    300    100    50
    
    # Verify they are different
    ${score}=    Get Image Similarity Score    ${disabled_btn}    ${enabled_btn}
    Should Be True    ${score} < 90    Button state didn't change
```

### Example 3: Verify Exact Match
```robotframework
*** Test Cases ***
Verify Logo Display
    ${actual_logo}=    Capture Screen Region    10    10    200    100
    
    # Require 99% match for logo
    Compare Images And Fail If Different
    ...    ${EXPECTED_IMAGES_DIR}/company_logo.png
    ...    ${actual_logo}
    ...    99.0
    ...    ssim
```

## Report Output

When you run image comparison tests, the HTML report will show:

1. **Comparison Status**: Visual PASS/FAIL indicator
2. **Similarity Score**: Percentage with method used
3. **Three Images Side-by-Side**:
   - Expected image
   - Actual image
   - Difference image (red highlights show differences)
4. **File Information**: Names of compared images

Example report entry:
```
┌─────────────────────────────────────────┐
│  Image Comparison: PASS                 │
│  Similarity Score: 97.5% (Method: MSE)  │
├─────────────────────────────────────────┤
│  [Expected] [Actual] [Differences]      │
│     📷        📷         📷              │
└─────────────────────────────────────────┘
```

## Tips and Best Practices

### 1. Choose Appropriate Thresholds
- **99-100%**: Exact match (logos, static images)
- **95-98%**: High similarity (UI elements with minor variations)
- **90-94%**: Moderate similarity (dynamic content areas)
- **<90%**: Low similarity (major differences expected)

### 2. Use Correct Comparison Method
- Use **MSE** for speed and pixel-perfect comparisons
- Use **SSIM** for perceptual similarity and structural comparison

### 3. Image Preparation
- Store expected images in `resources/Images/expected/`
- Use descriptive filenames: `login_dialog_expected.png`
- Capture at consistent resolution
- Avoid timestamp or dynamic content in expected images

### 4. Handling Dynamic Content
For areas with timestamps or changing data:
```robotframework
# Capture only static regions
${static_region}=    Capture Screen Region    100    100    400    200
Compare Images    ${EXPECTED}    ${static_region}    95.0
```

### 5. Debugging Failed Comparisons
When a comparison fails:
1. Check the HTML report for the difference image (red highlights)
2. Look at the similarity score - low scores indicate major differences
3. Verify screen resolution and scaling settings
4. Check if application loaded completely before capture

## Troubleshooting

### Images Have Different Dimensions
The library automatically resizes the actual image to match expected dimensions, but a warning will be logged. For best results, ensure consistent capture sizes.

### "Image Not Found" Error
Verify paths are correct and use absolute paths or proper relative paths from test file location.

### Low Similarity Scores
- Check timing - ensure UI is fully loaded
- Verify screen resolution matches
- Check for overlapping windows
- Ensure consistent application state

### SSIM Not Available
If you get "scikit-image not installed", the library will automatically fall back to MSE method. Install scikit-image for SSIM support:
```bash
pip install scikit-image==0.22.0
```

## Directory Structure

```
AgileMark-Automation-Test/
├── resources/
│   └── Images/
│       └── expected/          # Store expected reference images here
│           ├── dialog1.png
│           ├── button_enabled.png
│           └── ...
├── results/
│   └── actual_screenshots/    # Actual captured images saved here
│       └── diff_*.png         # Difference images generated here
└── tests/
    └── demo-agilemark-examples.robot
```

## Integration with Existing Tests

Add to any existing test:

```robotframework
*** Settings ***
Library    ../libraries/ImageComparisonLibrary.py

*** Test Cases ***
Your Existing Test
    # ... your existing test steps ...
    
    # Add image comparison
    ${actual}=    Capture Screen Region    x    y    width    height
    Compare Images And Fail If Different    ${EXPECTED}    ${actual}    95.0
```

## Advanced Usage

### Batch Comparisons
```robotframework
*** Keywords ***
Compare Multiple Regions
    [Arguments]    @{regions}
    FOR    ${region}    IN    @{regions}
        ${actual}=    Capture Screen Region    ${region}[x]    ${region}[y]    ${region}[w]    ${region}[h]
        Compare Images    ${region}[expected]    ${actual}    ${region}[threshold]
    END
```

### Conditional Comparison
```robotframework
*** Test Cases ***
Compare Based On Condition
    ${score}=    Get Image Similarity Score    ${IMG1}    ${IMG2}
    Run Keyword If    ${score} < 80    Log    Major differences detected    WARN
    ...    ELSE IF    ${score} < 95    Log    Minor differences detected    INFO
    ...    ELSE    Log    Images match closely    INFO
```
