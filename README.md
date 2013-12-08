# LOVEDownloader #

A downloading library for Love2d


## How to use ##


First require the library `LOVEDownloader = require('LOVEDownloader')`. 

`fileDown = LOVEDownloader.download( downloadURL, filename, callbacks )` returns you a FileDownload instance. Now you can start the download using `fileDown:start()`. If you don't give a filename, it will be saved in a string, that can be accessed with `fileDown.content` when finished. Run `fileDown:update()` to update.

### Example ###

    LOVEDownloader = require('LOVEDownloader')
	
	function love.load()
		file = LOVEDownloader.download(http://www.randomnumber.org/randdata/1MB_200409232104.dat", "file.dat", {
			update = function(per, down, size)
				print(per, down, size)
			end
		})
		file:start() -- Start download
	end
	function love.update()
		file:update()
	end
	function love.draw()
		love.graphics.print(math.floor(file.progress*100) .. "%", 10, 10)
		if file.success then
			print("success")
		end
	end

## Functions ##
### LOVEDownloader.download( downloadURL [, filename] [, callbacks] ) ###

Returns a [FileDown](#FileDown) object

- Arguments
	- downloadURL: The URL to the File to download
	- filename: The filename to save as. If not set it will be saved in a string, that can be accessed with `FileDown.content` when finished.
	- callbacks: A table with callback functions
- Returns
	- A [FileDown](#FileDown) object


## Callbacks ##

Can be used in the the table of the last argument in `LOVEDownloader.download`

Example

	file = LOVEDownloader.download( "http://example.com/file.dat" , file.dat, {
		update = function(per, down, size){
			print(per, down, size)	
		}
	})

### update ###

Called when received update from download-thread.

- Arguments
	- per: the progress of the download.
	- down: the downloaded size in Bytes.
	- size: the size of the file.

### content ###
	
Called when got the content, if `filename` not set.

- Arguments
	- content: the content of the downloaded file.

### success ###

Called when download successed.

### error ###

Callen when an error occurred.

- Arguments
 	- desc: The description of the error.

### stopped ###

Called when download stopped with `FileDown:stop()`

### finished ###

Called when finished successfully, stopped or an error occurred.

# <a name="FileDown">FileDown</a> #

## Functions ##

### FileDown:start() ###

Starts the Download.

### FileDown:stop() ###

Stops the Download.

### FileDown:update() ###

Updates all variables.

## Variables ##

### FileDown.progress ###

The progress of the download. A number between 0 and 1.

### FileDown.success ###

A boolean value. `true`, if finished successfully.

### FileDown.error ###

Description of the error that occurred. `nil` if no error occurred. 

### FileDown.stopped ###

A boolean value. `true`, when stopped. Use `FileDown:stop()` to stop.

### FileDown.finished ###

A boolean value. `true`, if finished successfully or stopped or an error occurred.

### FileDown.downloaded ###

The number of Bytes already downloaded.

### FileDown.size ###

The size in Bytes of the File to download.

### FileDown.speed ###

The speed in Bytes per second.

