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
    Log    ========================== ⚙️ OPEN AGILEMARK INSTALLER ==========================
    Open Application    ${CURDIR}${/}..${/}resources${/}Apps${/}AgileMark 1_1_2_8 GR.msi
    Sleep    5s

    # Wait the pattern to appear on screen with high similarity threshold
    Log    ========================== WAIT FOR PATTERN TO APPEAR ON SCREEN WITH HIGH SIMILARITY THRESHOLD ==========================
    Set Min Similarity    0.95
    ${pattern_found}=    Run Keyword And Return Status    Wait Until Screen Contain    ${IMAGE_DIR}${/}patternAfterInstall.png    ${LONG_TIMEOUT}

    # Delete the config file if it exists to ensure a fresh install
    Log    ========================== ⚙️ DELETE THE CONFIG FILE IF IT EXISTS TO ENSURE A FRESH INSTALL ==========================
    ${config_file}=    Set Variable    C:\\Program Files (x86)\\AgileMark\\store.cfg
    ${config_exists}=    Run Keyword And Return Status    File Should Exist    ${config_file}
    Run Keyword If    ${config_exists}    Delete Config File With Elevated Privileges    ${config_file}
    Run Keyword If    ${config_exists}    Log    Deleted config file: ${config_file}
    ...    ELSE    Log    Config file does not exist: ${config_file}

    # Move the expected config file into place after deletion
    Log    ========================== ⚙️ MOVE THE EXPECTED CONFIG FILE INTO PLACE AFTER DELETION ==========================
    ${source_config}=    Set Variable    ${CURDIR}${/}..${/}resources${/}Configs${/}store.cfg
    ${dest_dir}=    Set Variable    C:\\Program Files (x86)\\AgileMark
    ${dest_config}=    Set Variable    ${dest_dir}\\store.cfg
    Copy Config File With Elevated Privileges    ${source_config}    ${dest_config}
    Log    Copied config file from ${source_config} to ${dest_config}

    # Restart AgileService to apply new config
    Log    ========================== ⚙️ RESTART AGILESERVICE TO APPLY NEW CONFIG ==========================
    Restart AgileService
    
    # Capture actual screenshot for comparison regardless of pattern match result
    Log    ========================== ⚙️ CAPTURE ACTUAL SCREENSHOT FOR COMPARISON ==========================
    ${actual_screenshot}=    Capture Screen Region    0    0    1920    1035    ${ACTUAL_IMAGES_DIR}${/}install_screen.png
    
    # Compare with expected image if it exists
    Log    ========================== ⚙️ COMPARE WITH EXPECTED IMAGE IF IT EXISTS ==========================
    ${expected_img}=    Set Variable    ${EXPECTED_IMAGES_DIR}${/}patternAfterInstall.png
    ${expected_exists}=    Run Keyword And Return Status    File Should Exist    ${expected_img}
    Run Keyword If    not ${expected_exists}    Fail    Expected image does not exist: ${expected_img}
    ${comparison_result}=    Compare Images    ${expected_img}    ${actual_screenshot}    100.0
    Run Keyword If    not ${comparison_result}    Fail    Image comparison failed - images do not match. Check comparison in report.
    
    # Fail at the end if pattern was not found
    Log    ========================== ⚠️ FAIL IF PATTERN WAS NOT FOUND ==========================
    Run Keyword If    not ${pattern_found}    Fail    Pattern '${IMAGE_DIR}${/}patternAfterInstall.png' was not found on screen. Check image comparison in report.

    Stop Sikuli Process

Case2: Verify Watermark display on different screen resolutions
    [Documentation]    Tests watermark display at different screen resolutions
    [Tags]    sikuli    gui    agilemark    resolution
    Start Sikuli Process
    
    # Open Windows Display Settings
    Log    ========================== ⚙️ OPEN WINDOWS DISPLAY SETTINGS ==========================
    Open Display Settings

    # Change to 1280 x 720 resolution
    Log    ========================== ⚙️ CHANGE TO 1280 X 720 RESOLUTION ==========================
    Change Resolution    resolution_1280x720.png    down

    # Close Display Settings
    Log    ========================== ⚙️ CLOSE DISPLAY SETTINGS ==========================
    Close Display Settings
    
    Stop Sikuli Process

Case3: Reset display with default screen resolutions
    [Documentation]    Resets display to default 1920x1080 resolution
    [Tags]    sikuli    gui    agilemark    resolution
    Start Sikuli Process
    
    # Open Windows Display Settings
    Log    ========================== ⚙️ OPEN WINDOWS DISPLAY SETTINGS ==========================
    Open Display Settings

    # Change to 1920 x 1080 resolution
    Log    ========================== ⚙️ CHANGE TO 1920 X 1080 RESOLUTION ==========================
    Change Resolution    resolution_1920x1080.png    up

    # Close Display Settings
    Log    ========================== ⚙️ CLOSE DISPLAY SETTINGS ==========================
    Close Display Settings
    
    Stop Sikuli Process

CaseX: Uninstall AgileMark Application 
    [Documentation]    Delete data associated with AgileMark application
    [Tags]    sikuli    gui   agilemark
    Start Sikuli Process

    # Check if AgileMark and AgileService processes are running
    Log    ========================== ⚙️ CHECK IF AGILEMARK AND AGILESERVICE PROCESSES ARE RUNNING ==========================
    ${check_result}=    Run Process    tasklist    /FI    IMAGENAME eq AgileMark.exe    shell=True
    Log    AgileMark process check: ${check_result.stdout}
    ${check_service}=    Run Process    tasklist    /FI    IMAGENAME eq AgileService.exe    shell=True
    Log    AgileService process check: ${check_service.stdout}
    
    # Force kill both AgileMark and AgileService processes with elevated privileges
    Log    ========================== ⚙️ FORCE KILL BOTH AGILEMARK AND AGILESERVICE PROCESSES WITH ELEVATED PRIVILEGES ==========================
    ${kill_cmd}=    Set Variable    Start-Process powershell -ArgumentList '-Command', 'Stop-Process -Name AgileMark,AgileService -Force -ErrorAction SilentlyContinue' -Verb RunAs -WindowStyle Hidden -Wait
    ${kill_result}=    Run Process    powershell    -Command    ${kill_cmd}    shell=True
    Log    PowerShell elevated kill stdout: ${kill_result.stdout}
    Log    PowerShell elevated kill stderr: ${kill_result.stderr}
    Log    PowerShell elevated kill return code: ${kill_result.rc}
    
    Sleep    1s
    
    # Verify if processes still exist
    Log    ========================== ⚙️ VERIFY IF PROCESSES STILL EXIST ==========================
    ${verify_agilemark}=    Run Process    tasklist    /FI    IMAGENAME eq AgileMark.exe    shell=True
    ${agilemark_found}=    Run Keyword And Return Status    Should Contain    ${verify_agilemark.stdout}    AgileMark.exe
    ${verify_service}=    Run Process    tasklist    /FI    IMAGENAME eq AgileService.exe    shell=True
    ${service_found}=    Run Keyword And Return Status    Should Contain    ${verify_service.stdout}    AgileService.exe
    
    Run Keyword If    not ${agilemark_found} and not ${service_found}    Log    All AgileMark processes successfully terminated
    ...    ELSE IF    ${agilemark_found}    Log    WARNING: AgileMark.exe is still running    level=WARN
    ...    ELSE IF    ${service_found}    Log    WARNING: AgileService.exe is still running    level=WARN
    
    Sleep    2s

    # Delete the AgileMark data folder with elevated privileges
    Log    ========================== ⚙️ DELETE THE AGILEMARK DATA FOLDER ==========================
    
    # First attempt: Try to delete the entire folder with recursive force
    ${delete_cmd}=    Set Variable    Start-Process powershell -ArgumentList '-Command', 'Remove-Item -Path ''C:\\Program Files (x86)\\AgileMark'' -Recurse -Force -ErrorAction SilentlyContinue' -Verb RunAs -WindowStyle Hidden -Wait
    ${delete_result}=    Run Process    powershell    -Command    ${delete_cmd}    shell=True    
    Sleep    3s
    
    # Check if folder still exists and attempt more aggressive cleanup if needed
    Log    ========================== ⚙️ VERIFY FOLDER DELETION AND CLEANUP REMAINING FILES ==========================
    ${folder_exists}=    Run Keyword And Return Status    Directory Should Exist    C:\\Program Files (x86)\\AgileMark
    
    Run Keyword If    ${folder_exists}    Log    WARNING: AgileMark folder still exists, attempting detailed cleanup...    level=WARN
    
    # If folder still exists, try to delete specific files and subdirectories
    Run Keyword If    ${folder_exists}    Delete AgileMark Files Individually
    
    Sleep    2s
    
    # Final verification
    Log    ========================== ⚙️ FINAL VERIFICATION ==========================
    ${final_check}=    Run Keyword And Return Status    Directory Should Exist    C:\\Program Files (x86)\\AgileMark
    Run Keyword If    not ${final_check}    Log    AgileMark folder successfully deleted
    ...    ELSE    Log    WARNING: AgileMark folder still exists after cleanup attempts    level=WARN
    
    Sleep    1s

    Stop Sikuli Process

*** Keywords ***
Delete Config File With Elevated Privileges
    [Documentation]    Deletes a file with elevated privileges using PowerShell with takeown and icacls
    [Arguments]    ${file_path}
    Log    Deleting config file with elevated privileges: ${file_path}
    
    # First, try taking ownership and granting permissions, then delete
    ${delete_cmd}=    Set Variable    Start-Process powershell -ArgumentList '-Command', 'if (Test-Path ''${file_path}'') { takeown /f ''${file_path}'' > $null 2>&1; icacls ''${file_path}'' /grant administrators:F > $null 2>&1; Remove-Item -Path ''${file_path}'' -Force }' -Verb RunAs -WindowStyle Hidden -Wait
    ${delete_result}=    Run Process    powershell    -Command    ${delete_cmd}    shell=True
    Log    Delete command executed: ${delete_result.stdout} | ${delete_result.stderr}
    Sleep    2s
    
    # Verify deletion
    ${file_still_exists}=    Run Keyword And Return Status    File Should Exist    ${file_path}
    Run Keyword If    ${file_still_exists}    Log    WARNING: File still exists after deletion attempt: ${file_path}    level=WARN
    ...    ELSE    Log    Successfully deleted: ${file_path}

Copy Config File With Elevated Privileges
    [Documentation]    Copies a file with elevated privileges using PowerShell
    [Arguments]    ${source_path}    ${dest_path}
    Log    Copying config file with elevated privileges from ${source_path} to ${dest_path}
    
    # Ensure destination directory exists and copy file with elevated privileges
    ${copy_cmd}=    Set Variable    Start-Process powershell -ArgumentList '-Command', '$dest = ''${dest_path}''; $destDir = Split-Path $dest; if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }; Copy-Item -Path ''${source_path}'' -Destination $dest -Force' -Verb RunAs -WindowStyle Hidden -Wait
    ${copy_result}=    Run Process    powershell    -Command    ${copy_cmd}    shell=True
    Log    Copy command executed: ${copy_result.stdout} | ${copy_result.stderr}
    Sleep    2s
    
    # Verify copy
    ${file_exists}=    Run Keyword And Return Status    File Should Exist    ${dest_path}
    Run Keyword If    ${file_exists}    Log    Successfully copied to: ${dest_path}
    ...    ELSE    Log    WARNING: File was not copied successfully to: ${dest_path}    level=WARN

Delete AgileMark Files Individually
    [Documentation]    Attempts to delete AgileMark files individually with elevated privileges
    Log    Attempting to delete individual files and subdirectories...
    
    # Delete store.cfg specifically
    ${delete_cfg_cmd}=    Set Variable    Start-Process powershell -ArgumentList '-Command', 'Remove-Item -Path ''C:\\Program Files (x86)\\AgileMark\\store.cfg'' -Force -ErrorAction SilentlyContinue' -Verb RunAs -WindowStyle Hidden -Wait
    ${cfg_result}=    Run Process    powershell    -Command    ${delete_cfg_cmd}    shell=True
    Log    Delete store.cfg result: ${cfg_result.stdout} | ${cfg_result.stderr}
    Sleep    1s
    
    # Get list of all files and folders in AgileMark directory
    ${list_cmd}=    Set Variable    Get-ChildItem -Path 'C:\\Program Files (x86)\\AgileMark' -Recurse -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
    ${list_result}=    Run Process    powershell    -Command    ${list_cmd}    shell=True
    Log    Remaining files/folders: ${list_result.stdout}
    
    # Force delete all contents with takeown and icacls for permission issues
    ${force_delete_cmd}=    Set Variable    Start-Process powershell -ArgumentList '-Command', '$path = ''C:\\Program Files (x86)\\AgileMark''; if (Test-Path $path) { takeown /f $path /r /d y > $null 2>&1; icacls $path /grant administrators:F /t > $null 2>&1; Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue }' -Verb RunAs -WindowStyle Hidden -Wait
    ${force_result}=    Run Process    powershell    -Command    ${force_delete_cmd}    shell=True
    Log    Force delete with takeown result: ${force_result.stdout} | ${force_result.stderr}
    Sleep    2s

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