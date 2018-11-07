# Description:
#   Reacts to uptime robot messages
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   Monitor is DOWN - reacts with :serverdown:
#   Monitor is UP - reacts with :serverup:
#
# Author:
#   death-au
{WebClient} = require "@slack/client"

module.exports = (robot) ->
    if robot.adapter.options && robot.adapter.options.token
        web = new WebClient robot.adapter.options.token

        robot.hear /Monitor is DOWN/i, (msg) ->
            web.reactions.add
                name: 'serverdown',
                channel: "#{msg.message.rawMessage.channel}",
                timestamp: "#{msg.message.rawMessage.ts}"

        robot.hear /Monitor is UP/i, (msg) ->
            web.reactions.add
                name: 'serverup',
                channel: "#{msg.message.rawMessage.channel}",
                timestamp: "#{msg.message.rawMessage.ts}"
