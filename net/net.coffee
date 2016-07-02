EventEmitter = require("events")

module.exports = class NetCom extends EventEmitter
	connected: false

	constructor: (@address, @options) ->
		if (!@test)
			addr = @address+"?type="+@options.type
			if (@options.bot)
				addr += "&bot-name="+@options.bot

			if (@options.debug)
				console.log(addr)

			@_socket = new WebSocket(addr)

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

	sendToSimba: (command, params, callback) ->
		if (callback)
			@_socket.addEventListener("message", (ev) =>
				result = JSON.parse(ev.data.trim())
				
				if (result.target == "controller")
					callback(result.statusCode)

				@_socket.removeEventListener("message", arguments.callee)
			)

		@_socket.send(JSON.stringify({target: "simba", commandOp: command, commandArgs:params}))

	sendToApp: (data) ->
		data.target = "app"
		data.bot = @options.bot
		@_socket.send(JSON.stringify(data))