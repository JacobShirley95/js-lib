module.exports.RandomEvent = class RandomEvent
	constructor: (@probability, @run) ->

module.exports.RandomUtils = class RandomUtils
	constructor: ->

	@antiGoogleProtection: (simba, targetTime, ontick, onfinished) ->
		MOUSE_EVENT_RANDOMNESS = 1.0/10
		SCROLL_EVENT_RANDOMNESS = 4.8/10

		SCROLL_EVENT_DOWN_RANDOMNESS = 8.5/10

		ANTI_GOOGLE_EVENTS = [
			new RandomEvent(MOUSE_EVENT_RANDOMNESS, () =>
				#console.log("Doing event: Mouse move random")
				simba.moveToRandom()
			), new RandomEvent(SCROLL_EVENT_RANDOMNESS, () =>
				#console.log("Doing event: Mouse Scroll Random")
				simba.scrollBy(Math.round(10*Math.random()), Math.random() < SCROLL_EVENT_DOWN_RANDOMNESS)
			)]

		return RandomUtils.waitAndPerform(ANTI_GOOGLE_EVENTS, targetTime, ontick, onfinished)

	@waitAndPerform: (events, targetTime, ontick, onfinished) ->
		MIN_EVENT_TIME = 1000

		tick = c = 0
		curTime = tick
		t = targetTime/MIN_EVENT_TIME

		interval = setInterval(() ->
			c++;
			if (c < t)
				curTime = c*MIN_EVENT_TIME
				if (ontick)
					ontick(targetTime-curTime)

				if (curTime-tick >= MIN_EVENT_TIME)
					tick = curTime

					last = 0
					random = Math.random()

					for eventObj in events
						probability = eventObj.probability

						if (random >= last && random <= last+probability)
							eventObj.run()
							break

						last += probability
				
			else
				clearInterval(interval)

				if (onfinished)
					onfinished()
			
		, MIN_EVENT_TIME)