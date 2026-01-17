-- module: dictation - Voice input with paste to terminal
-- Cmd+Shift+D to open, use dictation shortcut, Enter to paste
--
local M = {}

local lastApp = nil

function M.show()
    lastApp = hs.application.frontmostApplication()

    -- Auto-trigger dictation after dialog opens
    hs.timer.doAfter(0.3, function()
        hs.eventtap.keyStroke({"alt"}, "space")
    end)

    local button, text = hs.dialog.textPrompt(
        "Dictation",
        "Use Option+Space to dictate, then click OK",
        "",
        "OK",
        "Cancel"
    )

    if button == "OK" and text and text ~= "" then
        if lastApp then
            lastApp:activate()
        end

        hs.timer.doAfter(0.2, function()
            hs.pasteboard.setContents(text)
            hs.eventtap.keyStroke({"cmd"}, "v")
        end)
    elseif lastApp then
        lastApp:activate()
    end

    lastApp = nil
end

-- Bind hotkey
hs.hotkey.bind({"cmd", "shift"}, "D", M.show)

print("Dictation module loaded - Cmd+Shift+D to activate")

return M
