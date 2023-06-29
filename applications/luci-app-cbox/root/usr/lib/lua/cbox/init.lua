
local libcannabox2 = {
	bufferFile = "/etc/cannabox/buffers/queue";
	cmd = "";
	portName = "";
	port = "";
	verbose = 1;
	err = "";
	readBuffer = {};
	writeBuffer = {};
	Serial = require("luars232");

	
};

SERIAL = {
	BAUD = 115200;
	DATA_BITS = 8;
	PARITY = 'NONE';
	STOP_BITS = 1;
	FLOW_CONTROL = 'OFF';
};


--## LIBUCI-LUA FOR UCI CONFIGURATION MANAGEMENT ##--
require('uci');

--## LUA-RS232 FOR SERIAL PORT COMMS ##--
local Serial = require("luars232")

-----------------------------------------------------------[[ RS232 SERIAL FUNCTIONS TO INTERACT WITH ARDUINO ]]------------------------------------------------------------

--## AVAILABLE SERIAL PORT CONFIGURATION VALUES ##--
baud_rates = {
	[9600] 		= Serial.RS232_BAUD_9600;
	[19200]		= Serial.RS232_BAUD_19200;
	[38400]		= Serial.RS232_BAUD_38400;
	[57600]		= Serial.RS232_BAUD_57600;
	[115200]	= Serial.RS232_BAUD_115200;
};

data_bits = {
	[6] 		= Serial.RS232_DATA_6;
	[7] 		= Serial.RS232_DATA_7;
	[8] 		= Serial.RS232_DATA_8;
};

stop_bits = {
	[1] 		= Serial.RS232_STOP_1;
	[2] 		= Serial.RS232_STOP_2;
};

parity_bits = {
	["NONE"] 	= Serial.RS232_PARITY_NONE;
	["ODD"]		= Serial.RS232_PARITY_ODD;
	["EVEN"]	= Serial.RS232_PARITY_EVEN;
};

flow_control = {
	["OFF"]		= Serial.RS232_FLOW_OFF;
	["HW"]		= Serial.RS232_FLOW_HW;
	["XONXOFF"]	= Serial.RS232_FLOW_XON_XOFF;
};

--## FUNCTION TO OPEN SERIAL PORT ##--
function libcannabox2.openPort(self,portName,Serial, verbose) 
local Serial = require("luars232")
local ok = 0;
local failed = 1;
local err, port = Serial.open(portName)
	-- handle any errors and send them to stderr for debugging
	if err ~= Serial.RS232_ERR_NOERROR then
		if(verbose > 0) then print(string.format("FAILED TO OPEN SERAIL PORT '%s', error: '%s'\n", portName, Serial.error_tostring(err))) end;
		return failed, err;
	end
 	assert(port:set_baud_rate(baud_rates[SERIAL.BAUD]) == Serial.RS232_ERR_NOERROR)
	assert(port:set_data_bits(data_bits[SERIAL.DATA_BITS]) == Serial.RS232_ERR_NOERROR)
	assert(port:set_parity(parity_bits[SERIAL.PARITY]) == Serial.RS232_ERR_NOERROR)
	assert(port:set_stop_bits(stop_bits[SERIAL.STOP_BITS]) == Serial.RS232_ERR_NOERROR)
	assert(port:set_flow_control(flow_control[SERIAL.FLOW_CONTROL])  == Serial.RS232_ERR_NOERROR)
	self.err = err
	self.port = port;
	self.portName= portName;
	self.verbose = verbose or 1;
  	return ok, port;
end

--## FUNCTION TO PRINT IN COLOR ##--
function printColor(string,color)
local esc = '\27[0m\n';
local colors = { 
red = '\27[91m';
yellow = '\27[93m';
green = '\27[92m';
};
	if string and color then
		for k,v in pairs(colors) do
			if(color == k) then
				string = v..string..esc
				break;
			end
		end
	end
	return(string);
end


--## FUNCTION TO WRITE TO SERIAL PORT ##--
function libcannabox2.writePort(self,port, data, timeout)
local writeBuffer = self.writeBuffer;
local port = self.port;
local portName = self.portName;
local verbose = self.verbose;
local bytesSent = tostring(data):len()+1 or 1;
local ok = 0;
local failed = 1;

	 if(verbose > 0) then print(string.format("==> WRITING ( %d )bytes TO PORT [%s]", bytesSent, portName)) end;
	local error, written_len = port:write(data..'\n',timeout);
	if(written_len) then
		--writeBuffer[#writeBuffer+1] = data
		if(written_len == bytesSent) then
			if(verbose > 0) then 
				print(string.format("TRANSMISSION SUCCESSFUL ( %d/%d bytes ) WRITTEN TO PORT [%s] \n" ,written_len, bytesSent, portName)) end;
				print(string.format(printColor("<== DATA SENT  %s ","red"), printColor(data,"green")));
			port:flush();
			return tonumber(ok), data;
		end;
	end;
	if(verbose > 0) then print(string.format("TRANSMISSION FAILED ( %d/%d bytes ) WRITTEN TO PORT [%s] \n" ,written_len, bytesSent, portName)) end;
	port:flush();
	return tonumber(failed), error;
end

--## FUNCTION TO READ FROM SERIAL PORT ##--
function libcannabox2.readPort(self,port,read_len, timeout, forced)
local port = self.port;
local portName = self.portName;
local readBuffer = self.readBuffer;
local verbose = self.verbose;
local read_len = tonumber(read_len) or 3;
local timeout = tonumber(timeout) or 1000;
local forced = tonumber(forced) or 0;
local ok = 0;
local failed = 1;

	if(verbose > 0) then print(string.format("<== READING ( %d )bytes FROM PORT [%s] WITH TIMEOUT ( %d )ms" ,read_len, portName, timeout)) end;	
	local error, data, read_len = port:read(read_len,timeout,forced)
	
	if(data) then
		--readBuffer[#readBuffer+1] = data
		local size = data:len() or 0;
		if(verbose > 0) then 
			print(string.format("TRANSMISSION SUCCESSFUL ( %d/%d bytes ) RECIEVED FROM PORT [%s] \n" ,read_len, size, portName))
			print(string.format(printColor("==> DATA RECEIVED  %s ", 'yellow'), printColor(data, 'green')));
			end;
		if(size == read_len) then
			port:flush();
			return tonumber(ok), data;
		end
	end
	if(verbose > 0) then print(string.format("TRANSMISSION FAILED ( %d/%d bytes ) READ FROM PORT [%s] \n" ,read_len or 1, size or 1, portName)) end;
	port:flush();	
	return tonumber(failed), error;
end

-----------------------------------------------------------[[ END OF SERIAL FUNCTIONS ]]--------------------------------------------------

-----------------------------------------------------------[[FIFO BUFFER FUNCTIONS ]]--------------------------------------------------

function fifo(func)
  local queue = dofile(bufferFile)
  local result = func(queue)
  for k, v in ipairs(queue) do
    queue[k] = ("%q,\n"):format(v)
  end
  table.insert(queue, "}\n")
  queue[0] = "return {\n"
  queue = table.concat(queue, "", 0)
  local f = assert(io.open(bufferFile, "w"))
  f:write(queue)
  f:close()
  return result
end

function libcannabox2.newMsg(some_data)
  fifo(
    function(queue)
      table.insert(queue, some_data)
    end
  )
end

function libcannabox2.nextMsg()
  -- returns nil if queue is empty
  return fifo(
    function(queue)
      return table.remove(queue, 1)
    end
  )
end

-----------------------------------------------------------[[ UCI CONFIGUATION FUNCTIONS ]]-----------------------------------------------

--## RETURN A OPTION/VALUE TABLE FOR SECTION OF THE CURRENT CONFIG FILE ##--
function libcannabox2.getConfig(self, conf, sec)
local uci = uci.cursor();
local config = {};

	uci:foreach(conf,sec, function(s)
		for k,v in pairs(s) do 
			config[k] = v;
			print(k,v)	
		end;
	end);
	return config;
end

return libcannabox2;