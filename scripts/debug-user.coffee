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
  robot.respond /debug userinfo/, (msg) ->
    for key in msg.message.user
      msg.send(key + " : " + msg.message.user[key])
	  
  robot.respond /debug messageinfo/, (msg) ->
    for key in msg.message
      msg.send(key + " : " + msg.message[key])