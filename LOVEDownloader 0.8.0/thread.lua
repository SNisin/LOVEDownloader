	local thisThread = love.thread.getThread()
	
	downloadURL = thisThread:demand("downloadURL")
	filename = thisThread:demand("filename")
	DOWNLOADER_PATH = thisThread:demand("DOWNLOADER_PATH")
	require("love.filesystem")
	local http = require(DOWNLOADER_PATH..".http")
	local ltn12 = require("ltn12")	

	
	
	
	local count = 0
	local size = 0
	local err = nil
	local stopped = false
	local content = {}
	
	
	function customPump(source,sink)
	
		if thisThread:get("stop") then
			stopped = true
			return nil
		end
		
		
		count = count + 1
		
		
		local per
		local downloaded
		if size > 0 then
			per = math.min((2048*count)/size, 1)
			downloaded = math.min(count*2048, size)
		else
			per = 0
			downloaded = count*2048
		end
		thisThread:set("per", per)
		thisThread:set("count", downloaded)
		thisThread:set("size", size)
		thisThread:set("update", true)
		
		return ltn12.pump.step(source,sink)
	end
	
	function hCallback(header)
		size = tonumber(header['content-length'] or 0)
		
		thisThread:set("per", 0)
		thisThread:set("count", 0)
		thisThread:set("size", size)
		thisThread:set("update", true)
	end
	
	function downloadToFile(dllink, name)
	   local nfile = love.filesystem.newFile(name)
	   nfile:open('w')
	   local lsink = ltn12.sink.file(nfile)
	   local f, e, h = http.request{
		  url = dllink,
		  sink = lsink,
		  step = customPump,
		  headerCallback = hCallback
	   }
	   nfile:close()
	   return f, e, h
	end
	
	function downloadToString(dllink)
		local lsink = ltn12.sink.table(content)
		local f, e, h = http.request{
			url = dllink,
			sink = lsink,
			step = customPump,
			headerCallback = hCallback
		}
		return f, e, h
	end
	

	local f, e, h
	
	if filename then
		f, e, h = downloadToFile(downloadURL, filename);
	else
		f, e, h = downloadToString(downloadURL);
		thisThread:set("content", table.concat(content))
	end
	
	
	if stopped then
		thisThread:set("stopped", true)
	elseif e == 200 then
		if size == 0 then
			local downloaded
			if filename then
				local file = love.filesystem.newFile(filename)
				file:open("c")
				downloaded = file:getSize()
			else
				downloaded = (count-2)*2048 + content[#content]:len()
			end
			thisThread:set("per", 1)
			thisThread:set("count", downloaded)
			thisThread:set("size", size)
			thisThread:set("update", true)
		end
		thisThread:set("success", true)
	elseif (f == nil and e) or e ~= 200 then
		thisThread:set("cerror", e)
	else
		thisThread:set("cerror", "unknown")
	end

