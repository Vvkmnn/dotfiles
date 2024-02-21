
-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
-- config.default_prog = { '/bin/bash','-l' }
-- config.default_prog = { '/bin/zsh','-l','-c','tmux attach -A || tmux' }

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'

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
