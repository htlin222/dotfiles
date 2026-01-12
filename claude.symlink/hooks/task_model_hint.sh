#!/bin/bash
# PreToolUse:Task hook - remind about model selection for sub-agents
# Fires BEFORE spawning a Task agent, so model choice can be influenced

# stdout: visible to Claude as system message
# message: visible to user in terminal
echo '{"continue": true, "stdout": "💡 Consider model:haiku for Edit/Explore tasks", "message": "💡 Task hint: prefer haiku for simple tasks"}'
