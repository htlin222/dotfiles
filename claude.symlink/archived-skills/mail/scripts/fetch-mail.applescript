-- fetch-mail.applescript
-- Usage: osascript fetch-mail.applescript <days>
-- Returns JSON array of emails from all accounts' inboxes within the time range

on run argv
    set dayCount to 1
    if (count of argv) > 0 then
        set dayCount to (item 1 of argv) as integer
    end if

    tell application "Mail"
        set cutoffDate to (current date) - dayCount * days
        set jsonOutput to "["
        set isFirst to true
        set allAccounts to every account

        repeat with acct in allAccounts
            set acctName to name of acct
            set allMailboxes to every mailbox of acct

            repeat with mb in allMailboxes
                set mbName to name of mb
                -- Match common inbox names across locales
                if mbName is "INBOX" or mbName is "收件匣" then
                    try
                        set msgs to (every message of mb whose date received > cutoffDate)
                    on error
                        set msgs to {}
                    end try

                    repeat with msg in msgs
                        try
                            set msgId to message id of msg
                            set subj to subject of msg
                            set sndr to sender of msg
                            set dt to date received of msg
                            set isRead to read status of msg
                            set body to content of msg
                            if length of body > 800 then
                                set body to text 1 thru 800 of body
                            end if

                            -- Escape JSON special chars
                            set subj to my escapeJSON(subj)
                            set sndr to my escapeJSON(sndr)
                            set body to my escapeJSON(body)
                            set msgId to my escapeJSON(msgId)
                            set dtStr to my escapeJSON(dt as string)

                            if not isFirst then
                                set jsonOutput to jsonOutput & ","
                            end if
                            set isFirst to false

                            set jsonOutput to jsonOutput & "{\"id\":" & "\"" & msgId & "\","
                            set jsonOutput to jsonOutput & "\"account\":\"" & my escapeJSON(acctName) & "\","
                            set jsonOutput to jsonOutput & "\"subject\":\"" & subj & "\","
                            set jsonOutput to jsonOutput & "\"from\":\"" & sndr & "\","
                            set jsonOutput to jsonOutput & "\"date\":\"" & dtStr & "\","
                            set jsonOutput to jsonOutput & "\"read\":" & isRead & ","
                            set jsonOutput to jsonOutput & "\"preview\":\"" & body & "\"}"
                        end try
                    end repeat
                end if
            end repeat
        end repeat

        set jsonOutput to jsonOutput & "]"
        return jsonOutput
    end tell
end run

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
