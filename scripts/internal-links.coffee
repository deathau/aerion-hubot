# Description:
#   Listen for and save links to an external database
#
# Dependencies:
#
# Configuration:
#
# Commands:
#
# URLs:
#
# Author:
#   Gordon Pedersen

urlMetadata = require('url-metadata')
puturl = 'https://internal-link-sharing.firebaseio.com/links.json'
errorputurl = 'https://internal-link-sharing.firebaseio.com/errors.json'

module.exports = (robot) ->
  robot.hear /(https?:\/\/(?![^" ]*(?:jpg|png|gif))[^" ]+)/i, (msg) ->
    #if msg.message.user.room is 'gordontest'
      urlMetadata(msg.match[0]).then(
        (metadata) -> # success handler
            postdata = 
                metadata: metadata
                message: msg.match.input
                name: msg.message.user.name
                room: msg.message.user.room
            msg.http(puturl).post(JSON.stringify(postdata)) (err, res, body) ->
                #msg.send err
                #msg.send body
        ,
        (error) -> # failure handler
            postdata = 
                error: error
                message: msg.match.input
                name: msg.message.user.name
                room: msg.message.user.room
            msg.http(errorputurl).post(JSON.stringify(postdata)) (err, res, body) ->
                #msg.send err
                #msg.send body
      )