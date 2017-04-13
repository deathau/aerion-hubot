# Description:
#   None
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   haiku (message) - attempts to turn (message) into a haiku
#
# Author:
#   death_au

morae = require 'morae'

module.exports = (robot) ->
    
  morae (m) ->
    robot.respond /haiku (.*)/i, (res) ->
      message = res.match[1]
      syllables = m.count(message)
      res.send("There are #{syllables} syllables")
      haikus = m.extract(message)
      if haikus.length == 0
        res.send("Sorry, I can't really make a haiku from that. Try something with 5-7-5 syllables.")
      else
        res.send("We can make #{haikus.length} haikus")
      for haiku in haikus
        res.send("--- A haiku: ---")
        res.send(haiku['1'])
        res.send(haiku['2'])
        res.send(haiku['3'])

      robot.hear /(.*)/i, (res) ->
        message = res.match[1]
        syllables = m.count(message)
        if syllables == 17
          haikus = m.extract(message)
          if haikus.length > 0
            for haiku in haikus
              res.send("--- A haiku: ---")
              res.send(haiku['1'])
              res.send(haiku['2'])
              res.send(haiku['3'])