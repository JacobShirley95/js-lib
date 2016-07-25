module.exports.ChromeMessaging = class ChromeMessaging
	@_listeners: []
	@_started: false

	@send: (messageId, data, tabId) ->
		if (typeof tabId != 'undefined')
			chrome.tabs.sendMessage(tabId, {messageId:messageId, data: data})
		else
			chrome.runtime.sendMessage({messageId:messageId, data: data})

	@listen: (messageId, callback) ->
		ChromeMessaging._listeners.push({id: messageId, callback: callback})

	@start: ->
		if (!ChromeMessaging._started)
			ChromeMessaging._started = true
			chrome.runtime.onMessage.addListener((data, sender, sendResponse) ->
				for listener in ChromeMessaging._listeners
					if (listener.id == data.messageId)
						listener.callback(data.data)
			)

module.exports.TabMessaging = class TabMessaging
	_listeners: []
	_connected: false

	constructor: (@id, @type) ->
		ChromeMessaging.start()
		ChromeMessaging.listen("TAB-"+@id, (data) =>
			if (!@isConnected())
				if (data.extConnected)
					@_connected = true
			else
				for listener in @_listeners
					listener.callback(data)
		)

		if (@type == "extension")
			@send({extConnected: true})

	send: (data) ->
		###if (!@isConnected())
			throw new Error("TabMessaging: Not connected to tab "+@id+".")
		###
		if (@type == "background")
			ChromeMessaging.send("TAB-"+@id, data, @id)
		else
			ChromeMessaging.send("TAB-"+@id, data)

	listen: (callback) ->
		@_listeners.push({callback: callback})

	isConnected: ->
		return @_connected