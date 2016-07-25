module.exports.RandomEvent = class RandomEvent
	constructor: (@probability, @run) ->

module.exports.RandomUtils = class RandomUtils
	constructor: ->

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