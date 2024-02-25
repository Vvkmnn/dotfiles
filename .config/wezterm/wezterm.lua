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
adjust_window_size_when_changing_font_size = false

-- opacity
-- config.window_background_opacity = 0.88
-- config.window_background_opacity = 0.97 + math.random() / 100
config.window_background_opacity = 0.99

-- config.inactive_pane_hsb = {
--  saturation = 0.8
--  brightness = 0.7
-- }
--
-- config.color_scheme = 'Hardcore'
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 14
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

--
--
-- }}}

config.window_background_gradient = {
	-- 	-- colors = { "#EEBD89", "#D13ABD" },
	-- 	-- colors = { "#0f0c29", "#24243e" },
	-- 	colors = { "#000000", "##434343" },
	-- -- Combine all the colors into a single table
	-- local allColors = { "#EEBD89", "#D13ABD", "#0f0c29", "#24243e", "#000000", "#434343", "#0f0c29", "#141E30", "#243B55" },
	--
	-- -- Randomly select two colors from the table (allowing duplicate selections)
	-- math.randomseed(os.time()),
	-- colors = { allColors[math.random(#allColors)],
	-- 	allColors[math.random(#allColors)] },
	--
	-- -- Example usage: print the selected colors
	-- -- print(
	--
	-- colors = { selectedColors[1], selectedColors[2] },

	-- Combine all the colors into a single table
	-- local allColors = { "#EEBD89", "#D13ABD", "#0f0c29", "#24243e", "#000000", "#434343", "#0f0c29", "#141E30", "#243B55" }
	--
	-- -- Initialize the random seed
	-- math.randomseed(os.time())
	--
	-- -- Randomly select two colors from the table (allowing duplicate selections)
	-- local colors = { allColors[math.random(#allColors)], allColors[math.random(#allColors)] }
	--
	-- -- Example usage: print the selected colors
	-- print(colors[1], colors[2])

	colors = (function()
		local colors1 = { "#191919", "#0f0c29", "#24243e" }
		local colors2 = { "#141E30", "#24243e", "#302b63" }
		-- { "#191919", "#0f0c29", "#000000", "#191919", "#24243e", "#0f0c29" },
		-- { "#191919", "#0f0c29", "#000000", "#191919", "#24243e", "#0f0c29" },
		-- { "#EEBD89", "#D13ABD", "#0f0c29", "#24243e", "#000000", "#434343", "#0f0c29", "#141E30", "#243B55" }
		-- { "#0f0c29", "#24243e", "#000000", "#0f0c29", "#141E30" }
		-- math.randomseed(os.time()) -- Initialize the random seed

		math.randomseed(os.time()) -- Initialize the random seed
		-- Return two randomly selected colors
		return { colors1[math.random(#colors1)], colors2[math.random(#colors2)] }
	end)(), -- Immediately invoke the anonymous function

	-- colors = { "#0f0c29", "#000000" },
	-- colors = { "#191919", "#000000" },
	-- colors = { "#191919", "#0f0c29" },
	-- colors = { "#24243e", "#0f0c29" },
	-- colors = { "#24243e", "#0f0c29" },
	-- Specifices a Linear gradient starting in the top left corner.
	orientation = { Linear = { angle = -(math.random() * 100) } },
}

-- config.window_background_gradient = {
-- 	-- colors = { "deeppink", "gold" },
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
