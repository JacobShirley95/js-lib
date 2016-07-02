TabUtils = require("./tab-utils.coffee")

module.exports.Tab = class Tab
	url: ""
	imageURI: ""

	constructor: (@id) ->
		if (@id != -1)
			@getURL()

	loadURL: (url, callback, timeout) ->
		@url = url
		@refresh(callback, timeout)

	select: (callback) ->
		TabUtils.selectTab(@id, callback)

	close: (callback) ->
		TabUtils.closeTab(@id, callback)

	getNewImage: (options, callback) ->
		TabUtils.captureTab(@id, options, (tabId, imageURI) =>
			@imageURI = imageURI

			callback(tabId, imageURI)
		)

	getRaw: (callback) ->
		TabUtils.getTab(@id, callback)

	getURL: (callback) ->
		@getRaw((tab) =>
			@url = tab.url

			callback(tab.url)
		)

	refresh: (callback, timeout) ->
		if (@url == "")
			throw new Error("URL is blank. Tab not loaded.")

		TabUtils.loadURL(@id, @url, (tabId) =>
			if (@id == -1)
				@id = tabId

			if (callback)
				callback(@)
		, timeout)

class ControllerTabCollection
	_tabs: []

	constructor: ->

	addTab: (tab) ->

	getTab: (options) ->