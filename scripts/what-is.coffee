# Description:
#   Look up something in the Google Knowledge Graph
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot what is <something>? - checks the Google Knowledge Graph for <something>
#
# Author:
#   Gordon Pedersen

# replace the following with your own api key
apiKey = "AIzaSyBY5Ain5GfYTR9uniNm6b-YdA7MKGn6REc"
# replace the following with your custom search cx code (for auto-correct purposes)
cx = "002607098205503633319%3Ahqwuzd_5v7m"


# these are the varibles used internally
matchRegex = /(who|what) (.* )*is ([a-z\d\-_\s]+)\??$/i
lmgtfy = false

module.exports = (robot) ->
  robot.hear matchRegex, (msg) ->
    lmgtfy = false
    doStuff msg

  robot.respond matchRegex, (msg) ->
    lmgtfy = true
  #  doStuff msg

doStuff = (msg) ->
    query = msg.match[3].trim()

    if cx?
      checkSpelling(msg, query)
    else
      runQuery(msg, query)


checkSpelling = (msg, query) ->
  msg.http("https://www.googleapis.com/customsearch/v1?key=#{apiKey}&cx=#{cx}&q=#{query}")
  .get() (err, res, body) ->
    try
      data = JSON.parse body
      correctedQuery = data.spelling?.correctedQuery
      if correctedQuery?
        msg.send "Did you mean #{correctedQuery}?"
        runQuery(msg, correctedQuery)
      else
        runQuery(msg, query)
    catch ex
      msg.send "Erm, something went EXTREMELY wrong - #{ex}"

runQuery = (msg, query) ->
  msg.http("https://kgsearch.googleapis.com/v1/entities:search?key=#{apiKey}&limit=1&query=#{query}")
  .get() (err, res, body) ->
    try
      data = JSON.parse body
      if data.itemListElement? && data.itemListElement.length > 0
        result = data.itemListElement[0].result
        description = result.detailedDescription
        if result.image?
          msg.send "#{result.image.contentUrl}&.jpg"
        if description?
          msg.send "/quote #{description.articleBody}"
          msg.send "#{description.url}"
      else if lmgtfy
        msg.send "How the hell am I supposed to know?"
        msg.send "http://lmgtfy.com/?q=#{query}"
    
    catch ex
      msg.send "Erm, something went EXTREMELY wrong - #{ex}"