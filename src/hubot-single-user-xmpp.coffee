try
  { Adapter, TextMessage, User } = require 'hubot'
catch
  prequire = require 'parent-require'
  { Adapter, TextMessage, User } = prequire 'hubot'

xmpp = require 'simple-xmpp'

class XMPPAdapter extends Adapter

  constructor: (robot) ->
    @robot = robot
    @admin = process.env.HUBOT_XMPP_ADMIN_JID
    @xmpp = xmpp

  send: (envelope, messages...) ->
    @xmpp.send envelope.user.jid, "#{str}" for str in messages

  emote: (envelope, messages...) ->
    @send envelope, "* #{str}" for str in messages

  reply: (envelope, messages...) ->
    @send envelope, messages

  online: () =>
    @robot.logger.info 'Hubot online, ready to go!'
    @emit 'connected'
    @xmpp.subscribe @admin

  chat: (from, message) =>
    @robot.logger.debug "Received message: #{message} from: #{from}"
    user = new User from,
      jid: from
      room: from
    message = new TextMessage(user, message)
    @receive message

  run: ->
    return @robot.logger.error 'Undefined HUBOT_XMPP_ADMIN_JID' unless @admin

    @xmpp.on 'online', @online
    @xmpp.on 'chat', @chat

    @xmpp.connect
      jid:  process.env.HUBOT_XMPP_USERNAME
      password: process.env.HUBOT_XMPP_PASSWORD
      host: process.env.HUBOT_XMPP_HOST
      port: process.env.HUBOT_XMPP_PORT or 5222

module.exports.use = (robot) ->
  new XMPPAdapter robot
