local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

config.window_close_confirmation = 'AlwaysPrompt'
-- UI
config.enable_scroll_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.window_background_opacity = 0.87

-- Key Binding
local keys_default = {
	{ key = 'a', mods = 'CTRL|SHIFT', action = act.EmitEvent 'toggle-leader' },
}
local keys_mux = {
	-- TMUX-LIKE
	{ key = 'a', mods = 'LEADER', action = act.SendKey { key = 'a', mods = 'CTRL' }},
	{ key = 'a', mods = 'LEADER|CTRL', action = act.ActivateLastTab },
	{ key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
	{ key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
	{ key = '"', mods = 'LEADER', action = act.SplitVertical },
	{ key = '|', mods = 'LEADER', action = act.SplitPane { direction = 'Right' } },
	{ key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
	-- TODO: resize with key table
	{ key = 'LeftArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
	{ key = 'RightArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
	{ key = 'UpArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
	{ key = 'DownArrow', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
	{ key = '{', mods = 'LEADER', action = act.PaneSelect },
	{ key = '}', mods = 'LEADER', action = act.PaneSelect { mode = 'SwapWithActive' } },
	{ key = ',', mods = 'LEADER', action = act.PromptInputLine {
		description = 'Enter new name for tab',
		action = wezterm.action_callback(function(window, pane, line)
			if line then window:active_tab():set_title(line) end
		end),
	}},
}
for i = 0, 9 do
	table.insert(keys_mux, { key = tostring(i), mods = 'LEADER', action = wezterm.action.ActivateTab(i-1)})
end

function merge(t1, t2)
	local t = {}
	table.move(t1, 1, #t1, #t+1, t)
	table.move(t2, 1, #t2, #t+1, t)
	return t
end

local keys_on_leader = merge(keys_default, keys_mux)

config.keys = keys_on_leader
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

wezterm.on('toggle-leader', function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if overrides.leader then
		-- restore to config
		overrides.keys = nil
		overrides.leader = nil
	else
		overrides.keys = keys_default
		overrides.leader = { key = '_', mods = 'CTRL|ALT|SHIFT|SUPER' }
	end
	window:set_config_overrides(overrides)
end)

return config
