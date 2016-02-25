# Description
#   Your mum is a hubot script. It replies with "your mum"isms.
#   Also works with "your face", "your dad", "your mum's face", "your dad's face" or "your code"
#
# Configuration:
#   HUBOT_YOURFACE_PERCENT (optional)
#		Percent chance that hubot will repond with a "Your face". Default is 40%
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Joe Bott

options = ["mum", "dad", "face", "mum's face", "dad's face", "code"]
optionsString = options.join('|')
yourfaceRegex = new RegExp "how is (.*|my) (" + optionsString + ")\\??$", 'i'
dontmatchRegex = new RegExp "your " + options.join("|your ") + "|how|why|wtf|when|where", 'i'

module.exports = (robot) ->
	percent         = process.env.HUBOT_YOURFACE_PERCENT or 0

	lastYourFace = {}
	robot.hear /^([ \w]* )(is|was) ([ \w]+)[\.!]?$/, (message) ->
		lower = message.match[1].toLowerCase()
		if not lower.match dontmatchRegex
		#if lower.indexOf("your face") < 0 and lower.indexOf("how") < 0 and lower.indexOf("why") < 0 and lower.indexOf("wtf") < 0 and lower.indexOf("when") < 0 and lower.indexOf("where") < 0
			yourFace = message.match[2] + " " + message.match[3]
			lastYourFace[(message.message.user.mention_name + '').toLowerCase()] = yourFace
			if Math.random() <= (percent / 100.0)
				setTimeout (->
					message.send "your " + options[Math.floor(Math.random() * options.length)] + " " + yourFace
					), 2000
		return

	robot.respond yourfaceRegex, (message) ->
		name = message.match[1].replace("'s", '')

		name = message.message.user.mention_name + '' if message.match[1] == 'my'

		if lastYourFace[name.toLowerCase()]
			message.send name + ": Your " + message.match[2] + " " + lastYourFace[name.toLowerCase()]
		else
			message.send "I don't know how " + name + "'s " + message.match[2] + " is. :("
	
		return

