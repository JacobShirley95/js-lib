module.exports = class Locking
	lock: false
	buffer: []

	constructor: ->

	queue: (func) ->
		if (@lock)
			@buffer.push(func)
		else
			@lock = true
			if (@buffer.length > 0)
				if (func)
					@buffer.push(func)
				func = @buffer[0]
				
				@buffer.splice(0, 1)

			func()

	next: ->
		@lock = false
		if (@buffer.length > 0)
			@queue()
