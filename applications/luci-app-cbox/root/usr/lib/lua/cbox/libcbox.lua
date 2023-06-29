--[[
FireWrt - Lua Configuration Interface
$Id: libcbox.lua 8382 2021-04-21 16:45:20
$ Hostle : hostle@fire-wrt.com
]]--

module("cbox.libcbox", package.seeall)

require("luci.sys")
require("nixio")
require ("uci")
require "ubus"

-- Establish ubus connection
local conn = ubus.connect()
if not conn then
    error("Failed to connect to ubusd")
end


local function getTemp()
	
	local target = "http://192.168.1.192/TMP/"
	local tmp = conn:call("cbox", "readSensors", { target = target})
	local uci = uci.cursor();
	local conf = "cboxStats";
	local sec = "temp";
	local buf = {};

	if(tmp.error) then 
		return tmp.error;
	else
		for temp in string.gmatch(tmp.result, '([^,]+)') do
    			--print(hum)
			buf[#buf+1]=temp;	
		end

		local tmp1 = buf[1] or '?';
		local tmp2 = buf[2] or '?';
		local tmp3 = buf[3] or '?';
		local avg = (tonumber(tmp1) + tonumber(tmp2) + tonumber(tmp3)) / 3;

		uci:set(conf,sec,"sen1Temp",tmp1);
		uci:set(conf,sec,"sen2Temp",tmp2);
		uci:set(conf,sec,"sen3Temp",tmp3);
		uci:set(conf,sec,"avgTemp",avg);
		uci:commit(conf);
		--print(temp);
	end
end

local function getHum()
	local target = "http://192.168.1.192/HUM/"
	local hum = conn:call("cbox", "readSensors", { target = target})
	local uci = uci.cursor();
	local conf = "cboxStats";
	local sec = "hum";
	local buf = {};

	if(hum.error) then 
		return hum.error
	else
		for hum in string.gmatch(hum.result, '([^,]+)') do
    			--print(hum)
			buf[#buf+1]=hum;
		end

		local hum1 = buf[1] or '?';
		local hum2 = buf[2] or '?';
		local hum3 = buf[3] or '?';
		local avg = (tonumber(hum1)  + tonumber(hum3)) / 2;

		uci:set(conf,sec,"sen1Hum",hum1);
		uci:set(conf,sec,"sen2Hum",hum2);
		uci:set(conf,sec,"sen3Hum",hum3);
		uci:set(conf,sec,"avgHum",avg);
		uci:commit(conf);
		--print(humidity);
	end

end


local line_cnt = 0
local log_file = "/tmp/cbox.log"

local function create_log()
local file, err = assert(io.open(log_file, 'w'))
	if(file) then 
  		file:write('Canabox Server is Not Connected !!\n');
  		file:close();
	end
 return
end

if not nixio.fs.stat(log_file) then create_log() end

local function trun_file(data)
  local file = io.open(log_file, "w")
  file:write(data)
  file:close()
  return
end

local function get_size()
  local line_cnt = 1
  local file = io.open(log_file, "r")
  for line in file:lines() do
    if line and line ~= "" then line_cnt = line_cnt + 1 end
  end
  file:close()
 return line_cnt
end

local function read_log(maxlines,ln)
  local lines = get_size()
  local file = io.open(log_file, "r")

  if(tonumber(lines) > tonumber(maxlines)) then
    for i=1, (lines - maxlines) do
      local line = file:read("*l")
      ln[i] = line
    end
    local data = file:read("*a")
    file:close()
    for j,v in pairs(ln) do
      data:gsub(v, "")
    end
    trun_file(data)
  end

  local file = io.open(log_file, "r")
  for i=1, lines do
    local line = file:read("*l")
    ln[i] = line
  end
  file:close()
 return ln
end

function startFan(fan)
  local uci = uci.cursor();
  local conf = "cboxStats";
  local sec = "fan";
  local cmdStr = string.format("lua /root/readSensors.lua %s 1", fan);
  local file = io.popen(cmdStr)
  file:close()
  uci:set(conf,sec,"fan"..fan,1);
  uci:commit(conf);
  return
end

function stopFan(fan)
  local uci = uci.cursor();
  local conf = "cboxStats";
  local sec = "fan";
  local cmdStr = string.format("lua /root/readSensors.lua %s 0", fan);
  local file = io.popen(cmdStr)
  file:close()
  uci:set(conf,sec,"fan"..fan,0);
  uci:commit(conf);
  return
end



function temps()
	getTemp();
	local rv = {};
	local uci = uci.cursor();
	local conf = "cboxStats";
	local sec = "temp";

	local ln = {};
  		ln[1]=uci:get(conf,sec,"avgTemp");
  		ln[2]=uci:get(conf,sec,"sen3Temp");
  		ln[3]=uci:get(conf,sec,"sen2Temp");
  		ln[4]=uci:get(conf,sec,"sen1Temp");
  		ln[5]=uci:get(conf,sec,"sen3Temp");
  		ln[6]=uci:get(conf,sec,"sen3Temp");
  		ln[7]=uci:get("cboxSvr","temp","TEMP_HIGH");
  		ln[8]=uci:get("cboxSvr","temp","TEMP_LOW");

	if (ln) then
		rv[#rv+1] = {
		 		 	  ln = {
		 					ln[1] or '00.00',
		 					ln[2] or '00.00',
		 					ln[3] or '00.00',
		 					ln[4] or '00.00',
		 					ln[5] or '00.00',
		 					ln[6] or '00.00',
		 					ln[7] or '00.00',
		 					ln[8] or '00.00'			
						   }
		  		    }
	end;
  return rv;
end

function fans()
	local rv = {};
	local sec = "fan"
	local conf = "cboxStats"
	local uci = uci.cursor()

	local cd = {};
    	cd[1]= uci:get(conf,sec,"fan1");
    	cd[2]= uci:get(conf,sec,"fan2");
    	cd[3]= uci:get(conf,sec,"fan3");
    	cd[4]= uci:get(conf,sec,"fan4");

	if (cd) then
		rv[#rv+1] = {
						cd = {
								cd[1] or 'Reading ...',
								cd[2] or 'Reading ...',
								cd[3] or 'Reading ...',
								cd[4] or 'Reading ...'
			     			 }
		    		}
	end;
	return rv
end

function hums()
	getHum();
	local rv = {};
	local sec = "hum";
	local conf = "cboxStats";
	local uci = uci.cursor();

	local hs = {};
		hs[1]= uci:get(conf,sec,"avgHum");
		hs[2]= uci:get(conf,sec,"sen3Hum");
		hs[3]= uci:get(conf,sec,"sen2Hum");
		hs[4]= uci:get(conf,sec,"sen1Hum");
		hs[5]= uci:get(conf,sec,"sen4Hum");
		hs[6]= uci:get(conf,sec,"sen4Hum");
		hs[7]= uci:get("cboxSvr","temp","HUM_HIGH");
		hs[8]= uci:get("cboxSvr","temp","HUM_LOW");

	if (hs) then
		rv = { }
			rv[#rv+1] = {
						   hs = {
								  hs[1] or '00.00',
								  hs[2] or '00.00',
								  hs[3] or '00.00',
								  hs[4] or '00.00',
								  hs[5] or '00.00',
								  hs[6] or '00.00',
								  hs[7] or '00.00',
								  hs[8] or '00.00'
						        }
						 }
	end
	return rv
end

function log()
  local rv = { }
  local ln = { }
  local maxlines = 19
  
  read_log(maxlines,ln)
  if (ln) then
    rv[#rv+1] = {
		 ln = {
		 	ln[1] or '',
		 	ln[2] or '',
		 	ln[3] or '',
		 	ln[4] or '',
		 	ln[5] or '',
		 	ln[6] or '',
		 	ln[7] or '',
		 	ln[8] or '',
		 	ln[9] or '',
		 	ln[10] or '',
		 	ln[11] or '',
		 	ln[12] or '',
		 	ln[13] or '',
		 	ln[14] or '',
		 	ln[15] or '',
		 	ln[16] or '',
			ln[17] or '',
		 	ln[18] or '',
		 	ln[19] or ''
		       }
		  }
    end
  return rv
end

function clear_log()
  luci.sys.exec("echo '' > /tmp/cbox.log &>/dev/null")
 return
end

function start_log()
  luci.sys.exec("/etc/init.d/cboxServer start >/dev/null &")
 return
end

function restart_log()
  luci.sys.exec("/etc/init.d/cboxServer restart >/dev/null &")
 return
end

function stop_log()
  luci.sys.exec("/etc/init.d/cboxServer stop >/dev/null &")
 return
end

function log_running()
  local file = io.popen("pidof cboxServer")
  local pid = file:read("*l")
  file:close()
  if pid then return true end
 return false
end