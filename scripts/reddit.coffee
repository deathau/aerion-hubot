# Description:
#   Get random posts from a particular subreddit
#
# Dependencies:
#   none
#
# Configuration:
#  None
#
# Commands:
#   hubot /r/[subreddit] - get a random post from the top 100 on [subreddit] from the past day
#   hubot /r/[subreddit] fresh - get a random post from the top 100 on [subreddit] from all time
#
# Author:
#   death_au

baseError = 'Sorry, I couldn\'t get any posts.'
reasonError = 'Unexpected status from reddit:'

module.exports = (robot) ->
  robot.respond /\/?r\/([^\s/]+)( fresh)?/i, (msg) ->
    timeLimit = 'hour'
    message = ''
    if msg.match[2] == ' fresh' 
      timeLimit = 'day'
      message = '' 
    else
      timeLimit = 'all'
      message = ''
    numLimit = 100
    url = "https://www.reddit.com/r/#{msg.match[1]}/top.json?sort=top&t=#{timeLimit}&limit=#{numLimit}"
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
        posts = []
        i = 0
        while i < mainObj.length
          thepost = '';
          thepost += mainObj[i].data.title
          if mainObj[i].data.preview
            thepost += '\n' + mainObj[i].data.preview.images[0].source.url
          thepost += "\nhttps://www.reddit.com" + mainObj[i].data.permalink
          posts.push thepost
          i++
        msg.send message + msg.random posts
      else # error
        msg.reply "#{baseError} #{reasonError} #{res.statusCode} when requesting the post (#{url})"