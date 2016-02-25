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
regex = new RegExp profanity.join('|'), 'gi'

module.exports = (robot) ->
  robot.hear regex, (msg) ->
    theSwear = msg.match[0]
    userName = msg.message.user.name
    msg.send "Swear Jar! \n http://49.media.tumblr.com/6f8a8468b45c655f15294368b0909b07/tumblr_muyadhp4KI1sc9c73o2_250.gif"
    swearBrain = robot.brain.swearbot ? [ ]
    swearUser = swearBrain[userName] ? { User: userName, Swears: [ ] }
    swearUser.Swears.push { Swear: theSwear, Date: new Date }
    swearBrain[userName] = swearUser
    robot.brain.swearbot = swearBrain
    
  robot.respond /swearjar/i, (msg) ->
    swearBrain = robot.brain.swearbot ? [ ]
    for userName,swearUser of swearBrain
      if swearUser.Swears.length > 0
        msg.send userName + ": " + swearUser.Swears.length

  robot.respond /swears for (.*)/i, (res) ->
    userName = res.match[1]
    swearBrain = robot.brain.swearbot ? []
    swearUser = swearBrain[userName] ? null
    if swearUser == null
      res.send(userName + " hasn't sworn")
    else
      res.send("Swears for " + userName + ":")
      for swear in swearUser.Swears
        res.send(swear)
        res.send(swear.Swear + " (" + swear.Date + ")")
