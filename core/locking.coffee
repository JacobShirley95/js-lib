module.exports = class Locking
	lock: false
	buffer: []

	constructor: () ->

	queue: (func) ->
		if (@lock)
			@buffer.push(func)
		else
			@lock = true
			if (@buffer.length > 0)
				func = @buffer[0]
				@buffer.splice(0, 1)

				func()
			else
				func()

	next: ->
		@lock = false

		if (@buffer.length > 0)
			@queue()
