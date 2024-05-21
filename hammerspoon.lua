-- copy to ~/.hammerspoon/init.lua
-- snap app
apps = {term="wezterm", term_alt='terminal', dir="finder", web="firefox", editor="code"}
applist = {apps['term'], apps["dir"], apps["web"], apps["editor"], "fork"}
appAlt = {[1]=apps['term_alt']}

for i, app in pairs(applist) do
	hs.hotkey.bind("option", tostring(i), function() hs.application.launchOrFocus(app) end)
end

-- snap window
ratio_conf = {50, 33, 90, 66}

M = {MOVE=1, RESIZE=2}
D = {UP=1, DOWN=2, LEFT=3, RIGHT=4, CENTER=5}
W = {WIDTH=1, HEIGHT=2}
prev_m = nil
prev_d = nil
move = 0

function win_maximize()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local s = win:screen():frame()
	win:setFrame(s)
end

function win_move(method, direction)
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local s = win:screen():frame()
	--print("from: ", f)
	--print("screen: ", s)

	local way         -- resizing way
	local pos_r = 0   -- resized position ratio

	if direction == D.UP then
		way = W.HEIGHT
	elseif direction == D.DOWN then
		way = W.HEIGHT
		pos_r = 1
	elseif direction == D.LEFT then
		way = W.WIDTH
	elseif direction == D.RIGHT then
		way = W.WIDTH
		pos_r = 1
	else -- direction == D.CENTER then
		if s.w >= s.h then
			way = W.WIDTH
		else
			way = W.HEIGHT
		end
		pos_r = 0.5
	end

	if prev_m == method and prev_d == direction then
		move = move + 1
	else
		prev_m = method
		prev_d = direction
		move = 0
	end

	local ratio = ratio_conf[move % #ratio_conf + 1]/100
	--print("ratio: ", ratio)

	if way == W.WIDTH then
		f.x = s.x + s.w * (1-ratio)*pos_r
		f.w = s.w * ratio
	elseif way == W.HEIGHT then
		f.y = s.y + s.h * (1-ratio)*pos_r
		f.h = s.h * ratio
	end

	if method == M.MOVE then
		if way == W.WIDTH then
			f.y = s.y
			f.h = s.h
		elseif way == W.HEIGHT then
			f.x = s.x
			f.w = s.w
		end
	end

	prev_m = method
	prev_d = direction
	--print("to: ", f)
	win:setFrame(f)
end

function win_move_monitor(direction)
	local win = hs.window.focusedWindow()
	local m = nil
	if direction > 0 then
		m = win:screen():next()
	else
		m = win:screen():previous()
	end

	if m ~= win:screen() then
		win:moveToScreen(m, 0)
	end
end

function test()
	print("test")
	local menubar = hs.menubar.new()
	local stext = hs.styledtext.new("test")

	local toggle = true
	local timer = hs.timer.doEvery(1, function()
		if(toggle) then
			stext = stext:setStyle({color=hs.drawing.color.red})
		else
			stext = stext:removeStyle({"color"})
		end
		toggle = not toggle
		menubar:setTitle(stext)
	end)

	menubar:setClickCallback(function()
		timer:stop()
		menubar:delete()
	end)
end


hs.hotkey.bind("ctrl", "t", test)
hs.hotkey.bind("option", "left", function() win_move(M.MOVE, D.LEFT) end)
hs.hotkey.bind("option", "right", function() win_move(M.MOVE, D.RIGHT) end)
hs.hotkey.bind("option", "up", function() win_move(M.MOVE, D.UP) end)
hs.hotkey.bind("option", "down", function() win_move(M.MOVE, D.DOWN) end)
hs.hotkey.bind({"cmd", "option"}, "left", function() win_move(M.RESIZE, D.LEFT) end)
hs.hotkey.bind({"cmd", "option"}, "right", function() win_move(M.RESIZE, D.RIGHT) end)
hs.hotkey.bind({"cmd", "option"}, "up", function() win_move(M.RESIZE, D.UP) end)
hs.hotkey.bind({"cmd", "option"}, "down", function() win_move(M.RESIZE, D.DOWN) end)
hs.hotkey.bind({"option", "shift"}, "left", function() win_move_monitor(-1) end)
hs.hotkey.bind({"option", "shift"}, "right", function() win_move_monitor(1) end)
hs.hotkey.bind({"option", "shift"}, "up", win_maximize)
hs.hotkey.bind({"option", "shift"}, "down", function() win_move(M.MOVE, D.CENTER) end)

