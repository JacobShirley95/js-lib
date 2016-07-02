module.exports.Logger = null

module.exports.LoggerChain = class LoggerChain
	loggers: []

	constructor: ->

	attachLogger: (logger) ->
		@loggers.push(logger)

	log: (s, severity) ->
		console.log("logger chain "+@loggers.length)
		for logger in @loggers
			logger.log(s, severity)

module.exports.BasicLogger = class BasicLogger extends LoggerChain
	constructor: ->

	log: (status, severity) ->
		super(status, severity)
		console.log("LOG: "+severity+": "+status)