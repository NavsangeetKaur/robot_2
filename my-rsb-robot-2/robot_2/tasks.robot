*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Calendar
Library             RPA.Archive
Library             RPA.JavaAccessBridge


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Click that button
    Download the orders file
    ${orders}    Read csv file
    FOR    ${row}    IN    @{orders}
        Fill the form    ${row}
        Preview the robot
        Wait Until Keyword Succeeds    3x    2s    Submit the Order
        ${file_path_pdf}    Store order as a PDF    ${row}[Order number]    # !Problem nachfragen
        ${file_path_png}    Screenshot of the robot image    ${row}[Order number]
        Embed Screenshot to the PDF    ${file_path_pdf}    ${file_path_png}
        Order another Robot
        Click that button
    END

    Create Zip file

    # Log To Console    Head: ${row}[Head]
    # Log To Console    Order number: ${row}[Order number]
    # Log To Console    Body: ${row}[Body]
    # Log To Console    Legs: ${row}[Legs]
    # Log To Console    Address: ${row}[Address]


*** Keywords ***
Open the robot order website
    RPA.Browser.Selenium.Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the orders file
    RPA.HTTP.Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Read csv file
    ${table}    RPA.Tables.Read Table From Csv    orders.csv
    RETURN    ${table}

Click that button    # rights aufgeben
    Click Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    Log To Console    button 'ok' geklickt

Fill the form
    [Arguments]    ${row}
    # Head auswählen -> Dropdown
    Select From List By Index    //*[@id="head"]    ${row}[Head]
    Log To Console    dropdown erfolgreich ausgewählt

    # Body auswählen -> Radio Button
    IF    ${row}[Body] == 1
        Radio Button Should Not Be Selected    body
        Select Radio Button    body    1
        Log To Console    Checkbox 1 ausgewählt
    ELSE IF    ${row}[Body] == 2
        Radio Button Should Not Be Selected    body
        Select Radio Button    body    2
        Log To Console    Checkbox 2 ausgewählt
    ELSE IF    ${row}[Body] == 3
        Radio Button Should Not Be Selected    body
        Select Radio Button    body    3
        Log To Console    Checkbox 3 ausgewählt
    ELSE IF    ${row}[Body] == 4
        Radio Button Should Not Be Selected    body
        Select Radio Button    body    4
        Log To Console    Checkbox 4 ausgewählt
    ELSE IF    ${row}[Body] == 5
        Radio Button Should Not Be Selected    body
        Select Radio Button    body    5
        Log To Console    Checkbox 5 ausgewählt
    ELSE IF    ${row}[Body] == 6
        Radio Button Should Not Be Selected    body
        Select Radio Button    body    6
        Log To Console    Checkbox 6 ausgewählt
    END

    # Legs eintragen
    RPA.Browser.Selenium.Input Text    xpath://*[@placeholder="Enter the part number for the legs"]    ${row}[Legs]
    Log To Console    Legs erfolgreich eingetragen

    # Adresse eintragen
    RPA.Browser.Selenium.Input Text    //*[@id="address"]    ${row}[Address]
    Log To Console    Adresse erfolgreich eingetragen

Preview the robot
    RPA.Browser.Selenium.Click Button    //*[@id="preview"]
    Log To Console    preview erstellt

Submit the Order
    Log To Console    Trying to hit the Order Button
    RPA.Browser.Selenium.Wait Until Page Contains Element    //*[@id="order"]
    RPA.Browser.Selenium.Click Button    //*[@id="order"]
    RPA.Browser.Selenium.Wait Until Element Is Visible    //*[@id="receipt"]    2s
    Log To Console    Clicked on Order-Button: Order einsenden

Store order as a PDF
    [Arguments]    ${order_number}
    ${file_path_pdf}    Set Variable    D:\\my-rsb-robot-2\\robot_2//output//receipt//receipt_${order_number}.pdf
    ${order_html}    Get Element Attribute    //*[@id="receipt"]    outerHTML
    Html To Pdf    ${order_html}    ${file_path_pdf}
    RETURN    ${file_path_pdf}
    Log To Console    Order erfolgreich als PDF abgespeichert

Screenshot of the robot image
    [Arguments]    ${order_number}
    ${file_path_png}    Set Variable    D:\\my-rsb-robot-2\\robot_2//output//receipt//receipt_${order_number}.png
    RPA.Browser.Selenium.Screenshot    //*[@id="robot-preview-image"]    ${file_path_png}
    RETURN    ${file_path_png}
    Log To Console    Screenshot vom Roboter erfolgreich abgespeichert

Embed Screenshot to the PDF
    [Arguments]    ${Pdf}    ${Screenshot}
    RPA.PDF.Open Pdf    ${Pdf}
    RPA.PDF.Add Watermark Image To Pdf    ${Screenshot}    ${Pdf}
    RPA.PDF.Save Pdf    ${Pdf}
    # RPA.PDF.Close Pdf    ${Pdf}    # !Problem nachfragen
    Log To Console    Screenshort erfolgreich in die PDF Datei eingefügt

Order another Robot
    RPA.Browser.Selenium.Click Button    //*[@id="order-another"]
    Log To Console    Order another Roboter ausgewählt

Create Zip file
    ${zip_file}    Set Variable    D:\\my-rsb-robot-2\\robot_2//output//receipts.zip
    Archive Folder With Zip    D:\\my-rsb-robot-2\\robot_2//output//receipt*.pdf    ${zip_file}
    Log To Console    Zip erstellt
