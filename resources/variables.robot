*** Variables ***
# Application Paths
${APP_PATH}          C:/Program Files/YourApp/app.exe

# Image Directory
${IMAGE_DIR}         ${CURDIR}/../images

# Result Directory
${RESULT_DIR}        ${CURDIR}/../results

# SikuliX Settings
${SIKULI_TIMEOUT}    10
${SIMILARITY}        0.8

# Screen Regions (x, y, width, height)
${LOGIN_REGION}      100,100,400,300
${MAIN_REGION}       0,0,1920,1080

# Test Data Files
${TEST_DATA_DIR}     ${CURDIR}/../test_data

# Logging
${LOG_LEVEL}         INFO
