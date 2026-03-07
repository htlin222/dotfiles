-- fetch-reminders.applescript
-- Returns JSON array of incomplete reminders from the "Inbox" list

tell application "Reminders"
    set targetList to list "Inbox"
    set jsonOutput to "["
    set isFirst to true

    set incompleteReminders to (every reminder of targetList whose completed is false)
    repeat with r in incompleteReminders
        try
            set rName to name of r
            set rBody to body of r
            if rBody is missing value then set rBody to ""
            set rDue to due date of r
            set rDueStr to rDue as string
            if rDue is missing value then set rDueStr to ""

            set rName to my escapeJSON(rName)
            set rBody to my escapeJSON(rBody)
            set rDueStr to my escapeJSON(rDueStr)

            if not isFirst then
                set jsonOutput to jsonOutput & ","
            end if
            set isFirst to false

            set jsonOutput to jsonOutput & "{\"name\":\"" & rName & "\","
            set jsonOutput to jsonOutput & "\"body\":\"" & rBody & "\","
            set jsonOutput to jsonOutput & "\"due\":\"" & rDueStr & "\"}"
        end try
    end repeat

    set jsonOutput to jsonOutput & "]"
    return jsonOutput
end tell

on escapeJSON(theText)
    set theText to theText as string
    set output to ""
    repeat with i from 1 to length of theText
        set c to character i of theText
        if c is "\"" then
            set output to output & "\\\""
        else if c is "\\" then
            set output to output & "\\\\"
        else if c is (ASCII character 10) then
            set output to output & "\\n"
        else if c is (ASCII character 13) then
            set output to output & "\\n"
        else if c is (ASCII character 9) then
            set output to output & "\\t"
        else
            set output to output & c
        end if
    end repeat
    return output
end escapeJSON
