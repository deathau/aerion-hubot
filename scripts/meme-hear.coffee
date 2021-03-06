# Description:
#   Get a meme from http://memecaptain.com/
#   API Docs at:
#   github.com/mmb/meme_captain_web/blob/master/doc/api/create_meme_image.md
#
# Dependencies:
#   None
#
# Commands:
#   [Meme] Y U NO <text> - Meme: Y U NO GUY w/ bottom caption
#   [Meme] I don't always <something> but when i do <text> - Meme: The Most Interesting man in the World
#   [Meme] <text> (SUCCESS|NAILED IT) - Meme: Success kid w/ top caption
#   [Meme] <text> ALL the <things> - Meme: ALL THE THINGS
#   [Meme] <text> TOO DAMN <high> - Meme: THE RENT IS TOO DAMN HIGH guy
#   [Meme] Yo dawg <text> so <text> - Meme: Yo Dawg
#   [Meme] All your <text> are belong to <text> - Meme: All your <text> are belong to <text>
#   [Meme] If <text>, <question> <text>? - Meme: Philosoraptor
#   [Meme] <text>, BITCH PLEASE <text> - Meme: Yao Ming
#   [Meme] <text>, COURAGE <text> - Meme: Courage Wolf
#   [Meme] ONE DOES NOT SIMPLY <text> - Meme: Boromir
#   [Meme] IF YOU <text> GONNA HAVE A BAD TIME - Meme: Ski Instructor
#   [Meme] IF YOU <text> TROLLFACE <text> - Meme: Troll Face
#   [Meme] Aliens guy <text> - Meme: Aliens guy
#   [Meme] Brace yourself <text> - Meme: Ned Stark braces for <text>
#   [Meme] Iron Price <text> - Meme: To get <text>? Pay the iron price!
#   [Meme] Not sure if <something> or <something else> - Meme: Futurama Fry
#   [Meme] <text>, AND IT'S GONE - Meme: Bank Teller
#   [Meme] WHAT IF I TOLD YOU <text> - Meme: Morpheus "What if I told you"
#   [Meme] WTF <text> - Meme: Picard WTF
#   [Meme] IF <text> THAT'D BE GREAT - Meme: Generates Lumberg
#   [Meme] MUCH <text> (SO|VERY) <text> - Meme: Generates Doge
#   [Meme] <text>, <text> EVERYWHERE - Meme: Generates Buzz Lightyear
#   [Meme] khanify <text> - Meme: Has Shatner yell your phrase
#   [Meme] pun | bad joke eel <text>? <text> - Meme: Bad joke eel
#   [Meme] pun | bad joke eel <text> / <text> - Meme: Bad joke eel
#   [Meme] why not both? - Meme: Mexican girl
#   [Meme] why not <text> - Meme: Why not Zoidberg?
#   [Meme] is only <text> - Meme: Why you heff to be med?
# Author:
#   bobanj
#   cycomachead, Michael Ball <cycomachead@gmail.com>
#   peelman, Nick Peelman <nick@peelman.us>
#   ericjsilva, Eric Silva
#   lukewaite, Luke Waite
#   death_au, Gordon Pedersen <gordon@aerion.com.au>

sanitizeHtml = require 'sanitize-html'

memeGenerator = require "./lib/imgflip.coffee"
idToUse = 'imgflip_id'
memes = [];

module.exports = (robot) ->
  
  # middleware to strip html. This will stop success kid showing up on something like
  # "<span class='aui-lozenge-success'>"
  robot.receiveMiddleware (context, next, done) ->
    if context.response.message.text
      clean = sanitizeHtml(context.response.message.text, {allowedTags:[]})
      context.response.message.text = clean
    next(done)

  storageLoaded = =>
    robot.logger.info "meme-hear: brain has (re)loaded"
    for meme in memes
      # robot.logger.debug "meme-hear: removing existing listener for #{meme.id}"
      robot.listeners = robot.listeners.filter (listener) ->
        return listener.options && listener.options.id != meme.id
      
    memes = [];
    unless robot.brain.data.memes?
      robot.brain.data.memes = defaultMemes

    for meme in robot.brain.data.memes
      setupResponder robot, meme
  
  robot.brain.on "loaded", storageLoaded
  #storageLoaded() # just in case storage was loaded before we got here

setupResponder = (robot, meme) ->
  if meme[idToUse]
    # robot.logger.debug "meme-hear: setting up meme #{meme['id']}"
    responder = robot.hear new RegExp(meme.regex, "i"), {id: meme.id}, (msg) ->
      top = substitute(meme.top, msg, 1)
      bottom = substitute(meme.bottom, msg, 2)
      memeGenerator msg, meme[idToUse], top, bottom
    memes.push meme

substitute = (text, msg, matchNo) ->
  if text
    return text.replace /\{([0-9]+)\}/g, (_, index) ->
      msg.match[index]
  else
    return msg.match[matchNo]
    
defaultMemes =  [
  {
    id: 'meme.not-simply',
    regex: "(one does not simply) (.*)",
    imgflip_id: 61579,
    memecaptain_id: 'da2i4A'
  },
  {
    id: 'meme.interesting-man',
    regex: "(i don'?t always .*) (but when i do,? .*)",
    imgflip_id: 61532,
    memecaptain_id: 'V8QnRQ'
  },
  {
    id: 'meme.aliens',
    regex: "aliens ()(.*)",
    imgflip_id: 101470,
    memecaptain_id: 'sO-Hng'
  },
  {
    id: 'meme.grumpy-cat',
    regex: "grumpy cat ()(.*)",
    imgflip_id: 405658
  },
  {
    id: 'meme.everywhere',
    regex: "(.*),? (\\1 everywhere)",
    imgflip_id: 347390,
    memecaptain_id: 'yDcY5w'
  },
  {
    id: 'meme.not-sure-fry',
    regex: "(not sure if .*) (or .*)",
    imgflip_id: 61520,
    memecaptain_id: 'CsNF8w'
  },
  {
    id: 'meme.y-u-no',
    regex: "(y u no) (.+)",
    imgflip_id: 61527,
    memecaptain_id: 'NryNmg'
  },
  {
    id: 'meme.brace-yourself',
    regex: "(brace yoursel[^\\s]+) (.*)",
    imgflip_id: 61546,
    memecaptain_id: '_I74XA'
  },
  {
    id: 'meme.all-the-things', 
    regex: "(.*) (all the .*)",
    imgflip_id: 61533,
    memecaptain_id: 'Dv99KQ'
    # add case for sad all the things?
  },
  {
    id: 'meme.be-great',
    regex: "(.*) (that would be great|that'?d be great)",
    imgflip_id: 563423,
    memecaptain_id: 'q1cQXg'
  },
  {
    id: 'meme.too-damn-high',
    regex: "(.*) (\\w+\\stoo damn .*)",
    imgflip_id: 61580,
    memecaptain_id: 'RCkv6Q'
  },
  {
    id: 'meme.yo-dawg',
    regex: "(yo dawg .*) (so .*)",
    imgflip_id: 101716,
    memecaptain_id: 'Yqk_kg'
  },
  {
    id: 'meme.bad-time',
    regex: "(.*) (.* gonna have a bad time)",
    imgflip_id: 100951,
    memecaptain_id: 'lfSVJw'
  },
  {
    id: 'meme.only-one-around',
    regex: "(am i the only one around here) (.*)",
    imgflip_id: 259680
  },
  {
    id: 'meme.told-you',
    regex: "(what if i told you) (.*)",
    imgflip_id: 100947,
    memecaptain_id: 'fWle1w'
  },
  {
    id: 'meme.aint-nobody',
    regex: "(.*) (ain'?t nobody got time for? that)",
    imgflip_id: 442575
  },
  {
    id: 'meme.guarantee-it',
    regex: "(.*) (i guarantee it)",
    imgflip_id: 10672255
  },
  {
    id: 'meme.its-gone',
    regex: "(.*) (a+n+d+ it'?s gone)",
    imgflip_id: 766986,
    memecaptain_id: 'uIZe3Q'
  },
  {
    id: 'meme.loses-minds'
    regex: "(.* bats an eye) (.* loses their minds?)",
    imgflip_id: 1790995
  },
  {
    id: 'meme.back-in-my-day',
    regex: "(back in my day) (.*)",
    imgflip_id: 718432
  },
  {
    id: 'meme.success-kid',
    regex: "(.*)\\b(SUCCESS|NAILED IT.*)",
    memecaptain_id: 'AbNPRQ',
    imgflip_id: 61544
  },
  {
    id: 'meme.base-are-belong',
    regex: "(All your .*) (are belong to .*)",
    memecaptain_id: '76CAvA',
    imgflip_id: 4503404
  },
  {
    id: 'meme.bitch-please',
    regex: "(.*)\\s*BITCH PLEASE\\s*(.*)",
    memecaptain_id: 'jo9J0Q',
    imgflip_id: 6411349
  },
  {
    id: 'meme.philosoraptor',
    regex: "(IF .*), ((ARE|CAN|DO|DOES|HOW|IS|MAY|MIGHT|SHOULD|THEN|WHAT|WHEN|WHERE|WHICH|WHO|WHY|WILL|WON\\'T|WOULD)[ \\'N].*)",
    memecaptain_id: '-kFVmQ',
    imgflip_id: 61516
    # add question mark on end?
  },
  {
    id: 'meme.wtf',
    regex: "(WTF) (.*)",
    memecaptain_id: 'z8IPtw',
    imgflip_id: 245898
  },
  {
    id: 'meme.doge',
    regex: "((?:WOW )?(?:SUCH|MUCH) .*) ((SUCH|MUCH|SO|VERY|MANY) .*)",
    memecaptain_id: 'AfO6hw',
    imgflip_id: 8072285
  },
  {
    id: 'meme.why-not',
    regex: "why not (\\w+)",
    memecaptain_id: 'kzsGfQ',
    imgflip_id: 61573,
    top: '{1}?',
    bottom: 'Why not Zoidberg?'
    #por que no las dos?
  },
  {
    id: 'meme.why-heff-med',
    regex: "IT?'?S (ONLY|JUST)( A)? (.+)",
    memecaptain_id: 'iAGOQw',
    imgflip_id: 109522862,
    top: 'IS ONLY {3}',
    bottom: 'WHY YOU HEFF TO BE MED?'
  },
  {
    id: 'meme.whats-the-deal',
    regex: "(what'?s the deal) (.+)",
    imgflip_id: 46404522
  }
]