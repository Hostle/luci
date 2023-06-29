require ("uci")

local uci = uci.cursor();
local conf  = "cbox";
local t_sec = "temp";
local h_sec = "hum";
local f_sec = "fan";

local configs = {

		['avgTemp'] 	= function (key,val) uci:set(conf,t_sec,tostring(key),tostring(val)); end;
		['avgHum'] 	= function (key,val) uci:set(conf,h_sec,tostring(key),tostring(val)); end;
		['sen1Temp'] 	= function (key,val) uci:set(conf,t_sec,tostring(key),tostring(val)); end;
		['sen1Hum'] 	= function (key,val) uci:set(conf,h_sec,tostring(key),tostring(val)); end;
		['sen2Temp'] 	= function (key,val) uci:set(conf,t_sec,tostring(key),tostring(val)); end;
		['sen2Hum'] 	= function (key,val) uci:set(conf,h_sec,tostring(key),tostring(val)); end;
		['sen3Temp'] 	= function (key,val) uci:set(conf,t_sec,tostring(key),tostring(val)); end;
		['sen3Hum'] 	= function (key,val) uci:set(conf,h_sec,tostring(key),tostring(val)); end;
		['fan1'] 	= function (key,val) uci:set(conf,f_sec,tostring(key),tostring(val)); end;
		['fan2'] 	= function (key,val) uci:set(conf,f_sec,tostring(key),tostring(val)); end;
		['fan3'] 	= function (key,val) uci:set(conf,f_sec,tostring(key),tostring(val)); end;
		['fan4'] 	= function (key,val) uci:set(conf,f_sec,tostring(key),tostring(val)); end;
	}



--################################################ Logger Function ###########################################--

local function logger(msg,dir)
  local log_file = "/tmp/cbox.log"
  local dte = os.date()
  local rsp
  if tostring(dir) == "svr" then snd = "==> " rsp = "ARD" else snd = "<== " rsp ="GL" end
   local file = io.open(log_file, "a+")
   file:write(string.format("%s [ %s ]  %s:\n%s\n\n",snd,dte,rsp,msg))
   file:close()
 return
end

--<==========================================================================================================>--


function setStats(Cbuf)
	print("UPDATING UCI CONFIGS ...");
	for k,v in pairs(Cbuf) do
		for a,b in pairs(configs) do
			if(k == a) then
				b(a,v);
			end;
		end;
	end;
	print("COMMITING CHANGES");
	uci:commit(conf);
	print("CONFIG UPDATE SUCCESS");
  return;
end

function tweaktable(Cbuf)
	setStats(Cbuf);
	local Lbuf = {numfields=1};
	for k,v in pairs(Cbuf) do
		--logger(string.format("{sensor : %s value : %s}", k,v), "svr");
		Lbuf.numfields = Lbuf.numfields + 1;
		Lbuf[tostring(k)] = string.upper(tostring(v));
	end;
	Lbuf.numfields = tostring(Lbuf.numfields);

	return Lbuf;
end

print("Initializing CBOX CONTROLLER ...");