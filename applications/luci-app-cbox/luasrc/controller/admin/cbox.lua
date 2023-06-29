--[[
LuCI - Lua Configuration Interface
$Id: cannatrol.lua 12/12/2014 by Hostle 
]]--

module("luci.controller.admin.cbox", package.seeall)

require ("uci")
require ("luci.sys")
local cbox = require ("cbox.libcbox")


function index()
        local uci = uci.cursor()
	
	entry({"admin", "cbox", "start"}, call("action_start"))
	entry({"admin", "cbox", "restart"}, call("action_restart")) 
	entry({"admin", "cbox", "clear"}, call("action_clear")) 
	entry({"admin", "cbox", "stop"}, call("action_stop"))

    	entry({"admin", "cbox", "fan1Act"}, call("action_start_fan1"))
	entry({"admin", "cbox", "fan2Act"}, call("action_start_fan2"))
	entry({"admin", "cbox", "fan3Act"}, call("action_start_fan3"))
	entry({"admin", "cbox", "fan4Act"}, call("action_start_fan4"))
	entry({"admin", "cbox", "fan1Term"}, call("action_stop_fan1"))
	entry({"admin", "cbox", "fan2Term"}, call("action_stop_fan2"))
	entry({"admin", "cbox", "fan3Term"}, call("action_stop_fan3"))
	entry({"admin", "cbox", "fan4Term"}, call("action_stop_fan4"))


end

function action_start()
  cbox.start_log()
 return
end

function action_restart()
  cbox.restart_log()
 return
end

function action_clear()
  cbox.clear_log()
 return
end

function action_stop()
  cbox.stop_log()
 return
end

function action_start_fan1()
  cbox.startFan(1)
 return
end

function action_stop_fan1()
  cbox.stopFan(1)
 return
end

function action_start_fan2()
  cbox.startFan(2)
 return
end

function action_stop_fan2()
  cbox.stopFan(2)
 return
end

function action_start_fan3()
  cbox.startFan(3)
 return
end

function action_stop_fan3()
  cbox.stopFan(3)
 return
end

function action_start_fan4()
  cbox.startFan(4)
 return
end

function action_stop_fan4()
  cbox.stopFan(4)
 return
end


