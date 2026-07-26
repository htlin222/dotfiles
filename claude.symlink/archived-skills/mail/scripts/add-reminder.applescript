-- add-reminder.applescript
-- Usage: osascript add-reminder.applescript "<name>" "<body>" "<due_date>" "<priority>"
-- priority: 0=none, 1=high, 5=medium, 9=low
-- due_date format: "2026-03-20 17:00"

on run argv
    set reminderName to item 1 of argv
    set reminderBody to item 2 of argv
    set dueDateStr to item 3 of argv
    set priorityVal to (item 4 of argv) as integer

    tell application "Reminders"
        set targetList to list "Inbox"

        if dueDateStr is not "" then
            -- Parse "YYYY-MM-DD HH:MM" format
            set y to text 1 thru 4 of dueDateStr as integer
            set m to text 6 thru 7 of dueDateStr as integer
            set d to text 9 thru 10 of dueDateStr as integer
            set h to text 12 thru 13 of dueDateStr as integer
            set mn to text 15 thru 16 of dueDateStr as integer

            set dueDate to current date
            set year of dueDate to y
            set month of dueDate to m
            set day of dueDate to d
            set hours of dueDate to h
            set minutes of dueDate to mn
            set seconds of dueDate to 0

            make new reminder in targetList with properties {name:reminderName, body:reminderBody, due date:dueDate, priority:priorityVal}
        else
            make new reminder in targetList with properties {name:reminderName, body:reminderBody, priority:priorityVal}
        end if

        return "OK"
    end tell
end run
