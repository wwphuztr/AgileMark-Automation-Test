# 🎯 Using Image Comparison in Your AgileMark Tests

## Real-World Integration Example

Here's how to add image comparison to your existing AgileMark installation test:

### Before (Original Test)
```robotframework
Case1: Install AgileMark Application 
    [Documentation]    Installs the AgileMark application
    [Tags]    sikuli    gui   agilemark    
    Start Sikuli Process
    
    # Open AgileMark installer
    Open Application    ${CURDIR}${/}..${/}resources${/}Apps${/}AgileMark 1_1_2_8 GR.msi

    # Wait for installer window to appear
    Wait Until Screen Contain    ${IMAGE_DIR}${/}DePIN${/}pattern.png    ${LONG_TIMEOUT}
    
    Stop Sikuli Process
```

### After (With Visual Verification)
```robotframework
Case1: Install AgileMark Application With Visual Verification
    [Documentation]    Installs the AgileMark application and verifies UI appearance
    [Tags]    sikuli    gui   agilemark    visual-test
    Start Sikuli Process
    
    # Open AgileMark installer
    Open Application    ${CURDIR}${/}..${/}resources${/}Apps${/}AgileMark 1_1_2_8 GR.msi

    # Wait for installer window to appear
    Wait Until Screen Contain    ${IMAGE_DIR}${/}DePIN${/}pattern.png    ${LONG_TIMEOUT}
    
    # NEW: Capture and verify the installer window
    Sleep    1s    # Ensure window is fully rendered
    ${installer_screen}=    Capture Screen Region    100    100    800    600    ${OUTPUT_DIR}/installer_window.png
    
    # Compare with expected image (will show in HTML report)
    ${expected_file}=    Set Variable    ${EXPECTED_IMAGES_DIR}/installer_window_expected.png
    ${expected_exists}=    Run Keyword And Return Status    File Should Exist    ${expected_file}
    
    # If expected image exists, compare it; otherwise just log the captured image
    Run Keyword If    ${expected_exists}
    ...    Compare Images And Fail If Different    ${expected_file}    ${installer_screen}    95.0    mse    Installer window doesn't match expected appearance
    ...    ELSE    Log    Expected image not yet created. Captured image saved to ${installer_screen}. Copy to ${expected_file} after verification.    WARN
    
    Stop Sikuli Process
```

## 📝 Step-by-Step Integration Guide

### Step 1: Prepare Expected Image (First Time Only)

1. Run your test once to capture the actual image
2. Manually verify the captured image looks correct
3. Copy it to the expected directory:
   ```bash
   # From results/actual_screenshots/ to resources/Images/expected/
   Copy-Item results\actual_screenshots\installer_window.png resources\Images\expected\installer_window_expected.png
   ```

### Step 2: Run Test with Comparison

Now when you run the test again, it will:
1. ✅ Capture the installer window
2. ✅ Compare with expected image
3. ✅ Show visual comparison in HTML report
4. ✅ Fail test if similarity < 95%

### Step 3: Review Results

Open `results/report.html` to see:
- **Expected Image** (your reference)
- **Actual Image** (what was captured)
- **Difference Image** (red highlights show changes)
- **Similarity Score** (95.5%, 97.2%, etc.)

## 🎨 Practical Examples

### Example 1: Verify Installer Dialog Appearance
```robotframework
*** Test Cases ***
Verify Installer Welcome Dialog
    Open Application    installer.msi
    Sleep    2s
    
    ${dialog}=    Capture Screen Region    200    150    600    400
    Compare Images And Fail If Different    
    ...    ${EXPECTED_IMAGES_DIR}/welcome_dialog.png    
    ...    ${dialog}    
    ...    95.0
```

### Example 2: Verify Button State Changes
```robotframework
*** Test Cases ***
Verify Next Button Enables After Accept
    # Capture button in disabled state
    ${disabled_btn}=    Capture Screen Region    500    550    100    40
    
    # Click "I Accept" checkbox
    Click    ${ACCEPT_CHECKBOX}
    Sleep    0.5s
    
    # Capture button in enabled state
    ${enabled_btn}=    Capture Screen Region    500    550    100    40
    
    # Verify they're different (button changed appearance)
    ${similarity}=    Get Image Similarity Score    ${disabled_btn}    ${enabled_btn}
    Should Be True    ${similarity} < 90    Button should change appearance when enabled
    
    # Verify enabled state matches expected
    Compare Images And Fail If Different    
    ...    ${EXPECTED_IMAGES_DIR}/next_button_enabled.png    
    ...    ${enabled_btn}    
    ...    95.0
```

### Example 3: Verify Installation Progress
```robotframework
*** Test Cases ***
Verify Installation Progress Display
    Click    ${INSTALL_BUTTON}
    Sleep    2s
    
    # Capture progress dialog
    ${progress_dialog}=    Capture Screen Region    150    150    700    500
    
    # Verify progress dialog appearance
    Compare Images And Fail If Different    
    ...    ${EXPECTED_IMAGES_DIR}/installation_progress.png    
    ...    ${progress_dialog}    
    ...    90.0    # Lower threshold due to progress bar animation
```

### Example 4: Multi-Step Verification
```robotframework
*** Test Cases ***
Complete Installation with Visual Checkpoints
    [Documentation]    Verify visual appearance at each installation step
    
    # Step 1: Welcome screen
    Open Application    installer.msi
    Sleep    2s
    ${welcome}=    Capture Screen Region    100    100    800    600
    Compare Images    ${EXPECTED_IMAGES_DIR}/step1_welcome.png    ${welcome}    95.0
    
    # Step 2: License agreement
    Click    ${NEXT_BUTTON}
    Sleep    1s
    ${license}=    Capture Screen Region    100    100    800    600
    Compare Images    ${EXPECTED_IMAGES_DIR}/step2_license.png    ${license}    95.0
    
    # Step 3: Installation location
    Click    ${NEXT_BUTTON}
    Sleep    1s
    ${location}=    Capture Screen Region    100    100    800    600
    Compare Images    ${EXPECTED_IMAGES_DIR}/step3_location.png    ${location}    95.0
    
    # Step 4: Installation complete
    Click    ${INSTALL_BUTTON}
    Wait Until Screen Contain    ${COMPLETE_PATTERN}    60s
    ${complete}=    Capture Screen Region    100    100    800    600
    Compare Images    ${EXPECTED_IMAGES_DIR}/step4_complete.png    ${complete}    95.0
```

## 🔧 Customizing for Your Needs

### Adjust Capture Coordinates

Find the right coordinates for your screen:
```robotframework
# Full screen
${img}=    Capture Screen Region    0    0    1920    1080

# Specific dialog
${img}=    Capture Screen Region    200    150    600    400

# Just a button
${img}=    Capture Screen Region    500    550    100    40
```

### Adjust Similarity Thresholds

Based on your needs:
```robotframework
# Very strict (99%+) - for logos, icons
Compare Images    expected.png    actual.png    99.0

# Normal (95-98%) - for dialogs, buttons
Compare Images    expected.png    actual.png    95.0

# Relaxed (90-94%) - for dynamic content
Compare Images    expected.png    actual.png    90.0

# Very relaxed (80-89%) - for high variability
Compare Images    expected.png    actual.png    85.0
```

### Choose Comparison Method

```robotframework
# MSE - Fast, pixel-perfect (default)
Compare Images    expected.png    actual.png    95.0    mse

# SSIM - Perceptual, structural
Compare Images    expected.png    actual.png    95.0    ssim
```

## 📊 What You Get in Reports

When a comparison runs, your `report.html` shows:

```
┌─────────────────────────────────────────────────────────┐
│ 🟢 Image Comparison: PASS                               │
│ Similarity Score: 97.5% (Method: MSE)                   │
│ Expected: installer_window_expected.png                 │
│ Actual: installer_window.png                            │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   Expected          Actual           Differences        │
│   ┌─────────┐      ┌─────────┐      ┌─────────┐       │
│   │  [IMG]  │      │  [IMG]  │      │  [IMG]  │       │
│   │         │      │         │      │ (red    │       │
│   │         │      │         │      │ marks)  │       │
│   └─────────┘      └─────────┘      └─────────┘       │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

Or when it fails:

```
┌─────────────────────────────────────────────────────────┐
│ 🔴 Image Comparison: FAIL                               │
│ Similarity Score: 87.3% (Method: MSE)                   │
│ Threshold: 95.0%                                        │
│ Expected: button_enabled.png                            │
│ Actual: button_actual.png                               │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   Expected          Actual           Differences        │
│   ┌─────────┐      ┌─────────┐      ┌─────────┐       │
│   │  [IMG]  │      │  [IMG]  │      │  [IMG]  │       │
│   │ (green) │      │ (blue)  │      │ (!!!)   │       │
│   │         │      │         │      │ RED     │       │
│   └─────────┘      └─────────┘      └─────────┘       │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## 💡 Pro Tips

### 1. Use Helper Keywords
```robotframework
*** Keywords ***
Capture And Compare Dialog
    [Arguments]    ${x}    ${y}    ${width}    ${height}    ${expected_name}    ${threshold}=95.0
    ${actual}=    Capture Screen Region    ${x}    ${y}    ${width}    ${height}
    Compare Images And Fail If Different    
    ...    ${EXPECTED_IMAGES_DIR}/${expected_name}    
    ...    ${actual}    
    ...    ${threshold}

*** Test Cases ***
My Test
    Capture And Compare Dialog    200    150    600    400    welcome_dialog.png
```

### 2. Create Image Sets for Different Screens
```
resources/Images/expected/
├── 1920x1080/
│   ├── dialog1.png
│   └── dialog2.png
├── 1366x768/
│   ├── dialog1.png
│   └── dialog2.png
└── 2560x1440/
    ├── dialog1.png
    └── dialog2.png
```

### 3. Use Variables for Coordinates
```robotframework
*** Variables ***
# Dialog positions
${INSTALLER_X}    200
${INSTALLER_Y}    150
${INSTALLER_W}    600
${INSTALLER_H}    400

# Button positions
${NEXT_BTN_X}    500
${NEXT_BTN_Y}    550
${NEXT_BTN_W}    100
${NEXT_BTN_H}    40

*** Test Cases ***
My Test
    ${dialog}=    Capture Screen Region    ${INSTALLER_X}    ${INSTALLER_Y}    ${INSTALLER_W}    ${INSTALLER_H}
    ${button}=    Capture Screen Region    ${NEXT_BTN_X}    ${NEXT_BTN_Y}    ${NEXT_BTN_W}    ${NEXT_BTN_H}
```

## 🚀 Quick Start Commands

```bash
# Run your existing tests with image comparison
robot --outputdir results tests/demo-agilemark-examples.robot

# Run the example tests to see it in action
robot --outputdir results tests/image-comparison-examples.robot

# View the results
Start-Process results\report.html
```

## 📚 Reference

- **Quick Start**: `QUICK_START_IMAGE_COMPARISON.md`
- **Full Guide**: `libraries/IMAGE_COMPARISON_GUIDE.md`
- **Examples**: `tests/image-comparison-examples.robot`
- **Summary**: `IMPLEMENTATION_SUMMARY.md`

---

**You're ready to add visual testing to your AgileMark automation! 🎉**
