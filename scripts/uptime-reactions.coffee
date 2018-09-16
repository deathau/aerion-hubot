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
  web = new WebClient robot.adapter.options.token

  robot.hear /Monitor is DOWN(.*)$/i, (msg) ->
    web.reactions.add
      name: 'serverdown',
      channel: msg.message.item.channel,
      timestamp: msg.message.item.ts

  robot.hear /Monitor is UP(.*)$/i, (msg) ->
    web.reactions.add
      name: 'serverdown',
      channel: msg.message.item.channel,
      timestamp: msg.message.item.ts
