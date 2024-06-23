-- snap app
apps = {sh="wezterm", sh_alt="terminal", dir="finder", web="Firefox", web2="whale", editor_alt="IntelliJ IDEA", editor="Visual Studio Code", git="fork", ppt="Microsoft PowerPoint"}
applist = {apps["sh"], apps["dir"], apps["web"], apps["editor"], apps["git"], apps["code"]}
applistAlt = {[1]=apps['sh_alt'], [3]=apps["web2"], [4]=apps["editor_alt"]}
for i, app in pairs(applist) do
	hs.hotkey.bind("option", tostring(i), function() hs.application.launchOrFocus(app) end)
end
for i, app in pairs(applistAlt) do
	hs.hotkey.bind({"option","shift"}, tostring(i), function() hs.application.launchOrFocus(app) end)
end


-- snap window
ratio_conf = {50, 66, 90, 33}

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

macro = {
	sc="hardstatus alwayslastline \"%{bW}%-w%{rW}%n*%t%{-}%+w %= %c %H\"",
	utf8="export LC_ALL=\"ko_KR.utf8\" && export LANG=\"ko_KR.utf8\"",
	euckr="export LC_ALL=\"ko_KR.euckr\" && export LANG=\"ko_KR.euckr\""
}


function dialog()
	button, text = hs.dialog.textPrompt("test", "test2")

	if macro[text] then
		hs.pasteboard.setContents(macro[text])
	end

end

hs.hotkey.bind("option", "left", function() win_move(M.MOVE, D.LEFT) end)
hs.hotkey.bind("option", "right", function() win_move(M.MOVE, D.RIGHT) end)
hs.hotkey.bind("option", "up", function() win_move(M.MOVE, D.UP) end)
hs.hotkey.bind("option", "down", function() win_move(M.MOVE, D.DOWN) end)
hs.hotkey.bind({"option", "cmd"}, "left", function() win_move(M.RESIZE, D.LEFT) end)
hs.hotkey.bind({"option", "cmd"}, "right", function() win_move(M.RESIZE, D.RIGHT) end)
hs.hotkey.bind({"option", "cmd"}, "up", function() win_move(M.RESIZE, D.UP) end)
hs.hotkey.bind({"option", "cmd"}, "down", function() win_move(M.RESIZE, D.DOWN) end)
hs.hotkey.bind({"option", "shift"}, "left", function() win_move_monitor(-1) end)
hs.hotkey.bind({"option", "shift"}, "right", function() win_move_monitor(1) end)
hs.hotkey.bind({"option", "shift"}, "up", win_maximize)
hs.hotkey.bind({"option", "shift"}, "down", function() win_move(M.MOVE, D.CENTER) end)
--hs.hotkey.bind({"option", "shift"}, "space", dialog)
