*** Settings ***
Documentation    SikuliX integration test examples
...              Demonstrates visual recognition and GUI automation with SikuliX
Library          SikuliLibrary    mode=OLD    timeout=10
Library          OperatingSystem
Library          Process
Library          Collections
Suite Setup      Start Sikuli Process
Suite Teardown   Cleanup After Suite

*** Variables ***
${IMAGE_DIR}     ${CURDIR}${/}..${/}resources${/}images
${TIMEOUT}       10
${LONG_TIMEOUT}  20

*** Test Cases ***
Case1: Install AgileMark Application 
    [Documentation]    Installs the AgileMark application
    [Tags]    sikuli    gui   agilemark    
    Start Sikuli Process
    # Open AgileMark installer
    Open Application    ${CURDIR}${/}..${/}resources${/}Apps${/}AgileMark 1_1_2_8 GR.msi

    # Wait for installer window to appear
    Wait Until Screen Contain    ${IMAGE_DIR}${/}DePIN${/}pattern.png    ${LONG_TIMEOUT}
    
    Stop Sikuli Process

Case2: Uninstall AgileMark Application 
    [Documentation]    Delete data associated with AgileMark application
    [Tags]    sikuli    gui   agilemark
    Start Sikuli Process

    # Check if AgileMark and AgileService processes are running
    ${check_result}=    Run Process    tasklist    /FI    IMAGENAME eq AgileMark.exe    shell=True
    Log    AgileMark process check: ${check_result.stdout}
    ${check_service}=    Run Process    tasklist    /FI    IMAGENAME eq AgileService.exe    shell=True
    Log    AgileService process check: ${check_service.stdout}
    
    # Force kill both AgileMark and AgileService processes with elevated privileges
    ${kill_cmd}=    Set Variable    Start-Process powershell -ArgumentList '-Command', 'Stop-Process -Name AgileMark,AgileService -Force -ErrorAction SilentlyContinue' -Verb RunAs -WindowStyle Hidden -Wait
    ${kill_result}=    Run Process    powershell    -Command    ${kill_cmd}    shell=True
    Log    PowerShell elevated kill stdout: ${kill_result.stdout}
    Log    PowerShell elevated kill stderr: ${kill_result.stderr}
    Log    PowerShell elevated kill return code: ${kill_result.rc}
    
    Sleep    1s
    
    # Verify if processes still exist
    ${verify_agilemark}=    Run Process    tasklist    /FI    IMAGENAME eq AgileMark.exe    shell=True
    ${agilemark_found}=    Run Keyword And Return Status    Should Contain    ${verify_agilemark.stdout}    AgileMark.exe
    ${verify_service}=    Run Process    tasklist    /FI    IMAGENAME eq AgileService.exe    shell=True
    ${service_found}=    Run Keyword And Return Status    Should Contain    ${verify_service.stdout}    AgileService.exe
    
    Run Keyword If    not ${agilemark_found} and not ${service_found}    Log    All AgileMark processes successfully terminated
    ...    ELSE IF    ${agilemark_found}    Log    WARNING: AgileMark.exe is still running    level=WARN
    ...    ELSE IF    ${service_found}    Log    WARNING: AgileService.exe is still running    level=WARN
    
    Sleep    2s

    # Delete the AgileMark data folder
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