local DOWNLOADER_PATH = DOWNLOADER_PATH or ({...})[1]:gsub("[%.\\/]init$", "")
	--print("DOWNLOADER_PATH: "DOWNLOADER_PATH)

local DownFile = {}

function DownFile:new(downloadURL, filename, callbacks)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	
	--private
	o.thread = love.thread.newThread("download "..downloadURL, DOWNLOADER_PATH.."/thread.lua")
	o.thread:set("downloadURL", downloadURL)
	o.thread:set("filename", filename or false)
	o.thread:set("DOWNLOADER_PATH", DOWNLOADER_PATH)
	o.sctime = 0
	o.scbytes = 0
	
	
	o.callbacks = callbacks or {}
	
	
	--public
	o.downloadURL = downloadURL
	o.filename = filename
	
	o.progress = 0
	o.success = false
	o.error = nil
	o.stopped = false
	o.finished = false
	o.downloaded = 0
	o.size = 0
	o.speed = 0
	
	return o
end
function DownFile:start()
	self.thread:start()
end
function DownFile:update()
	if not self.error then
		self.error = self.thread:get('error')
		if self.error then
			print(self.error)
		end
	end

	
	
	if self.thread:get('update') then
		self.progress = self.thread:get('per') or self.progress
		self.downloaded = self.thread:get('count') or self.downloaded
		self.size = self.thread:get('size') or self.size
		
		if self.callbacks["update"] then self.callbacks["update"](self.progress, self.downloaded, self.size) end
	end
	if self.thread:peek('content') then
		self.content = self.thread:get('content')
		
		if self.callbacks["content"] then self.callbacks["content"](self.content) end
	end
	if self.thread:get('success') then
		self.success = true
		
		if self.callbacks["success"] then self.callbacks["success"]() end
	end
	if self.thread:peek('cerror') then
		self.error = self.thread:get('cerror')
		
		if self.callbacks["error"] then self.callbacks["error"](self.error) end
		
		print("Error: ".. self.error)
	end
	if self.thread:get('stopped') then
		self.stopped = true
		
		if self.callbacks["stopped"] then self.callbacks["stopped"]() end
	end
	
	
	
	if os.time() >= (self.sctime+1) then
		self.speed = self.downloaded - self.scbytes
	
		self.scbytes = self.downloaded
		self.sctime = os.time()
	end
	
	if not self.finished and (self.stopped or self.success or self.error) then
		self.finished = true
		
		if self.callbacks["finished"] then self.callbacks["finished"]() end
	end
end
function DownFile:stop()
	self.thread:set("stop", true)
end
	
local LOVEDownloader = {}

function LOVEDownloader.download(downloadURL, filename, callbacks)
	if type(filename) == "table" then
		callbacks = filename
		filename = nil
	end
	if not(type(downloadURL) == "string" and (type(filename) == "string" or filename == nil)) then
		error("invalid input")
	end
	return DownFile:new(downloadURL, filename, callbacks)
end


return LOVEDownloader