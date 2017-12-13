# Description:
#   Listen for and save links to an external database
#
# Dependencies:
#
# Configuration:
#
# Commands:
#
# URLs:
#
# Author:
#   Gordon Pedersen

module.exports = (robot) ->
  robot.hear /^.*$/i, (msg) ->
    if msg.message.user.room is 'gordontest'
      for key,value of msg.message.user
        msg.send "#{key}: #{value}"