EventEmitter = require("events")

module.exports = class NetCom extends EventEmitter
	connected: false

	constructor: (@address, @options) ->
		@_socket = new WebSocket(@address)

		@_socket.onopen = (event) =>
			@connected = true
			@emit("connected", event)

		@_socket.onclose = (event) =>
			@connected = false
			@emit("closed", event)

		@_socket.addEventListener("message", (ev) =>
			if (@options.debug)
				console.log("NetCom: "+ev.data)

			result = JSON.parse(ev.data.trim())
			if (result.target == @options.type)
				@emit("message", result)
		)

	send: (data, callback) ->
		@_socket.send(JSON.stringify(data))