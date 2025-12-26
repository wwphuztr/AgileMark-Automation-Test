*** Settings ***
Documentation    SikuliX integration test examples
...              Demonstrates visual recognition and GUI automation with SikuliX
Library          SikuliLibrary    mode=OLD    timeout=10
Library          OperatingSystem
Library          Process
Library          Collections
Library          String
Library          ../libraries/ImageComparisonLibrary.py
Library          ../libraries/VideoRecorderLibrary.py
Suite Setup      Start Sikuli Process
Suite Teardown   Cleanup After Suite
Test Setup       Start Test Recording
Test Teardown    Stop Test Recording

*** Variables ***
${IMAGE_DIR}     ${CURDIR}${/}..${/}resources${/}images${/}screens
${TIMEOUT}       10
${LONG_TIMEOUT}  10
${EXPECTED_IMAGES_DIR}    ${CURDIR}${/}..${/}resources${/}Images${/}expected
${ACTUAL_IMAGES_DIR}      ${CURDIR}${/}..${/}resources${/}Images${/}actual

*** Test Cases ***
Case1: Install AgileMark Application 
    [Documentation]    Installs the AgileMark application
    [Tags]    sikuli    gui   agilemark    only    
    Start Sikuli Process
    # Open AgileMark installer
    Log    <span style="color: #0066cc; font-weight: bold;">========================== OPEN AGILEMARK INSTALLER ==========================</span>    html=True
    Open Application    ${CURDIR}${/}..${/}resources${/}Apps${/}AgileMark 1_1_2_8 GR.msi
    Sleep    5s

    # Wait the pattern to appear on screen with high similarity threshold
    Log    <span style="color: #0066cc; font-weight: bold;">========================== WAIT FOR PATTERN TO APPEAR ON SCREEN WITH HIGH SIMILARITY THRESHOLD ==========================</span>    html=True
    Set Min Similarity    0.95
    ${pattern_found}=    Run Keyword And Return Status    Wait Until Screen Contain    ${IMAGE_DIR}${/}patternAfterInstall.png    ${LONG_TIMEOUT}

    # Delete the config file if it exists to ensure a fresh install
    Log    <span style="color: #0066cc; font-weight: bold;">========================== DELETE THE CONFIG FILE IF IT EXISTS TO ENSURE A FRESH INSTALL ==========================</span>    html=True
    ${config_file}=    Set Variable    C:\\Program Files (x86)\\AgileMark\\store.cfg
    ${config_exists}=    Run Keyword And Return Status    File Should Exist    ${config_file}
    Run Keyword If    ${config_exists}    Remove File    ${config_file}
    Run Keyword If    ${config_exists}    Log    Deleted config file: ${config_file}
    ...    ELSE    Log    Config file does not exist: ${config_file}

    # Move the expected config file into place after deletion
    Log    <span style="color: #0066cc; font-weight: bold;">========================== MOVE THE EXPECTED CONFIG FILE INTO PLACE AFTER DELETION ==========================</span>    html=True
    ${source_config}=    Set Variable    ${CURDIR}${/}..${/}resources${/}Configs${/}store.cfg
    ${dest_dir}=    Set Variable    C:\\Program Files (x86)\\AgileMark
    ${dest_config}=    Set Variable    ${dest_dir}\\store.cfg

    # Restart AgileService to apply new config
    Log    <span style="color: #0066cc; font-weight: bold;">========================== RESTART AGILESERVICE TO APPLY NEW CONFIG ==========================</span>    html=True
    Restart AgileService

    # Copy config file to destination
    Log    <span style="color: #0066cc; font-weight: bold;">========================== COPY CONFIG FILE TO DESTINATION ==========================</span>    html=True
    Copy File    ${source_config}    ${dest_config}
    Log    Copied config file from ${source_config} to ${dest_config}

    # Capture actual screenshot for comparison regardless of pattern match result
    Log    <span style="color: #0066cc; font-weight: bold;">========================== CAPTURE ACTUAL SCREENSHOT FOR COMPARISON ==========================</span>    html=True
    ${actual_screenshot}=    Capture Screen Region    0    0    1920    1040    ${ACTUAL_IMAGES_DIR}${/}install_screen.png
    
    # Compare with expected image if it exists
    Log    <span style="color: #0066cc; font-weight: bold;">========================== COMPARE WITH EXPECTED IMAGE IF IT EXISTS ==========================</span>    html=True
    ${expected_img}=    Set Variable    ${EXPECTED_IMAGES_DIR}${/}patternAfterInstall.png
    ${expected_exists}=    Run Keyword And Return Status    File Should Exist    ${expected_img}
    ${comparison_result}=    Run Keyword If    ${expected_exists}    Compare Images    ${expected_img}    ${actual_screenshot}    100.0
    Run Keyword If    ${expected_exists} and not ${comparison_result}    Fail    Image comparison failed - images do not match. Check comparison in report.
    
    # Fail at the end if pattern was not found
    Log    <span style="color: #ff6600; font-weight: bold;">========================== FAIL IF PATTERN WAS NOT FOUND ==========================</span>    html=True
    Run Keyword If    not ${pattern_found}    Fail    Pattern '${IMAGE_DIR}${/}patternAfterInstall.png' was not found on screen. Check image comparison in report.

    Stop Sikuli Process

Case2: Verify Watermark display on different screen resolutions
    [Documentation]    Tests watermark display at different screen resolutions
    [Tags]    sikuli    gui    agilemark    resolution
    Start Sikuli Process
    
    # Open Windows Display Settings
    Log    <span style="color: #0066cc; font-weight: bold;">========================== OPEN WINDOWS DISPLAY SETTINGS ==========================</span>    html=True
    Open Display Settings

    # Change to 1280 x 720 resolution
    Log    <span style="color: #0066cc; font-weight: bold;">========================== CHANGE TO 1280 X 720 RESOLUTION ==========================</span>    html=True
    Change Resolution    resolution_1280x720.png    down

    # Close Display Settings
    Log    <span style="color: #0066cc; font-weight: bold;">========================== CLOSE DISPLAY SETTINGS ==========================</span>    html=True
    Close Display Settings
    
    Stop Sikuli Process

Case3: Reset display with default screen resolutions
    [Documentation]    Resets display to default 1920x1080 resolution
    [Tags]    sikuli    gui    agilemark    resolution
    Start Sikuli Process
    
    # Open Windows Display Settings
    Log    <span style="color: #0066cc; font-weight: bold;">========================== OPEN WINDOWS DISPLAY SETTINGS ==========================</span>    html=True
    Open Display Settings

    # Change to 1920 x 1080 resolution
    Log    <span style="color: #0066cc; font-weight: bold;">========================== CHANGE TO 1920 X 1080 RESOLUTION ==========================</span>    html=True
    Change Resolution    resolution_1920x1080.png    up

    # Close Display Settings
    Log    <span style="color: #0066cc; font-weight: bold;">========================== CLOSE DISPLAY SETTINGS ==========================</span>    html=True
    Close Display Settings
    
    Stop Sikuli Process

CaseX: Uninstall AgileMark Application 
    [Documentation]    Delete data associated with AgileMark application
    [Tags]    sikuli    gui   agilemark
    Start Sikuli Process

    # Check if AgileMark and AgileService processes are running
    Log    <span style="color: #0066cc; font-weight: bold;">========================== CHECK IF AGILEMARK AND AGILESERVICE PROCESSES ARE RUNNING ==========================</span>    html=True
    ${check_result}=    Run Process    tasklist    /FI    IMAGENAME eq AgileMark.exe    shell=True
    Log    AgileMark process check: ${check_result.stdout}
    ${check_service}=    Run Process    tasklist    /FI    IMAGENAME eq AgileService.exe    shell=True
    Log    AgileService process check: ${check_service.stdout}
    
    # Force kill both AgileMark and AgileService processes with elevated privileges
    Log    <span style="color: #ff6600; font-weight: bold;">========================== FORCE KILL BOTH AGILEMARK AND AGILESERVICE PROCESSES WITH ELEVATED PRIVILEGES ==========================</span>    html=True
    ${kill_cmd}=    Set Variable    Start-Process powershell -ArgumentList '-Command', 'Stop-Process -Name AgileMark,AgileService -Force -ErrorAction SilentlyContinue' -Verb RunAs -WindowStyle Hidden -Wait
    ${kill_result}=    Run Process    powershell    -Command    ${kill_cmd}    shell=True
    Log    PowerShell elevated kill stdout: ${kill_result.stdout}
    Log    PowerShell elevated kill stderr: ${kill_result.stderr}
    Log    PowerShell elevated kill return code: ${kill_result.rc}
    
    Sleep    1s
    
    # Verify if processes still exist
    Log    <span style="color: #0066cc; font-weight: bold;">========================== VERIFY IF PROCESSES STILL EXIST ==========================</span>    html=True
    ${verify_agilemark}=    Run Process    tasklist    /FI    IMAGENAME eq AgileMark.exe    shell=True
    ${agilemark_found}=    Run Keyword And Return Status    Should Contain    ${verify_agilemark.stdout}    AgileMark.exe
    ${verify_service}=    Run Process    tasklist    /FI    IMAGENAME eq AgileService.exe    shell=True
    ${service_found}=    Run Keyword And Return Status    Should Contain    ${verify_service.stdout}    AgileService.exe
    
    Run Keyword If    not ${agilemark_found} and not ${service_found}    Log    All AgileMark processes successfully terminated
    ...    ELSE IF    ${agilemark_found}    Log    WARNING: AgileMark.exe is still running    level=WARN
    ...    ELSE IF    ${service_found}    Log    WARNING: AgileService.exe is still running    level=WARN
    
    Sleep    2s

    # Delete the AgileMark data folder
    Log    <span style="color: #ff0000; font-weight: bold;">========================== DELETE THE AGILEMARK DATA FOLDER ==========================</span>    html=True
    Remove Directory    C:\\Program Files (x86)\\AgileMark    recursive=True
    Sleep    5

    Stop Sikuli Process

*** Keywords ***
Start Sikuli Process
    [Documentation]    Initializes SikuliX
    Add Image Path    ${IMAGE_DIR}

Stop Sikuli Process
    [Documentation]    Cleanup after SikuliX operations
    Remove Image Path    ${IMAGE_DIR}

Restart AgileService
    [Documentation]    Restarts AgileService as a Windows service with elevated privileges
    Log    Stopping AgileService Windows service with elevated privileges...
    ${stop_cmd}=    Set Variable    Start-Process powershell -ArgumentList '-Command', 'Stop-Service -Name AgileService -Force -ErrorAction SilentlyContinue' -Verb RunAs -WindowStyle Hidden -Wait
    ${stop_result}=    Run Process    powershell    -Command    ${stop_cmd}    shell=True
    Log    Stop service stdout: ${stop_result.stdout}
    Log    Stop service stderr: ${stop_result.stderr}
    Log    Stop service return code: ${stop_result.rc}
    Sleep    2s
    
    Log    Starting AgileService Windows service with elevated privileges...
    ${start_cmd}=    Set Variable    Start-Process powershell -ArgumentList '-Command', 'Start-Service -Name AgileService' -Verb RunAs -WindowStyle Hidden -Wait
    ${start_result}=    Run Process    powershell    -Command    ${start_cmd}    shell=True
    Log    Start service stdout: ${start_result.stdout}
    Log    Start service stderr: ${start_result.stderr}
    Log    Start service return code: ${start_result.rc}
    Sleep    7s
    
    # Verify service is running
    Log    Verifying AgileService status...
    ${status_result}=    Run Process    powershell    -Command    (Get-Service -Name AgileService).Status    shell=True
    Log    AgileService status: ${status_result.stdout}
    Should Contain    ${status_result.stdout}    Running    AgileService is not running after restart. Status: ${status_result.stdout}

Open Display Settings
    [Documentation]    Opens Windows Display Settings
    Log    Opening Windows Display Settings...
    ${result}=    Run Process    powershell    -Command    Start-Process ms-settings:display    shell=True
    # Wait for Display settings window to appear
    Set Min Similarity    0.9
    ${settings_opened}=    Run Keyword And Return Status    Wait Until Screen Contain    ${IMAGE_DIR}${/}display_settings.png    ${TIMEOUT}
    Set Min Similarity    0.9
    Click    ${IMAGE_DIR}${/}display_settings.png    0    30
    # Scroll down to show more options if needed
    Sleep    1s
    Log    Scrolling down to bottom of Display Settings...
    # Scroll down multiple times to reach the bottom
    FOR    ${i}    IN RANGE    3
        Wheel Down    5
    END
    Log    Scrolled to bottom of Display Settings

Close Display Settings
    [Documentation]    Closes Windows Display Settings
    Log    Closing Windows Display Settings...
    ${close_result}=    Run Process    powershell    -Command    Get-Process | Where-Object {$_.MainWindowTitle -like '*Settings*'} | Stop-Process -Force    shell=True
    Wait Until Screen Not Contain    ${IMAGE_DIR}${/}display_settings.png    ${TIMEOUT}
    Log    Display Settings closed

Change Resolution
    [Documentation]    Changes screen resolution with scrolling support
    [Arguments]    ${resolution_image}    ${scroll_direction}=none
    
    # Click on resolution dropdown
    Log    Clicking on resolution dropdown...
    Click    ${IMAGE_DIR}${/}display_resolution_dropdown.png    0    30
    Sleep    1s
    
    # Scroll if needed
    Run Keyword If    '${scroll_direction}' == 'up'    Scroll Resolution List Up
    Run Keyword If    '${scroll_direction}' == 'down'    Scroll Resolution List Down
    
    # Select resolution
    Log    Selecting resolution: ${resolution_image}
    Click    ${IMAGE_DIR}${/}${resolution_image}
    Sleep    2s
    
    # Click Keep changes button
    Log    Clicking Keep changes button...
    Click    ${IMAGE_DIR}${/}keep_changes_button.png
    Sleep    1s

Scroll Resolution List Up
    [Documentation]    Scrolls up in resolution list
    Log    Scrolling up to show higher resolutions...
    FOR    ${i}    IN RANGE    5
        Wheel Up    5
        Sleep    0.2s
    END
    Sleep    1s

Scroll Resolution List Down
    [Documentation]    Scrolls down in resolution list
    Log    Scrolling down to show lower resolutions...
    FOR    ${i}    IN RANGE    5
        Wheel Down    5
        Sleep    0.2s
    END
    Sleep    1s

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

Start Test Recording
    [Documentation]    Starts video recording for the test
    ${test_name}=    Get Variable Value    ${TEST NAME}    unknown_test
    ${safe_name}=    Replace String    ${test_name}    ${SPACE}    _
    ${safe_name}=    Replace String    ${safe_name}    :    -
    Start Video Recording    ${safe_name}    10.0
    Log    Started video recording for test: ${test_name}

Stop Test Recording
    [Documentation]    Stops video recording and embeds in report
    ${video_path}=    Stop Video Recording
    ${path_exists}=    Run Keyword And Return Status    Should Not Be Equal    ${video_path}    ${None}
    Run Keyword If    ${path_exists}    Log    Video saved to: ${video_path}
    ...    ELSE    Log    No video recording to save    level=WARN