*** Settings ***
Documentation    SikuliX integration test examples
...              Demonstrates visual recognition and GUI automation with SikuliX
Library          SikuliLibrary    mode=OLD    timeout=10
Library          OperatingSystem
Library          Process
Library          Collections
Library          ../libraries/ImageComparisonLibrary.py
Suite Setup      Start Sikuli Process
Suite Teardown   Cleanup After Suite

*** Variables ***
${IMAGE_DIR}     ${CURDIR}${/}..${/}resources${/}images${/}screens
${TIMEOUT}       10
${LONG_TIMEOUT}  10
${EXPECTED_IMAGES_DIR}    ${CURDIR}${/}..${/}resources${/}Images${/}expected
${ACTUAL_IMAGES_DIR}      ${CURDIR}${/}..${/}resources${/}Images${/}actual

*** Test Cases ***
Case1: Install AgileMark Application 
    [Documentation]    Installs the AgileMark application
    [Tags]    sikuli    gui   agilemark    
    Start Sikuli Process
    # Open AgileMark installer
    Log    ========================== Open AgileMark installer ==========================
    Open Application    ${CURDIR}${/}..${/}resources${/}Apps${/}AgileMark 1_1_2_8 GR.msi
    Sleep    5s

    # Wait the pattern to appear on screen with high similarity threshold
    Log    ========================== Wait for pattern to appear on screen with high similarity threshold ==========================
    Set Min Similarity    0.95
    ${pattern_found}=    Run Keyword And Return Status    Wait Until Screen Contain    ${IMAGE_DIR}${/}patternAfterInstall.png    ${LONG_TIMEOUT}
    
    # Capture actual screenshot for comparison regardless of pattern match result
    Log    ========================== Capture actual screenshot for comparison ==========================
    ${actual_screenshot}=    Capture Screen Region    0    0    1920    1080    ${ACTUAL_IMAGES_DIR}${/}install_screen.png
    
    # Compare with expected image if it exists
    Log    ========================== Compare with expected image if it exists ==========================
    ${expected_img}=    Set Variable    ${EXPECTED_IMAGES_DIR}${/}install_screen_expected.png
    ${expected_exists}=    Run Keyword And Return Status    File Should Exist    ${expected_img}
    Run Keyword If    ${expected_exists}    Compare Images    ${expected_img}    ${actual_screenshot}    95.0
    
    # Fail at the end if pattern was not found
    Log    ========================== Fail if pattern was not found ==========================
    Run Keyword If    not ${pattern_found}    Fail    Pattern '${IMAGE_DIR}${/}patternAfterInstall.png' was not found on screen. Check image comparison in report.

    # Delete the config file if it exists to ensure a fresh install
    Log    ========================== Delete the config file if it exists to ensure a fresh install ==========================
    ${config_file}=    Set Variable    C:\\Program Files (x86)\\AgileMark\\store.cfg
    ${config_exists}=    Run Keyword And Return Status    File Should Exist    ${config_file}
    Run Keyword If    ${config_exists}    Remove File    ${config_file}
    Run Keyword If    ${config_exists}    Log    Deleted config file: ${config_file}
    ...    ELSE    Log    Config file does not exist: ${config_file}

    # Move the expected config file into place after deletion
    Log    ========================== Move the expected config file into place after deletion ==========================
    ${source_config}=    Set Variable    ${CURDIR}${/}..${/}resources${/}Configs${/}store.cfg
    ${dest_dir}=    Set Variable    C:\\Program Files (x86)\\AgileMark
    ${dest_config}=    Set Variable    ${dest_dir}\\store.cfg

    # Copy config file to destination
    Log    ========================== Copy config file to destination ==========================
    Copy File    ${source_config}    ${dest_config}
    Log    Copied config file from ${source_config} to ${dest_config}

    Stop Sikuli Process

Case2: Uninstall AgileMark Application 
    [Documentation]    Delete data associated with AgileMark application
    [Tags]    sikuli    gui   agilemark
    Start Sikuli Process

    # Check if AgileMark and AgileService processes are running
    Log    ========================== Check if AgileMark and AgileService processes are running ==========================
    ${check_result}=    Run Process    tasklist    /FI    IMAGENAME eq AgileMark.exe    shell=True
    Log    AgileMark process check: ${check_result.stdout}
    ${check_service}=    Run Process    tasklist    /FI    IMAGENAME eq AgileService.exe    shell=True
    Log    AgileService process check: ${check_service.stdout}
    
    # Force kill both AgileMark and AgileService processes with elevated privileges
    Log    ========================== Force kill both AgileMark and AgileService processes with elevated privileges ==========================
    ${kill_cmd}=    Set Variable    Start-Process powershell -ArgumentList '-Command', 'Stop-Process -Name AgileMark,AgileService -Force -ErrorAction SilentlyContinue' -Verb RunAs -WindowStyle Hidden -Wait
    ${kill_result}=    Run Process    powershell    -Command    ${kill_cmd}    shell=True
    Log    PowerShell elevated kill stdout: ${kill_result.stdout}
    Log    PowerShell elevated kill stderr: ${kill_result.stderr}
    Log    PowerShell elevated kill return code: ${kill_result.rc}
    
    Sleep    1s
    
    # Verify if processes still exist
    Log    ========================== Verify if processes still exist ==========================
    ${verify_agilemark}=    Run Process    tasklist    /FI    IMAGENAME eq AgileMark.exe    shell=True
    ${agilemark_found}=    Run Keyword And Return Status    Should Contain    ${verify_agilemark.stdout}    AgileMark.exe
    ${verify_service}=    Run Process    tasklist    /FI    IMAGENAME eq AgileService.exe    shell=True
    ${service_found}=    Run Keyword And Return Status    Should Contain    ${verify_service.stdout}    AgileService.exe
    
    Run Keyword If    not ${agilemark_found} and not ${service_found}    Log    All AgileMark processes successfully terminated
    ...    ELSE IF    ${agilemark_found}    Log    WARNING: AgileMark.exe is still running    level=WARN
    ...    ELSE IF    ${service_found}    Log    WARNING: AgileService.exe is still running    level=WARN
    
    Sleep    2s

    # Delete the AgileMark data folder
    Log    ========================== Delete the AgileMark data folder ==========================
    Remove Directory    C:\\Program Files (x86)\\AgileMark    recursive=True
    Sleep    5

    Stop Sikuli Process

Case3: Image Comparison Example
    [Documentation]    Demonstrates image comparison functionality with visual report
    [Tags]    sikuli    gui    agilemark    image-comparison
    
    # Create directories for images
    Create Directory    ${ACTUAL_IMAGES_DIR}
    Create Directory    ${EXPECTED_IMAGES_DIR}
    
    # Example 1: Capture and compare a screen region
    Log    Example: Capturing screen and comparing with expected image    console=True
    
    # In a real scenario, you would:
    # 1. Capture actual screenshot from application
    # ${actual_img}=    Capture Screen Region    100    100    400    300    ${ACTUAL_IMAGES_DIR}${/}screen_capture.png
    
    # 2. Compare with expected image
    # ${result}=    Compare Images    ${EXPECTED_IMAGES_DIR}${/}expected_screen.png    ${actual_img}    95.0
    # Should Be True    ${result}    Image comparison failed - see report for details
    
    # Example 2: Using the convenience keyword that fails automatically
    # Compare Images And Fail If Different    ${EXPECTED_IMAGES_DIR}${/}expected_dialog.png    ${ACTUAL_IMAGES_DIR}${/}actual_dialog.png    95.0
    
    # Example 3: Get similarity score without pass/fail
    # ${score}=    Get Image Similarity Score    ${EXPECTED_IMAGES_DIR}${/}image1.png    ${EXPECTED_IMAGES_DIR}${/}image2.png
    # Log    Similarity Score: ${score}%
    
    Log    Image comparison keywords are ready to use. Add expected images to ${EXPECTED_IMAGES_DIR}    console=True

*** Keywords ***
Start Sikuli Process
    [Documentation]    Initializes SikuliX
    Add Image Path    ${IMAGE_DIR}

Stop Sikuli Process
    [Documentation]    Cleanup after SikuliX operations
    Remove Image Path    ${IMAGE_DIR}

Cleanup After Suite
    [Documentation]    Cleanup suite and delete SikuliX log files
    Stop Remote Server
    Sleep    2s
    Delete Sikuli Log Files

Delete Sikuli Log Files
    [Documentation]    Delete temporary SikuliX log files using delayed cleanup
    ${results_dir}=    Set Variable    ${CURDIR}${/}..${/}results
    # Schedule deletion after 5 seconds to allow file handles to be released
    ${cleanup_command}=    Set Variable    Start-Sleep -Seconds 5; Get-ChildItem '${results_dir}' -Filter 'Sikuli_java_*' | Remove-Item -Force -ErrorAction SilentlyContinue
    Run Keyword And Ignore Error    Start Process    powershell.exe    -Command    ${cleanup_command}    shell=True
    Log    Scheduled delayed cleanup of SikuliX temporary log files