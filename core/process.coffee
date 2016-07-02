EventEmitter = require("events")

module.exports.Process = class Process extends EventEmitter
	paused: false

	constructor: (@name) ->
		@paused = false;

	cleanup: ->

	tick: ->

	isPaused: () ->
		return @paused;

	pause: (paused) ->
		@paused = paused;
		@emit("pause", @paused)

	start: () ->
		@emit("start")
		@tick()

module.exports.ProcessLoop = class ProcessLoop extends Process
	constructor: (@repeater, @curLoop, @maxLoopCount, @interval, @name) ->
		super(@name)

	tick: () =>
		if (!@isFinished())
			if (!@paused)
				@emit("tick", @curLoop)
				@curLoop++
				@repeater(() =>
					setTimeout(@tick, @interval)
				)
			else
				@on("pause", (paused) =>
					if (!paused)
						@removeListener("paused", arguments.callee);
						@tick()
				)
		else
			@emit("finish")

	isFinished: () ->
		return @curLoop >= @maxLoopCount

	start: () ->
		@emit("start")
		@tick()

module.exports.ProcessRunner = class ProcessRunner extends Process
	constructor: (@processes) ->
		for process in processes
			process.on("finish", () ->
				#todo: next process
				process.removeListener("finish", arguments.callee)
			)
