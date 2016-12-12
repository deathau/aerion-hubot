# Description:
#   The dankest memes
#
# Dependencies:
#   dankmemes
#
# Configuration:
#  None
#
# Commands:
#   hubot dank - get the dankest of memes
#
# Author:
#   death_au

baseError = 'Sorry, I couldn\'t get any memes.'
reasonError = 'Unexpected status from reddit:'

module.exports = (robot) ->
  robot.respond /dank/i, (msg) ->
    timeLimit = 'day'
    numLimit = 1
    url = 'https://www.reddit.com/r/dankmemes/top.json?sort=top&t=' + timeLimit + '&limit=' + numLimit    
    msg.robot.http(url)
    .header('accept', 'application/json')
    .header('Content-type', 'application/json')
    .get() (err, res, body) ->
      return msg.reply "#{baseError} #{err}" if err
      if res.statusCode == 301
        msg.http(res.headers.location).get() processResult
        return
      else if res.statusCode == 200 # success
        data = JSON.parse(body)
        mainObj = data.data.children
        urls = {}
        i = 0
        while i < mainObj.length
          msg.send mainObj[i].data.preview.images[0].source.url
          i++
      else # error
        msg.reply "#{baseError} #{reasonError} #{res.statusCode} when requesting the image"