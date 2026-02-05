local M = {}
local portable = require "utils.portable"

-- Be sure to explicitly define these LuaSnip node abbreviations!
local ls = require("luasnip")
local sn = ls.snippet_node
local i = ls.insert_node

function M.date_input(args, snip, old_state, fmt)
	local format = fmt or "%Y-%m-%d"
	return sn(nil, i(1, os.date(format)))
end

function M.get_visual(args, parent)
	if #parent.snippet.env.LS_SELECT_RAW > 0 then
		return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
	else
		return sn(nil, i(1, ""))
	end
end

function M.current_time()
	return os.date("%Y-%m-%d-[%H:%M]")
end

function M.get_buffer_last_modified_time()
	local buffer_name = vim.fn.expand("%:p") -- 獲取當前緩衝區的完整路徑

	-- 檢查緩衝區名稱是否為 nil 或空串
	if buffer_name == nil or buffer_name == "" then
		return "緩衝區名稱為空或不存在"
	end

	if vim.fn.executable("stat") ~= 1 then
		return "stat 命令不可用"
	end

	local stat_cmd
	if portable.os() == "Darwin" then
		-- macOS: `stat -f %m` 取得最後修改時間
		stat_cmd = "stat -f %m "
	else
		-- Linux: `stat -c %Y` 取得最後修改時間
		stat_cmd = "stat -c %Y "
	end

	local handle = io.popen(stat_cmd .. buffer_name)
	local result = handle:read("*a")
	handle:close()

	-- 檢查結果是否為 nil
	if result == nil then
		return "無法執行 stat 命令"
	end

	-- 轉換為數字，並使用 os.date 格式化
	local timestamp = tonumber(result)
	if timestamp then
		return os.date("%Y-%m-%d[%H:%M]", timestamp)
	else
		return "無法獲取時間"
	end
end

function M.switchIM()
	local handle = io.popen("uname -a") -- 執行 uname -a 並取得輸出
	local result = handle:read("*a")
	handle:close()

	if string.match(result, "GNU") then -- 如果輸出中包含 "GNU"
		os.execute("fcitx5-remote -t > /dev/null 2>&1")
	else
		local handle = io.popen("im-select")
		local result = handle:read("*a")
		handle:close()

		-- 檢查輸出並根據結果執行命令
		if result:find("com.boshiamy.inputmethod.BoshiamyIMK") then
			os.execute("im-select com.apple.keylayout.ABC > /dev/null 2>&1")
		elseif result:find("com.apple.keylayout.ABC") then
			os.execute("im-select com.boshiamy.inputmethod.BoshiamyIMK > /dev/null 2>&1")
		end
	end
	-- 使用 io.popen 執行命令並獲取輸出
end

function M.ret_filename()
	return vim.fn.expand("%:r")
end

function M.date()
	return os.date("%Y-%m-%d")
end

function M.weather()
	local command = "curl -s wttr.in/Taipei\\?format='%c%t\\n'"
	local data = vim.fn.system(command)
	local weather = tostring(data):gsub("\n", "")
	return weather
end


function M.imgur()
	local command = "$HOME/.pyenv/versions/keyboardmaestro/bin/python $HOME/pyscripts/cliptoimgur.py"
	vim.fn.system(command)
	vim.cmd("put")
end

function M.previous()
	if vim.g.previous == nil or vim.g.previous == "" then
		return "index"
	else
		return vim.g.previous
	end
end

function M.alias()
	if vim.g.alias == nil or vim.g.alias == "" then
		return "index"
	else
		return vim.g.alias
	end
end

function M.copy(args)
	return args[1]
end

function M.bash(_, _, command)
	local file = io.popen(command, "r")
	local res = {}
	for line in file:lines() do
		table.insert(res, line)
	end
	return res
end

return M

-- local helpers = require('helpers')
