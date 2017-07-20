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
#   who am i - answers the question
#
# Author:
#   gordon

module.exports = (robot) ->
  robot.hear /^who am i\??$/i, (msg) ->
    for key,value of msg.message.user
        msg.send "#{key}: #{value}"