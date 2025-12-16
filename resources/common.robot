*** Settings ***
Documentation    Common resources and settings for all test suites
Library          OperatingSystem
Library          Collections
Library          String
Library          DateTime

*** Variables ***
# Test Environment
${ENV}           test
${BASE_URL}      http://localhost:8080

# Timeouts
${SHORT_TIMEOUT}     5s
${MEDIUM_TIMEOUT}    15s
${LONG_TIMEOUT}      30s

# Test Data
${TEST_USER}         testuser
${TEST_PASSWORD}     testpass123

*** Keywords ***
Initialize Test Environment
    [Documentation]    Setup test environment before each test
    Log    Initializing test environment
    Set Screenshot Directory    ${CURDIR}/../results
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    Set Suite Variable    ${TIMESTAMP}    ${timestamp}

Cleanup Test Environment
    [Documentation]    Clean up after test execution
    Log    Cleaning up test environment
    Capture Final Screenshot
    Delete Sikuli Log Files

Capture Final Screenshot
    Run Keyword If Test Failed    Capture Screen    ${CURDIR}/../results/failure_${TIMESTAMP}.png

Delete Sikuli Log Files
    [Documentation]    Delete temporary SikuliX log files
    ${project_root}=    Set Variable    ${CURDIR}/..
    Remove Files    ${project_root}/Sikuli_java_stderr_*
    Remove Files    ${project_root}/Sikuli_java_stdout_*
    Log    Deleted SikuliX temporary log files

Log Test Info
    [Arguments]    ${message}
    Log    ${message}    level=INFO
    Log To Console    ${message}
