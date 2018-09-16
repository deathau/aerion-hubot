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
            if key == 'slack'
                for slackKey,slackValue of value
                    msg.send "slack.#{key}: #{value}"
            else
                msg.send "#{key}: #{value}"

    robot.hear /^what am i\??$/i, (msg) ->
        for key,value of msg.message
            if key == 'slack'
                for slackKey,slackValue of value
                    if !slackValue?()
                        msg.send "slack.#{key}: #{value}"
            else
                if !value?()
                    msg.send "#{key}: #{value}"