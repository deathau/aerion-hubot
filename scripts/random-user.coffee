# Description:
#   Generate random user data from randomuser.me
#
# Dependencies:
#   None
#
# Commands:
#   hubot random user - Get random user data from randomuser.me
#
# Author:
#   tombell

mailinatorDomains = [
  "mailinator.com",
  "mailismagic.com",
  "monumentmail.com",
  "mailtothis.com",
  "zippymail.info"
]

mailinatorEmail = (msg, email) ->
  email.replace /example\.com/, ""
  domain = msg.random mailinatorDomains
  email + domain + " (http://mailinator.com/inbox.jsp?to=#{email})"

String::capitalize = ->
  "#{@charAt(0).toUpperCase()}#{@slice(1)}"

module.exports = (robot) ->

  robot.respond /(random|generate) user/i, (msg) ->
    msg.http('http://api.randomuser.me/')
      .get() (err, res, body) ->
        if err?
          msg.reply "Error occured generating a random user: #{err}"
        else
          try
            data = JSON.parse(body).results[0].user
            msg.send "#{data.name.first.capitalize()} #{data.name.last.capitalize()}\n" +
              "Gender: #{data.gender}\n" +
              "Email: #{mailinatorEmail(msg, data.email)}\n" +
              "Picture: #{data.picture}"

          catch err
            msg.reply "Error occured parsing response body: #{err}"
