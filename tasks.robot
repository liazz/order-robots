*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium    auto_close=${False}
Library    RPA.HTTP
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.FileSystem
Library    RPA.Robocloud.Secrets
Library    Dialogs
Library    RPA.Tables


*** Variables ***
${receps_location}=    ${CURDIR}${/}recepts${/}


*** Tasks ***
order robts
    directory check
    download CSV file
    open the order robots website
    # pop up to go inside
    enter robot details
    compress PDFs to ZIP
    [Teardown]    Close Browser


*** Keywords ***
directory check
    ${recep_directory_exists}=    Does Directory Not Exist    ${receps_location}
    Create Directory    ${receps_location}


download CSV file
    ${csv_url}=    Get Value From User    Enter CSV URL    https://robotsparebinindustries.com/orders.csv
    Download    ${csv_url}    overwrite=${True}

open the order robots website
    ${URL}=    Get Secret    robotcred
    Open Available Browser    ${URL}[mainURL]
    Maximize Browser Window

pop up to go inside
    Click Button    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    Wait Until Element Is Visible    id=head

enter robot details
    ${robots_order_details}=    Read table from CSV    orders.csv
    FOR    ${element}    IN    @{robots_order_details}
        pop up to go inside
        IF    ${element}[Head] == 1
        ${head}    set Variable    Roll-a-thor head
        ELSE IF    ${element}[Head] == 2
            ${head}    set Variable    Peanut crusher head
        ELSE IF    ${element}[Head] == 3
            ${head}    set Variable    D.A.V.E head
        ELSE IF    ${element}[Head] == 4
            ${head}    set Variable    Andy Roid head
        ELSE IF    ${element}[Head] == 5
            ${head}    set Variable    Spanner mate head
        ELSE IF    ${element}[Head] == 6
            ${head}    set Variable    Drillbit 2000 head   
        END
        Select From List By Label    //*[@id="head"]    ${Head}
        # Click Element    id-body-1
        Select Radio Button    body    ${element}[Body]
        Input Text    class:form-control    ${element}[Legs]
        Input Text    address    ${element}[Address]
        Click Button    preview
        capture preview robot
        get places order details    ${element}
        Click Button    order-another
    END
    

capture preview robot
    Sleep    2s
    Screenshot    robot-preview-image    ${CURDIR}${/}robopreview.png
    Click Button    order
    Sleep    3s
    ${nextpage}=    Is Element Visible    id:receipt
    WHILE    ${nextpage} == False
        Click Button    order
        Sleep    3s
        ${nextpage}=    Is Element Visible    id:receipt
        WHILE    ${nextpage} == True
            BREAK
        END
        
    END

get places order details
    [Arguments]    ${element}
    ${recep}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${recep}    ${receps_location}${element}[Order number].pdf
    Open Pdf    ${receps_location}${element}[Order number].pdf
    Add Watermark Image To Pdf    robopreview.png    ${receps_location}${element}[Order number].pdf
    Close Pdf


compress PDFs to ZIP
    Archive Folder With Zip    ${receps_location}    ${OUTPUT_DIR}${/}1.zip