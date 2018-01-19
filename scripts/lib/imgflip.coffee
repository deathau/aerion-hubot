# Description:
#   Get a meme from http://imgflip.com/
#   API Docs at:
#   https://api.imgflip.com/
#
# This is a library file which can be used to interact with the imgflip api in third-party hubot modules.
# See the meme-hear.coffee script for an example of how to build your own custom memes with this API.

inspect = require('util').inspect

module.exports = (msg, template_id, text0, text1) ->
  username = process.env.IMGFLIP_API_USERNAME
  password = process.env.IMGFLIP_API_PASSWORD

  if (username or password) and not (username and password)
    msg.reply 'To use your own Imgflip account, you need to specify username and password!'
    return

  if not username
    username = 'imgflip_hubot'
    password = 'imgflip_hubot'

  msg.http('https://api.imgflip.com/caption_image')
  .query
      template_id: template_id,
      username: username,
      password: password,
      text0: text0,
      text1: text1
  .post() (error, res, body) ->
    if error
      msg.reply "I got an error when talking to imgflip:", inspect(error)
      return

    result = JSON.parse(body)
    success = result.success
    errorMessage = result.error_message

    if not success
      msg.reply "Imgflip API request failed: #{errorMessage}"
      return

    msg.send result.data.url