-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
-- config.default_prog = { '/bin/bash','-l' }
-- config.default_prog = { '/bin/zsh','-l','-c','tmux attach -A || tmux' }

-- For example, changing the color scheme:
-- config.color_scheme = "Catppuccin Mocha"

-- local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
-- custom.background = "#000000"
-- custom.tab_bar.background = "#040404"
-- custom.tab_bar.inactive_tab.bg_color = "#0f0f0f"
-- custom.tab_bar.new_tab.bg_color = "#080808"
--
-- color_schemes = { ["OLEDppuccin"] = custom }
-- color_scheme = "OLEDppuccin"

-- Custom {{{
-- Fancy
config.hide_tab_bar_if_only_one_tab = true
-- config.adjust_window_size_when_changing_font_size = false

-- Close
config.window_close_confirmation = "NeverPrompt"

-- opacity
-- config.window_background_opacity = 0.88
-- config.window_background_opacity = 0.91 + math.random() / 100
-- config.window_background_opacity = 0.95 + math.random() / 100
-- config.window_background_opacity = 0.977
config.window_background_opacity = 0.93
-- config.macos_window_background_blur = 20
config.macos_window_background_blur = 77
config.win32_system_backdrop = "Acrylic"
-- config.window_background_opacity = 0.961

-- config.inactive_pane_hsb = {
--  saturation = 0.8
--  brightness = 0.7
-- }
--
-- config.color_scheme = 'Hardcore'
-- config.font = wezterm.font("JetBrainsMono Nerd Font")
-- config.font = wezterm.font("JetBrains Mono")
config.font = wezterm.font_with_fallback({ "JetBrainsMono Nerd Font", "JetBrains Mono" })
config.font_size = 13
config.line_height = 1.2
config.use_dead_keys = false
config.scrollback_lines = 6666

-- TITLE bar
-- window_decorations = "TITLE | RESIZE"
-- config.window_decorations = "RESIZE|MACOS_FORCE_ENABLE_SHADOW"
config.window_decorations = "RESIZE|MACOS_FORCE_ENABLE_SHADOW"

-- cursor
config.colors = {}
config.colors.cursor_bg = "#FFFFFF"
config.colors.cursor_fg = "#000000"
config.colors.cursor_border = "#FFFFFF"
-- config.colors.cursor_style = BlinkingBlock
-- config.cursor_blink_rate = 1000
-- config.default_cursor_style = "BlinkingBar"
-- config.cursor_bg = "#000000"
-- config.colors.cursor_fg = "white"
-- config.colors.cursor_border = "white"

-- hyperlink
-- Use the defaults as a base
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- make task numbers clickable
-- the first matched regex group is captured in $1.
table.insert(config.hyperlink_rules, {
	regex = [[\b[tt](\d+)\b]],
	format = "https://example.com/tasks/?t=$1",
})

-- make username/project paths clickable. this implies paths like the following are for github.
-- ( "nvim-treesitter/nvim-treesitter" | wbthomason/packer.nvim | wez/wezterm | "wez/wezterm.git" )
-- as long as a full url hyperlink regex exists above this it should not match a full url to
-- github or gitlab / bitbucket (i.e. https://gitlab.com/user/project.git is still a whole clickable url)
table.insert(config.hyperlink_rules, {
	regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
	format = "https://www.github.com/$1/$3",
})

-- config.background = {
-- 	-- This is the deepest/back-most layer. It will be rendered first
-- 	{
-- 		source = { Gradient = { preset = "Warm" } },
--
-- 		-- The texture tiles vertically but not horizontally.
-- 		-- When we repeat it, mirror it so that it appears "more seamless".
-- 		-- An alternative to this is to set `width = "100%"` and have
-- 		-- it stretch across the display
-- 		repeat_x = "Mirror",
-- 		hsb = dimmer,
-- 		-- When the viewport scrolls, move this layer 10% of the number of
-- 		-- pixels moved by the main viewport. This makes it appear to be
-- 		-- further behind the text.
-- 		attachment = { Parallax = 0.1 },
-- 	},
-- 	{
-- 		source = { Gradient = { preset = "Plasma" } },
--
-- 		-- The texture tiles vertically but not horizontally.
-- 		-- When we repeat it, mirror it so that it appears "more seamless".
-- 		-- An alternative to this is to set `width = "100%"` and have
-- 		-- it stretch across the display
-- 		repeat_x = "Mirror",
-- 		hsb = dimmer,
-- 		-- When the viewport scrolls, move this layer 10% of the number of
-- 		-- pixels moved by the main viewport. This makes it appear to be
-- 		-- further behind the text.
-- 		attachment = { Parallax = 0.2 },
-- 	},
-- }

-- Function to generate a random window background gradient
-- local function generate_random_gradient()
--   -- Define color lists for variety
--   local colors1 = { "#191919", "#0f0c29", "#24243e", "#000000", "#141E30", "#243B55" }
--   local colors2 = { "#EEBD89", "#D13ABD", "#434343", "#24243e", "#0f0c29" }
--
--   -- Initialize the random seed
--   math.randomseed(os.time())
--
--   -- Randomly select one color from each list
--   local color_from_list1 = colors1[math.random(#colors1)]
--   local color_from_list2 = colors2[math.random(#colors2)]
--
--   -- Configure the gradient with randomly selected colors and linear orientation
--   return {
--     colors = { color_from_list1, color_from_list2 },
-- orientation = { Linear = { angle = math.random() * 360 } },
--   }
-- end

-- Apply the generated gradient to the window background
-- config.window_background_gradient = generate_random_gradient(),

wezterm.on("window-focus-changed", function(window, pane)
	-- wezterm.on("window-resized", function(window, pane)
	-- wezterm.on("window-resized", function(window, pane)
	-- Define two separate color lists for variety
	-- local colors1 = { "#191919", "#0f0c29", "#24243e", "#141E30",  "#243B55", "#2E3440" }
	-- local colors2 = { "#EEBD89", "#D13ABD", "#434343", "#24243e", "#0f0c29", "#81A1C1" }
	local colors1 = { "#000000", "#191919", "#1a1823", "#24273a" }
	local colors2 = { "#141E30", "#0f0c29", "#131020", "#24273A" }

	-- Initialize the random seed based on the current time
	math.randomseed()

	-- Select one color from each list randomly
	local color_from_list1 = colors1[math.random(#colors1)]
	local color_from_list2 = colors2[math.random(#colors2)]

	-- Set the window background gradient with the randomly selected colors
	window:set_config_overrides({
		window_background_gradient = {
			colors = { color_from_list1, color_from_list2 },
			orientation = { Linear = { angle = -(math.random() * 100) } },
		},
		-- window_background_opacity = 0.97 + math.random() / 100,
		-- window_background_opacity = 1,
	})
end)

-- config.window_background_gradient = {
--
-- 	colors = (function()
-- 		local colors1 = { "#191919", "#0f0c29", "#24243e" }
-- 		local colors2 = { "#141E30", "#24243e" }
--
-- 		math.randomseed()
--
-- 		return { colors1[math.random(#colors1)], colors2[math.random(#colors2)] }
-- 	end)(), -- Immediately invoke the anonymous function
-- 	orientation = { Linear = { angle = -(math.random() * 100) } },
-- }

-- config.window_background_gradient = {
-- -- colors = { "deeppink", "gold" },
-- 	-- colors = { "black", "gray" },
-- 	-- colors = { "deeppink", "gold" },
-- 	-- colors = { "#000000", "#141E30", "#243B55", "#0f0c29", "#24243e" },
-- 	colors = { "#000000", "#0f0c29" },
-- 	orientation = {
-- 		Radial = {
-- 			-- Specifies the x coordinate of the center of the circle,
-- 			-- in the range 0.0 through 1.0.  The default is 0.5 which
-- 			-- is centered in the X dimension.
-- 			cx = math.random(), -- 0.75,
--
-- 			-- Specifies the y coordinate of the center of the circle,
-- 			-- in the range 0.0 through 1.0.  The default is 0.5 which
-- 			-- is centered in the Y dimension.
-- 			cy = math.random(),
--
-- 			-- Specifies the radius of the notional circle.
-- 			-- The default is 0.5, which combined with the default cx
-- 			-- and cy values places the circle in the center of the
-- 			-- window, with the edges touching the window edges.
-- 			-- Values larger than 1 are possible.
-- 			radius = 1 + math.random(),
-- 		},
-- 	},
-- }

-- and finally, return the configuration to wezterm
return config

--
-- config.default_prog = { '/bin/zsh', '-l' }
-- config.default_prog = { '/bin/bash'}
-- config.default_prog = { 'top' }

-- -- window split
-- -- Leader is the same as my old tmux prefix
-- config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }
-- config.keys = {
--   -- splitting
--   {
--     mods   = "LEADER",
--     key    = "-",
--     action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }
--   },
--   {
--     mods   = "LEADER",
--     key    = "=",
--     action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }
--   }
-- }
--
