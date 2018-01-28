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
#     disasterometer - shows the current disaster level
#     set disaster level &lt;level&gt; - sets the current disaster level
#     disaster - increases the disaster level by one and shows the new level
#     ease up - decreased the disaster level by one and shows the new level
# Author:
#   death_au

disasterLevels = { 
  "Rubbish": "https://s3-ap-southeast-2.amazonaws.com/uploads-au.hipchat.com/159270/1145696/f3uqchzOHweYtTC/0.png",
  "Shambles": "https://s3-ap-southeast-2.amazonaws.com/uploads-au.hipchat.com/159270/1145696/njkg83IhQomEcti/1.png",
  "Shithouse": "https://s3-ap-southeast-2.amazonaws.com/uploads-au.hipchat.com/159270/1145696/w5BjxFrBwbHyT0A/2.png",
  "Disaster": "https://s3-ap-southeast-2.amazonaws.com/uploads-au.hipchat.com/159270/1145696/B5ZZxDyK5E34HtW/3.png",
  "Disgusting": "https://s3-ap-southeast-2.amazonaws.com/uploads-au.hipchat.com/159270/1145696/Tn6l9YSfByLOhQf/4.png",
  "Nightmare": "https://s3-ap-southeast-2.amazonaws.com/uploads-au.hipchat.com/159270/1145696/EyZ2FplEBK6ntaI/5.png"
}

allLevelNames = Object.keys(disasterLevels)
allLevelNamesString = allLevelNames.join('|')
regexString = "set disaster level ([0-" + (allLevelNames.length - 1) + "]|" + allLevelNamesString + ")"
setRegex = new RegExp regexString, 'gi'

module.exports = (robot) ->
  robot.respond setRegex, (msg) ->
    msg.send regexString
    msg.send msg.match