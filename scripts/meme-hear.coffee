# Description:
#   Get a meme from http://memecaptain.com/
#   API Docs at:
#   github.com/mmb/meme_captain_web/blob/master/doc/api/create_meme_image.md
#
# Dependencies:
#   None
#
# Commands:
#   Y U NO <text> - Meme: Y U NO GUY w/ bottom caption
#   I don't always <something> but when i do <text> - Meme: The Most Interesting man in the World
#   <text> (SUCCESS|NAILED IT) - Meme: Success kid w/ top caption
#   <text> ALL the <things> - Meme: ALL THE THINGS
#   <text> TOO DAMN <high> - Meme: THE RENT IS TOO DAMN HIGH guy
#   Yo dawg <text> so <text> - Meme: Yo Dawg
#   All your <text> are belong to <text> - Meme: All your <text> are belong to <text>
#   If <text>, <question> <text>? - Meme: Philosoraptor
#   <text>, BITCH PLEASE <text> - Meme: Yao Ming
#   <text>, COURAGE <text> - Meme: Courage Wolf
#   ONE DOES NOT SIMPLY <text> - Meme: Boromir
#   IF YOU <text> GONNA HAVE A BAD TIME - Meme: Ski Instructor
#   IF YOU <text> TROLLFACE <text> - Meme: Troll Face
#   Aliens guy <text> - Meme: Aliens guy
#   Brace yourself <text> - Meme: Ned Stark braces for <text>
#   Iron Price <text> - Meme: To get <text>? Pay the iron price!
#   Not sure if <something> or <something else> - Meme: Futurama Fry
#   <text>, AND IT'S GONE - Meme: Bank Teller
#   WHAT IF I TOLD YOU <text> - Meme: Morpheus "What if I told you"
#   WTF <text> - Meme: Picard WTF
#   IF <text> THAT'D BE GREAT - Meme: Generates Lumberg
#   MUCH <text> (SO|VERY) <text> - Meme: Generates Doge
#   <text>, <text> EVERYWHERE - Meme: Generates Buzz Lightyear
#   khanify <text> - Meme: Has Shatner yell your phrase
#   pun | bad joke eel <text>? <text> - Meme: Bad joke eel
#   pun | bad joke eel <text> / <text> - Meme: Bad joke eel
#   why not both? - Meme: Mexican girl
#   why not <text> - Meme: Why not Zoidberg?
#   is only <text> - Meme: Why you heff to be med?
# Author:
#   bobanj
#   cycomachead, Michael Ball <cycomachead@gmail.com>
#   peelman, Nick Peelman <nick@peelman.us>
#   ericjsilva, Eric Silva
#   lukewaite, Luke Waite

sanitizeHtml = require 'sanitize-html'

memeGenerator = require "./lib/imgflip.coffee"
idToUse = 'imgflip_id'

module.exports = (robot) ->
  
  # middleware to strip html. This will stop success kid showing up on something like
  # "<span class='aui-lozenge-success'>"
  robot.receiveMiddleware (context, next, done) ->
    if context.response.message.text
      clean = sanitizeHtml(context.response.message.text, {allowedTags:[]})
      context.response.message.text = clean
    next(done)

  unless robot.brain.data.memes?
      robot.brain.data.memes = [
        {
          id: 'meme.not-simply',
          regex: /(one does not simply) (.*)/i,
          imgflip_id: 61579,
          memecaptain_id: 'da2i4A'
        },
        {
          id: 'meme.interesting-man',
          regex: /(i don'?t always .*) (but when i do,? .*)/i,
          imgflip_id: 61532,
          memecaptain_id: 'V8QnRQ'
        },
        {
          id: 'meme.aliens',
          regex: /aliens ()(.*)/i,
          imgflip_id: 101470,
          memecaptain_id: 'sO-Hng'
        },
        {
          id: 'meme.grumpy-cat',
          regex: /grumpy cat ()(.*)/i,
          imgflip_id: 405658
        },
        {
          id: 'meme.everywhere',
          regex: /(.*),? (\1 everywhere)/i,
          imgflip_id: 347390,
          memecaptain_id: 'yDcY5w'
        },
        {
          id: 'meme.not-sure-fry',
          regex: /(not sure if .*) (or .*)/i,
          imgflip_id: 61520,
          memecaptain_id: 'CsNF8w'
        },
        {
          id: 'meme.y-u-no',
          regex: /(y u no) (.+)/i,
          imgflip_id: 61527,
          memecaptain_id: 'NryNmg'
        },
        {
          id: 'meme.brace-yourself',
          regex: /(brace yoursel[^\s]+) (.*)/i,
          imgflip_id: 61546,
          memecaptain_id: '_I74XA'
        },
        {
          id: 'meme.all-the-things', 
          regex: /(.*) (all the .*)/i,
          imgflip_id: 61533,
          memecaptain_id: 'Dv99KQ'
          # add case for sad all the things?
        },
        {
          id: 'meme.be-great',
          regex: /(.*) (that would be great|that'?d be great)/i,
          imgflip_id: 563423,
          memecaptain_id: 'q1cQXg'
        },
        {
          id: 'meme.too-damn-high',
          regex: /(.*) (\w+\stoo damn .*)/i,
          imgflip_id: 61580,
          memecaptain_id: 'RCkv6Q'
        },
        {
          id: 'meme.yo-dawg',
          regex: /(yo dawg .*) (so .*)/i,
          imgflip_id: 101716,
          memecaptain_id: 'Yqk_kg'
        },
        {
          id: 'meme.bad-time',
          regex: /(.*) (.* gonna have a bad time)/i,
          imgflip_id: 100951,
          memecaptain_id: 'lfSVJw'
        },
        {
          id: 'meme.only-one-around',
          regex: /(am i the only one around here) (.*)/i,
          imgflip_id: 259680
        },
        {
          id: 'meme.told-you',
          regex: /(what if i told you) (.*)/i,
          imgflip_id: 100947,
          memecaptain_id: 'fWle1w'
        },
        {
          id: 'meme.aint-nobody',
          regex: /(.*) (ain'?t nobody got time for? that)/i,
          imgflip_id: 442575
        },
        {
          id: 'meme.guarantee-it',
          regex: /(.*) (i guarantee it)/i,
          imgflip_id: 10672255
        },
        {
          id: 'meme.its-gone',
          regex: /(.*) (a+n+d+ it'?s gone)/i,
          imgflip_id: 766986,
          memecaptain_id: 'uIZe3Q'
        },
        {
          id: 'meme.loses-minds'
          regex: /(.* bats an eye) (.* loses their minds?)/i,
          imgflip_id: 1790995
        },
        {
          id: 'meme.back-in-my-day',
          regex: /(back in my day) (.*)/i,
          imgflip_id: 718432
        },
        {
          id: 'meme.success-kid',
          regex: /(.*)\b(SUCCESS|NAILED IT.*)/i,
          memecaptain_id: 'AbNPRQ',
          imgflip_id: 61544
        },
        {
          id: 'meme.base-are-belong',
          regex: /(All your .*) (are belong to .*)/i,
          memecaptain_id: '76CAvA',
          imgflip_id: 4503404
        },
        {
          id: 'meme.bitch-please',
          regex: /(.*)\s*BITCH PLEASE\s*(.*)/i,
          memecaptain_id: 'jo9J0Q',
          imgflip_id: 6411349
        },
        {
          id: 'meme.philosoraptor',
          regex: /(IF .*), ((ARE|CAN|DO|DOES|HOW|IS|MAY|MIGHT|SHOULD|THEN|WHAT|WHEN|WHERE|WHICH|WHO|WHY|WILL|WON\'T|WOULD)[ \'N].*)/i,
          memecaptain_id: '-kFVmQ',
          imgflip_id: 61516
          # add question mark on end?
        },
        {
          id: 'meme.wtf',
          regex: /(WTF) (.*)/i,
          memecaptain_id: 'z8IPtw',
          imgflip_id: 245898
        },
        {
          id: 'meme.doge',
          regex: /((?:WOW )?(?:SUCH|MUCH) .*) ((SUCH|MUCH|SO|VERY|MANY) .*)/i,
          memecaptain_id: 'AfO6hw',
          imgflip_id: 8072285
        },
        {
          id: 'meme.why-not',
          regex: /why not (\w+)/i,
          memecaptain_id: 'kzsGfQ',
          imgflip_id: 61573,
          top: '{1}?',
          bottom: 'Why not Zoidberg?'
          #por que no las dos?
        },
        {
          id: 'meme.why-heff-med',
          regex: /IT?'?S (ONLY|JUST)( A)? (.+)/i,
          memecaptain_id: 'iAGOQw',
          imgflip_id: 109522862,
          top: 'IS ONLY {3}',
          bottom: 'WHY YOU HEFF TO BE MED?'
        },
        {
          id: 'meme.whats-the-deal',
          regex: /(what'?s the deal) (.+)/i,
          imgflip_id: 46404522
        }
      ]

  for meme in robot.brain.data.memes
    setupResponder robot, meme

setupResponder = (robot, meme) ->
  if meme[idToUse]
    robot.hear meme.regex, (msg) ->
      top = substitute(meme.top, msg, 1)
      bottom = substitute(meme.bottom, msg, 2)
      memeGenerator msg, meme[idToUse], top, bottom

substitute = (text, msg, matchNo) ->
  if text
    return text.replace /\{([0-9]+)\}/g, (_, index) ->
      msg.match[index]
  else
    return msg.match[matchNo]
    
  