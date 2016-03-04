# Description:
#   get user's information
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot debug userinfo - say all the data in the user object
#   hubot debug messageinfo - say all the data in the message object
#
# Author:
#   Gordon Pedersen

module.exports = (robot) ->
  robot.respond /debug userinfo/i, (msg) ->
    for key,value of msg.message.user
      msg.send(key + " : " + value)
	  
  robot.respond /debug messageinfo/i, (msg) ->
    for key,value of msg.message
      msg.send(key + " : " + value)