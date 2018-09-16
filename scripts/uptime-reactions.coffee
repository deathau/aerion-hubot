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

  robot.respond /Monitor is DOWN(.*)$/i, (msg) ->
    robot.logger.info 'Heard that the monitor is down, attempting to react'
    web.reactions.add
      name: 'serverdown',
      channel: msg.message.item.channel,
      timestamp: msg.message.item.ts

  robot.respond /Monitor is UP(.*)$/i, (msg) ->

    web.reactions.add
      name: 'serverdown',
      channel: msg.message.item.channel,
      timestamp: msg.message.item.ts
