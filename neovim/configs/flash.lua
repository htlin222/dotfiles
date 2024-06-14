return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		lable = {
			labels = "fsdgerwtyuxcvbnm",
			rainbow = {
				enabled = true,
				-- number between 1 and 9
				shade = 5,
			},
		},
		modes = {
			char = {
				enabled = false,
				keys = { "F" },
				label = { exclude = "hjkliardcf" },
				char_actions = function(motion)
					return {
						["f"] = "next", -- set to `right` to always go right
						["F"] = "prev", -- set to `left` to always go left
						-- clever-f style
						[motion:lower()] = "next",
						[motion:upper()] = "prev",
						-- jump2d style: same case goes next, opposite case goes prev
						-- [motion] = "next",
						-- [motion:match("%l") and motion:upper() or motion:lower()] = "prev",
					}
				end,
			},
		},
	},
}
