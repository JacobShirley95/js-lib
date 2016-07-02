$ = require("jQuery")
TabMessaging = require("../chrome/messaging.coffee").TabMessaging
Locking = require("../core/locking.coffee")
CoffeeScript = require("coffee-script")

loadResource = (file, async, callback) ->
	console.log("Being called")
	r = ""
	$.ajax({
		url: chrome.extension.getURL(file)

		success: (result) ->
			r = result
			if (callback)
				callback(result)

		async: async || false
	})

	return r

module.exports = class TabUtils
	@_messagingCode: CoffeeScript.compile(require('fs').readFileSync(__dirname+"/messaging.coffee", 'utf-8'))
	@_captureTabLocking: new Locking()

	constructor: ->

	@captureTab: (tabId, options, onfinished) ->
		rawCapture = (tries, callback) ->
			if (tries == 5)
				console.log("Couldn't fix in 5 tries. Please try manually refreshing...")
				return

			chrome.tabs.captureVisibleTab(null, options, (dataURI) ->
				if (!chrome.extension.lastError)
					TabUtils._captureTabLocking.next()
					if (callback)
				    	callback(tabId, dataURI)
				else 
					console.log("Error in captureVisibleTab. Attempting to fix on try "+(tries+1)+"...")
					setTimeout(() ->
						capture(tries+1)
					, 10000)
			)

		capture = (tries) ->
			rawCapture(tries, onfinished)

		run = () ->
			setTimeout(() ->
				capture(0)
			, 1000)

		TabUtils._captureTabLocking.queue(() ->
			if (tabId == -1) 
				run()
			else
				chrome.tabs.update(tabId, {highlighted:true}, run)
		)

	@setLoadTimeout: (id, onloaded, timeout, onerror) ->
		timer = -1
		called = false

		onUpdated = (tabId, details) ->
						if (details.status == "complete" && tabId == id && !called)
							if (timer != -1)
								clearTimeout(timer)

							onloaded(tabId, details)
							called = true

							if (onloaded)
								chrome.tabs.onUpdated.removeListener(onUpdated)

							if (onerror)
								chrome.webNavigation.onErrorOccurred.removeListener(onError)
							
		onError = (details) ->
					if (details.tabId == id && !called)
						if (timer != -1)
							clearTimeout(timer)

						onerror(details)
						called = true

						if (onloaded)
							chrome.tabs.onUpdated.removeListener(onUpdated)

						if (onerror)
							chrome.webNavigation.onErrorOccurred.removeListener(onError)

		if (onloaded) 
			if (typeof timeout != "undefined") 
				timer = setTimeout(() ->
					if (!called) 
						onloaded(id, {timeout:true})
						called = true

						clearTimeout(timer)
						timer = -1

						chrome.tabs.onUpdated.removeListener(onUpdated)
						chrome.webNavigation.onErrorOccurred.removeListener(onError)
				, timeout)

			chrome.tabs.onUpdated.addListener(onUpdated)
			
		if (onerror) 
			chrome.webNavigation.onErrorOccurred.addListener(onError)

	@loadURL: (id, url, onloaded, timeout, onerror) ->
		if (id == -1)
			chrome.tabs.create({active:true, url: url}, (tab) ->
				id = tab.id
				TabUtils.setLoadTimeout(id, onloaded, timeout, onerror)
			)
		else
			chrome.tabs.update(id, {url: url})
			TabUtils.setLoadTimeout(id, onloaded, timeout, onerror)

	@alertTab: (tabId, msg) ->
		if (tabId > -1)
			chrome.tabs.executeScript(tabId, {code:'alert("'+msg+'");'})

	@executeScript: (tabId, options, callback, timeout) ->
		messaging = options.messaging

		timer = -1
		called = false

		injectCode = (code) ->
			pos = code.indexOf("/* EXT_VARS */")

			if (pos != -1)
				newCode = ""
				if (options.messaging)
					newCode = "var extConnection = new TabMessaging("+tabId+", 'extension');"
					delete options.messaging

				if (options.vars)
					newCode += "var EXT_VARS = "+JSON.stringify(options.vars)+";"
					delete options.vars

				code = TabUtils._messagingCode + code.substring(0, pos) + newCode + code.substring(pos, code.length);

			return code

		runExec = () ->
			chrome.tabs.executeScript(tabId, options, () ->
				if (!called && callback)
					called = true
					callback()

					if (timer != -1)
						clearTimeout(timer)
			)

		if (typeof timeout != "undefined")
			timer = setTimeout(() ->
				if (!called)
					callback()
					called = true

					clearTimeout(timer)
				
			, timeout)

		if (options.messaging || options.vars)
			if (options.code)
				options.code = injectCode(options.code)

				runExec()
			else if (options.file)
				loadResource(options.file, true, (data) ->
					delete options.file
					options.code = injectCode(data)
					runExec()
				)
		else
			runExec()

		if (messaging)
			return new TabMessaging(tabId, 'background')

	@getCurrent: (onfinished) ->
		chrome.tabs.query({active: true, currentWindow: true}, (tabs) ->
	    	onfinished(tabs[0])
		)

	@selectTab: (id, callback) ->
		chrome.tabs.update(id, {highlighted:true}, callback)

	@closeTab: (id, callback) ->
		chrome.tabs.remove(id, callback)

	@getTab: (id, callback) ->
		chrome.tabs.get(id, callback)