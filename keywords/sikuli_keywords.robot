*** Settings ***
Documentation    Reusable SikuliX keywords for test automation
Library          SikuliLibrary
Library          Collections

*** Keywords ***
Click Image
    [Documentation]    Click on an image with optional timeout
    [Arguments]    ${image_path}    ${timeout}=10
    Wait Until Screen Contain    ${image_path}    ${timeout}
    Sikuli Click    ${image_path}
    Log    Clicked on image: ${image_path}

Double Click Image
    [Documentation]    Double click on an image
    [Arguments]    ${image_path}    ${timeout}=10
    Wait Until Screen Contain    ${image_path}    ${timeout}
    Sikuli Double Click    ${image_path}
    Log    Double clicked on image: ${image_path}

Right Click Image
    [Documentation]    Right click on an image
    [Arguments]    ${image_path}    ${timeout}=10
    Wait Until Screen Contain    ${image_path}    ${timeout}
    Sikuli Right Click    ${image_path}
    Log    Right clicked on image: ${image_path}

Input Text
    [Documentation]    Type text using keyboard
    [Arguments]    ${text}
    Sikuli Type    ${text}
    Log    Typed text: ${text}

Press Key
    [Documentation]    Press a keyboard key
    [Arguments]    ${key}
    Sikuli Type    ${key}
    Log    Pressed key: ${key}

Screen Should Contain
    [Documentation]    Verify image exists on screen
    [Arguments]    ${image_path}    ${timeout}=5
    ${result}=    Wait Until Screen Contain    ${image_path}    ${timeout}
    Should Be True    ${result}
    Log    Verified screen contains: ${image_path}

Screen Should Not Contain
    [Documentation]    Verify image does not exist on screen
    [Arguments]    ${image_path}
    ${result}=    Screen Contains    ${image_path}
    Should Not Be True    ${result}
    Log    Verified screen does not contain: ${image_path}

Wait Until Screen Contain
    [Documentation]    Wait until image appears on screen
    [Arguments]    ${image_path}    ${timeout}=10
    Wait For Image    ${image_path}    ${timeout}
    Log    Image appeared: ${image_path}

Capture Screen
    [Documentation]    Capture screenshot
    [Arguments]    ${filename}
    Take Screenshot    ${filename}
    Log    Screenshot saved: ${filename}

Drag And Drop
    [Documentation]    Drag from source image to target image
    [Arguments]    ${source_image}    ${target_image}
    Sikuli Drag    ${source_image}
    Sikuli Drop    ${target_image}
    Log    Dragged from ${source_image} to ${target_image}

Hover Over Image
    [Documentation]    Move mouse over an image
    [Arguments]    ${image_path}    ${timeout}=10
    Wait Until Screen Contain    ${image_path}    ${timeout}
    Sikuli Hover    ${image_path}
    Log    Hovered over: ${image_path}

Click Image With Offset
    [Documentation]    Click on an image with offset
    [Arguments]    ${image_path}    ${x_offset}    ${y_offset}    ${timeout}=10
    Wait Until Screen Contain    ${image_path}    ${timeout}
    Sikuli Click    ${image_path}    ${x_offset}    ${y_offset}
    Log    Clicked on ${image_path} with offset (${x_offset}, ${y_offset})

Open Main Menu
    [Documentation]    Open the main menu
    Click Image    ${IMAGE_DIR}/menu_icon.png

Select Menu Option
    [Documentation]    Select a menu option by name
    [Arguments]    ${option_name}
    Click Image    ${IMAGE_DIR}/menu_${option_name}.png

Verify Settings Page Opened
    [Documentation]    Verify settings page is displayed
    Screen Should Contain    ${IMAGE_DIR}/settings_title.png

Go Back To Main Screen
    [Documentation]    Navigate back to main screen
    Click Image    ${IMAGE_DIR}/back_button.png
    Wait Until Screen Contain    ${IMAGE_DIR}/home_screen.png

Open Form Page
    [Documentation]    Open form page
    Click Image    ${IMAGE_DIR}/form_icon.png
    Wait Until Screen Contain    ${IMAGE_DIR}/form_header.png

Fill Form Fields
    [Documentation]    Fill multiple form fields
    [Arguments]    &{fields}
    FOR    ${field}    ${value}    IN    &{fields}
        Click Image    ${IMAGE_DIR}/${field}_field.png
        Input Text    ${value}
        Press Key    TAB
    END

Submit Form
    [Documentation]    Submit the form
    Click Image    ${IMAGE_DIR}/submit_button.png

Verify Submission Success
    [Documentation]    Verify form was submitted successfully
    Wait Until Screen Contain    ${IMAGE_DIR}/success_message.png    15
