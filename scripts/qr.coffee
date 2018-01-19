# Description:
#   Generate a QR code
#
# Dependencies:
#   None
#
# Commands:
#   qr <your text> - generates a QR code from <your text>

module.exports = (robot) ->
    robot.hear /qr (.*)/i, (msg) ->
        encoded = encodeURI msg.match[1]
        msg.send "https://api.qrserver.com/v1/create-qr-code/?data=#{encoded}&.png"