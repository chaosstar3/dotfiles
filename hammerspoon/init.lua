-- copy to ~/.hammerspoon/init.lua
package.path = package.path .. ";/path/to/dotfiles/hammerspoon/?.lua;"#
snap = require("snap")
task = snap.task

-- example
snap.window.regist()
apps = {
	dir="finder", term="wezterm",
	web="firefox", editor="visual studio code", kb="obsidian", git="fork",
	hello=task.task("/bin/echo", {os.getenv("HOME") .. "HELLO"})
}
task.regist("option", {"term", "dir", "web", "editor", "git"})
task.regist("option+shift", {[3]="web_alt", [4]="kb"})
