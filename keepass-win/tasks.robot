*** Settings ***
Library     RPA.Windows
Library     RPA.FileSystem
Library     Collections
Library     RPA.Browser.Selenium
Library     RPA.Desktop

Suite Setup    Set Global Timeout    ${3}


*** Variables ***
${MAIN_WINDOW}    regex:"AutoDb.kdbx.*KeePass"
${DATABASE}    name:AutoDb


*** Keywords ***
Click Group If Visible
    [Arguments]    ${name}

    ${group} =    Get Element    ${DATABASE} > name:"${name}"
    # Checks if the element is not visible (not having dimensions), thus not clickable
    #  for some reason. (when disturbing the automation)
    IF    ${group.width} <= ${0} or ${group.height} <= ${0}
        Fail    Group ${name} not clickable!
    END

    RPA.Windows.Click    ${group}    wait_time=${0.1}


Display Items In Group
    Set Anchor    id:m_lvEntries

    TRY
        @{item_elems} =    Get Elements    type:ListItem    timeout=${0.5}
    EXCEPT    ElementNotFound.*    type=regexp
        Log    No group entries found!
        RETURN
    END

    Log List    ${item_elems}
    FOR    ${item}    IN    @{item_elems}
        Log    Fields in entry: ${item.name}
        @{value_elems} =    Get Elements    type:Text    root_element=${item}
        @{values} =    Evaluate    [elem.name for elem in $value_elems]
        Log List    ${values}
        Log To Console    ${item.name}: ${values}
    END

    [Teardown]    Clear Anchor


*** Tasks ***
Iterate Groups
    # [Setup]    PrepareKeepass
    ${main} =    Control Window    ${MAIN_WINDOW}  # once is enough

    # Print the tree of elements given the current state of the app.
    &{structure} =    Print Tree    max_depth=${32}    return_structure=${True}
    Log Dictionary    ${structure}  # for display purposes

    # Test element clicking from the returned structure above. (bugfix)
    @{elems} =    Get From Dictionary    ${structure}    ${7}  # on level 7
    ${email_elem} =    Get From List    ${elems}    ${0}  # pick the first element
    Log To Console    ${email_elem}
    RPA.Windows.Double Click    ${email_elem}  # works now (no offset error anymore)

    # Now list groups without relying on previous pulled elements on every iteration.
    @{groups} =    Get Elements    ${DATABASE} > type:TreeItemControl
    @{group_names} =    Create List
    FOR    ${group}    IN    @{groups}
        Append To List    ${group_names}    ${group.name}
    END
    Log List    ${group_names}

    # And process every existing group by its name and a new element retrieval each
    #  time.
    FOR    ${group_name}    IN    @{group_names}
        Control Window    ${main}
        Click Group If Visible    ${group_name}
        Display Items In Group
    END


List Groups
    # [Setup]    PrepareKeepass

    ${Window} =    Control Window    ${MAIN_WINDOW}
#    Print Tree    log_as_warnings=True
    ${FileExists} =    Does file exist    ListGroups
    IF    ${FileExists}    Remove File    ListGroups
    Create file    ListGroups    content=List Of Groups\n
    ${Root} =    Get Element    name:AutoDb
    Log    ${Root}    console=True
    # Set Anchor    type:TreeItem name:AutoDb
    ${Level} =    Create List
    ${Groups} =    Get Elements    type:TreeItemControl    search_depth=16    root_element=${Root}   # siblings_only=False
    Log List    ${groups}
    FOR    ${Group}    IN    @{Groups}
        Get a group and Output information    ${Group}    ${Window}    ${Level}
        # BREAK
    END


*** Keywords ***
PrepareKeepass
    ${Found} =    Set Variable    0
    ${Windows} =    List Windows
    FOR    ${Window}    IN    @{Windows}
        IF    '${Window}[name]' == 'KeePass.exe'
            Log    Window title:${Window}[title]
            ${WindowName} =    Set Variable    ${Window}[title]
            Log    ${WindowName}
            IF    '${WindowName}' == 'Open Database - AutoDb.kdbx'
                ${Found} =    Set Variable    1
                ${Window} =    Open Database
                BREAK
            ELSE IF    '${WindowName}' == 'AutoDb.kdbx - KeePass'
                ${Root} =    Set Window
                ${Found} =    Set Variable    2
                BREAK
            ELSE IF    '${WindowName}' == 'AutoDb.kdbx* - KeePass'
                ${Window} =    Save Modification    ${Window}
                ${Found} =    Set Variable    3
                BREAK
            END
        END
        Log    EndOfIF
    END
    Log    Found=${Found}

    IF    ${Found} == 0
        ${Window} =    Start KeePass
    END
    Print Tree    log_as_warnings=True
    TRY
        ${Cancel} =    Get Element    name:Cancel
        Log    Cancel=${Cancel}
        WHILE    '${Cancel.name}' == 'Cancel'
            RPA.Windows.Click    ${Cancel}
            ${Cancel} =    Get Element    name:Cancel
        END
    EXCEPT
        Log    No Error
    END
    Log To Console    Found=${Found}
    RETURN    ${Window}

Set Window
    ${Root} =    Control Window    ${MAIN_WINDOW}
    RETURN    ${Root}

Save Modification
    [Arguments]    ${Window}

    ${Root} =    Set Window
    Send Keys    ${Root}    keys={Ctrl}S
    RETURN    ${Root}

Start KeePass
    Windows Run    "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\KeePass 2"
    Open Database

Open Database
    ${Root} =    Control Window    ${MAIN_WINDOW}
    ${Window} =    SendPasswd    ${Root}
    RETURN    ${Root}

SendPasswd
    [Arguments]    ${Window}

    Log    ${Window}
    ${Passwd} =    Get Element    id:m_tbPassword    root_element=${Window}
    Send Keys    ${Passwd}    keys=hhsem
    RPA.Windows.Click    name:OK
    ${Root} =    Control Window    ${MAIN_WINDOW}
    RETURN    ${Root}

Get a group and Output information
    [Arguments]    ${Group}    ${Window}    ${Level}

    Log To Console    ${Group.name}
    Log    ${Group.name}
    ${CurLevel} =    Get Index From List    ${Level}    ${Group.left}
    IF    ${CurLevel} < ${0}
        Append To List    ${Level}    ${Group.left}
        ${CurLevel} =    Get Index From List    ${Level}    ${Group.left}
    END
    Append To File    ListGroups    content=Group: ${Group.name}; Level=${CurLevel}\n
    Log    Found: ${Group}    console=${True}
    Control Window    ${Window}
    RPA.Windows.Click    ${Group}
    List Group

List Group
    # ${Window} =    Control Window    regex:"AutoDb.kdbx.*KeePass"
    ${Entries} =    Get Element    id:m_lvEntries    # root_element=${Window}
    Log    'List Group: Elements=',${Entries}
    Find entries of KeePass    ${Entries}

Find entries of KeePass
    [Arguments]    ${Entries}

    ${Spalten} =    Create List
    # ${Window} =    Control Window    regex:"AutoDb.kdbx.*KeePass"

    @{headers} =    Get Elements    type:HeaderControl    root_element=${Entries}
    TRY
        @{listitems} =    Get Elements    type:ListItemControl    root_element=${Entries}    timeout=${0.2}
    EXCEPT
        @{listitems} =    Create List
    END
    @{Elements} =    Combine Lists    ${headers}    ${listitems}
    # @{Elements} =    Get Elements    search_depth=1    root_element=${Entries}    siblings_only=False

    ${LngElements} =    Get Length    ${Elements}
    Log    LengthOf Elements=${LngElements}
    FOR    ${Element}    IN    @{Elements}
        ${LngElements} =    Get Length    ${Elements}
        Log    Find entries of KeePass: ${Element.name} ${Element.control_type}
        IF    '${Element.control_type}' == 'HeaderControl'
            Get spalten    ${Element}    ${Spalten}
        ELSE IF    '${Element.control_type}' == 'ListItemControl'
            Get data of entry    ${Element}    ${Spalten}
        END
    END

Get spalten
    [Arguments]    ${Element}    ${Spalten}

    # ${Window} =    Control Window    regex:"AutoDb.kdbx.*KeePass"  # no need to do this everywhere
    # ${infos} =    Get Elements    type:HeaderItemControl    root_element=${Element}    # siblings_only=False
    ${infos} =    Get Elements    search_depth=1    root_element=${Element}    siblings_only=False
    ${Lng} =    Get Length    ${infos}
    Log    LengthOf Infos=${Lng}
    FOR    ${info}    IN    @{infos}
        ${Lng} =    Get Length    ${infos}
        Log    Get spalten: info=${info}
        IF    '${info.name}' == 'Headersteuerelement'
            Append To List    ${Spalten}    'Entry'
        ELSE
            Append To List    ${Spalten}    ${info.name}
        END
        Log    Get spalten: spalten=${Spalten}
    END

Get data of entry
    [Arguments]    ${Element}    ${Spalten}

    Log    Get data of entry: Spalten=${Spalten}
    # ${Window} =    Control Window    regex:"AutoDb.kdbx.*KeePass"
    ${infos} =    Get Elements    search_depth=1    root_element=${Element}    siblings_only=False
    FOR    ${info}    IN    @{infos}
        Log    ${info}
        ${Ix} =    Get Index From List    ${infos}    ${info}
        Log    Get data of entry: Ix=${Ix}
        IF    ${Ix} == 0
            Append To File    ListGroups    content=\t
        ELSE
            ${Col} =    Get From List    ${Spalten}    ${Ix}
            Append To File    ListGroups    content= ${Col}=${info.name};
        END
    END
    Append To File    ListGroups    content=\n
