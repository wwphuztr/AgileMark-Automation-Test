*** Settings ***
Documentation    Practical examples of image comparison in AgileMark testing
Library          ../libraries/ImageComparisonLibrary.py
Library          OperatingSystem
Library          Screenshot

*** Variables ***
${EXPECTED_DIR}    ${CURDIR}${/}..${/}resources${/}Images${/}expected
${ACTUAL_DIR}      ${OUTPUT_DIR}${/}actual_screenshots

*** Test Cases ***
Example 1: Basic Screenshot Comparison
    [Documentation]    Demonstrates basic screenshot capture and comparison
    [Tags]    example    image-comparison
    
    # Setup directories
    Create Directory    ${EXPECTED_DIR}
    Create Directory    ${ACTUAL_DIR}
    
    # Take a screenshot using Robot Framework's Screenshot library
    ${screenshot_path}=    Take Screenshot    ${ACTUAL_DIR}/sample_screen.png
    
    Log    Screenshot saved to: ${screenshot_path}    console=True
    Log    To use comparison: Place expected image at ${EXPECTED_DIR}/sample_screen_expected.png    console=True

Example 2: Screen Region Comparison with Threshold
    [Documentation]    Shows how to capture specific screen regions and compare
    [Tags]    example    region-comparison
    
    Create Directory    ${ACTUAL_DIR}
    
    # Capture a specific region (modify coordinates for your screen)
    ${actual_img}=    Capture Screen Region    100    100    400    300    ${ACTUAL_DIR}/region_capture.png
    Log    Region captured: ${actual_img}    console=True
    
    # Get similarity score if expected image exists
    ${expected_exists}=    Run Keyword And Return Status    
    ...    File Should Exist    ${EXPECTED_DIR}/region_expected.png
    
    IF    ${expected_exists}
        ${score}=    Get Image Similarity Score    ${EXPECTED_DIR}/region_expected.png    ${actual_img}
        Log    Similarity Score: ${score}%    console=True
    ELSE
        Log    Expected image not found. Add it to ${EXPECTED_DIR}/region_expected.png to enable comparison    console=True
    END

Example 3: Automated Comparison with Pass/Fail
    [Documentation]    Demonstrates automatic pass/fail based on image comparison
    [Tags]    example    automated-comparison
    
    Create Directory    ${ACTUAL_DIR}
    
    # For demonstration, we'll capture screen regions directly
    # This ensures we have actual PNG images to compare
    
    # Capture two screen regions
    ${test_img1}=    Capture Screen Region    100    100    400    300    ${ACTUAL_DIR}/test_image1.png
    Sleep    0.5s
    ${test_img2}=    Capture Screen Region    100    100    400    300    ${ACTUAL_DIR}/test_image2.png
    
    # Compare images - should have very high similarity
    ${score}=    Get Image Similarity Score    ${test_img1}    ${test_img2}
    Log    Similarity between captures: ${score}%    console=True
    
    # Example of passing comparison
    ${result}=    Compare Images    ${test_img1}    ${test_img2}    threshold=80.0
    Should Be True    ${result}    Images should be similar

Example 4: Multiple Comparison Methods
    [Documentation]    Compares images using different algorithms
    [Tags]    example    comparison-methods
    
    Create Directory    ${ACTUAL_DIR}
    
    # Create two test screenshots
    ${img1}=    Take Screenshot    ${ACTUAL_DIR}/method_test1.png
    Sleep    0.2s
    ${img2}=    Take Screenshot    ${ACTUAL_DIR}/method_test2.png
    
    # Compare using MSE method (faster)
    ${mse_score}=    Get Image Similarity Score    ${img1}    ${img2}    method=mse
    Log    MSE Similarity: ${mse_score}%    console=True
    
    # Compare using SSIM method (more perceptual)
    ${ssim_score}=    Get Image Similarity Score    ${img1}    ${img2}    method=ssim
    Log    SSIM Similarity: ${ssim_score}%    console=True

Example 5: Visual Report Generation
    [Documentation]    Shows how comparison results appear in HTML reports
    [Tags]    example    visual-report
    
    Create Directory    ${EXPECTED_DIR}
    Create Directory    ${ACTUAL_DIR}
    
    # Create sample images for comparison
    ${expected}=    Take Screenshot    ${EXPECTED_DIR}/report_demo_expected.png
    Sleep    0.1s
    ${actual}=    Take Screenshot    ${ACTUAL_DIR}/report_demo_actual.png
    
    # This will create a visual comparison in the HTML report
    # Check the report.html after running this test to see the embedded images
    Compare Images    ${expected}    ${actual}    threshold=80.0
    
    Log    Check the HTML report to see the visual comparison with:    console=True
    Log    - Expected image    console=True
    Log    - Actual image    console=True
    Log    - Difference visualization (red highlights)    console=True
    Log    - Similarity score and pass/fail status    console=True

Example 6: Integration with SikuliX Pattern Matching
    [Documentation]    Shows how to combine SikuliX pattern matching with image comparison
    [Tags]    example    sikuli-integration
    
    Create Directory    ${ACTUAL_DIR}
    
    # After SikuliX finds a pattern, you can verify the exact appearance
    Log    Integration Example: After SikuliX click/wait operations    console=True
    Log    1. Use SikuliX to interact with UI    console=True
    Log    2. Capture the result with Capture Screen Region    console=True
    Log    3. Compare with expected result using Compare Images    console=True
    
    # Example workflow:
    # Wait Until Screen Contain    ${PATTERN}
    # Click    ${BUTTON_PATTERN}
    # Sleep    1s
    # ${result}=    Capture Screen Region    x    y    width    height
    # Compare Images And Fail If Different    ${EXPECTED}    ${result}    95.0

*** Keywords ***
Setup Image Comparison Test
    [Documentation]    Common setup for image comparison tests
    Create Directory    ${EXPECTED_DIR}
    Create Directory    ${ACTUAL_DIR}
    Log    Expected images directory: ${EXPECTED_DIR}    console=True
    Log    Actual images directory: ${ACTUAL_DIR}    console=True
