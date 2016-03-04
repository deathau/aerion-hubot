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
#   swearjar - shows the swears
#
# Author:
#   death_au

profanity = require './data/profanity.json'
regex = new RegExp '\\b(' + profanity.join('|') + ')\\b', 'i'

module.exports = (robot) ->
  robot.brain.on 'loaded', =>
    robot.brain.data.swearbot ||= {}
  
  robot.hear regex, (msg) ->
    theSwear = msg.match[0]
    userName = msg.message.user.name
    msg.send "Swear Jar! (swear)"
    swearUser = robot.brain.data.swearbot[userName] ? { User: userName, Swears: [ ] }
    swearUser.Swears.push { Swear: theSwear, Date: new Date }
    robot.brain.data.swearbot[userName] = swearUser
    
  robot.respond /swearjar/i, (msg) ->
    for userName,swearUser of robot.brain.data.swearbot
      if swearUser.Swears.length > 0
        msg.send userName + ": " + swearUser.Swears.length

  robot.respond /swears for (.*)/i, (res) ->
    userName = res.match[1]
    swearUser = robot.brain.data.swearbot[userName] ? null
    if swearUser == null
      res.send(userName + " hasn't sworn")
    else
      res.send("Swears for " + userName + ":")
      for swear in swearUser.Swears
        res.send(swear.Swear + " (" + swear.Date + ")")
