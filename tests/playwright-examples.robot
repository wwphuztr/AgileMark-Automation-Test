*** Settings ***
Documentation     Playwright Browser Library Examples
Library           Browser
Library           SikuliLibrary    mode=OLD    timeout=10
Library           ../libraries/WindowControlLibrary.py
Suite Setup       Create Browser Context
Suite Teardown    Close Browser


*** Variables ***
${BROWSER}        chromium    # Options: chromium, firefox, webkit
${HEADLESS}       ${False}    # Set to ${True} for headless mode


*** Test Cases ***
Case 1: Minimize Browser Using Windows API
    [Documentation]    Navigate and minimize only the browser window
    New Page    https://dev.agilemark.io:8443/auth
    Sleep    2s
    
    # Method 1: Minimize by window title (most reliable)
    Minimize Window By Title    AgileMark Control Panel
    Sleep    2s
    
    # Now you can interact with Windows desktop using SikuliX
    # The browser is minimized to taskbar
    
    # To restore the browser window:
    Restore Window By Title    AgileMark Control Panel - Google Chrome for Testing
    Sleep    1s


Case 2: List and Control Windows
    [Documentation]    Find and control specific windows
    New Page    https://dev.agilemark.io:8443/auth
    Sleep    1s
    
    # Get the window title
    ${title}=    Get Window Title    Chromium
    Log    Browser window title: ${title}
    
    # List all windows
    ${all_windows}=    List All Windows
    Log Many    @{all_windows}
    
    # Minimize browser
    Minimize Window By Title    Chromium
    Sleep    2s
    
    # Restore it back
    Restore Window By Title    Chromium


Case 3: Minimize All Browsers
    [Documentation]    Minimize all browser windows at once
    New Page    https://dev.agilemark.io:8443/auth
    Sleep    2s
    
    # Minimize all browsers (Chrome, Firefox, Edge, Chromium)
    ${minimized}=    Minimize All Browsers
    Log    Minimized browsers: ${minimized}

*** Keywords ***
Create Browser Context
    [Documentation]    Initialize browser with settings - Maximized with no address bar
    New Browser    ${BROWSER}    headless=${HEADLESS}    
    ...    args=['--start-maximized', '--disable-blink-features=AutomationControlled']
    
    # Use null viewport to allow maximized window
    New Context    viewport=${None}
