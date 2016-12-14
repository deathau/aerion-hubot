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
#   hubot dank - get a random dank meme from the past hour
#   hubot danker - get a random dank meme from the past day
#   hubot dankest - get a random dank meme from the all time dankest
#
# Author:
#   death_au

baseError = 'Sorry, I couldn\'t get any memes.'
reasonError = 'Unexpected status from reddit:'

module.exports = (robot) ->
  robot.respond /dank(est|er)?/i, (msg) ->
    timeLimit = 'hour'
    message = 'A dank meme from the past hour: '
    if msg.match[1] == 'est' 
      timeLimit = 'all'
      message = 'One of the dankest memes of all time: ' 
    else if msg.match[1] == 'er'
      timeLimit = 'day'
      message = 'One of the danker memes of today: '
    numLimit = 100
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
        urls = []
        i = 0
        while i < mainObj.length
          if mainObj[i].data.preview
            urls.push mainObj[i].data.preview.images[0].source.url
          i++
        msg.send message + msg.random urls
      else # error
        msg.reply "#{baseError} #{reasonError} #{res.statusCode} when requesting the image"