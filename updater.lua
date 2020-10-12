local shell = require("shell")
local branch = "master"
local program = "router.lua"
shell.execute("wget -f -Q https://raw.githubusercontent.com/RandomProrammer/Blorcart-Nuclear-Reactor/"..branch.."/"..program.." run.lua")
shell.execute("run")