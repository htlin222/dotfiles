-- fetch-reminders.applescript
-- Returns JSON array of incomplete reminders from the "Inbox" list
-- Usage: osascript fetch-reminders.applescript
-- Optimized: batch-fetch properties to avoid per-reminder AppleScript round-trips

with timeout of 30 seconds
	tell application "Reminders"
		try
			set targetList to list "Inbox"
		on error
			return "[]"
		end try

		try
			set rNames to name of every reminder of targetList whose completed is false
			set rBodies to body of every reminder of targetList whose completed is false
			set rDates to due date of every reminder of targetList whose completed is false
		on error
			return "[]"
		end try

		set reminderCount to count of rNames
		if reminderCount is 0 then return "[]"

		set jsonOutput to "["

		repeat with i from 1 to reminderCount
			set rName to item i of rNames
			set rBody to item i of rBodies
			set rDue to item i of rDates

			-- Handle missing values
			if rName is missing value then set rName to ""
			if rBody is missing value then set rBody to ""
			set rDueStr to ""
			if rDue is not missing value then
				try
					set rDueStr to rDue as string
				end try
			end if

			set rName to my escapeJSON(rName)
			set rBody to my escapeJSON(rBody)
			set rDueStr to my escapeJSON(rDueStr)

			if i > 1 then
				set jsonOutput to jsonOutput & ","
			end if

			set jsonOutput to jsonOutput & "{\"name\":\"" & rName & "\","
			set jsonOutput to jsonOutput & "\"body\":\"" & rBody & "\","
			set jsonOutput to jsonOutput & "\"due\":\"" & rDueStr & "\"}"
		end repeat

		set jsonOutput to jsonOutput & "]"
		return jsonOutput
	end tell
end timeout

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
