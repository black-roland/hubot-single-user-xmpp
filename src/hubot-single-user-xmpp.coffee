try
  { Adapter, TextMessage, User } = require 'hubot'
catch
  prequire = require 'parent-require'
  { Adapter, TextMessage, User } = prequire 'hubot'

xmpp = require 'simple-xmpp'

class XMPPAdapter extends Adapter

  reconnectInterval: 30000

  constructor: (robot) ->
    @robot = robot
    @admin = process.env.HUBOT_XMPP_ADMIN_JID
    @xmpp = xmpp

  send: (envelope, messages...) =>
    @xmpp.send envelope.room or envelope.user.jid, "#{str}" for str in messages

  emote: (envelope, messages...) =>
    @send envelope, "* #{str}" for str in messages

  reply: (envelope, messages...) =>
    @send envelope, messages

  online: () =>
    @robot.logger.info 'Hubot online, ready to go!'

    @emit if @connected then 'reconnected' else 'connected'
    @connected = true
    clearInterval @reconnectTimer if @reconnectTimer
    @reconnectTimer = false

    @xmpp.subscribe @admin

  chat: (from, message) =>
    @robot.logger.debug "Received message: #{message} from: #{from}"
    # ignore messages not from admin
    return @robot.logger.debug "Ignoring message" unless from == @admin

    user = new User from,
      jid: from
      room: from

    # remove Hubot name from message
    message = message.replace new RegExp("^#{ process.env.HUBOT_NAME or 'Hubot' } ", 'i')
    message = message.replace new RegExp("^#{ process.env.HUBOT_ALIAS } ", 'i') if process.env.HUBOT_ALIAS
    # prefix all messages with hubot name
    message = "#{ process.env.HUBOT_NAME or 'Hubot' } #{ message }"

    message = new TextMessage(user, message)

    @receive message

  subscribe: (from) =>
    @robot.logger.debug "Accepting subscription from #{from}"
    @xmpp.acceptSubscription from if from == @admin

  error: (err) =>
    @robot.logger.error 'XMPP error', err

  reconnect: () =>
    return if @reconnectTimer

    @robot.logger.info 'Connection lost'

    @reconnectTimer = setInterval () =>
      @robot.logger.info 'Reconnecting...'

      @xmpp.removeListener 'online', @online
      @xmpp.removeListener 'chat', @chat
      @xmpp.removeListener 'subscribe', @subscribe
      @xmpp.removeListener 'error', @error
      @xmpp.conn.removeListener 'end', @reconnect

      @connect()

    , @reconnectInterval

  connect: () =>
    @xmpp.on 'online', @online
    @xmpp.on 'chat', @chat
    @xmpp.on 'subscribe', @subscribe
    @xmpp.on 'error', @error

    @xmpp.connect
      jid:  process.env.HUBOT_XMPP_USERNAME
      password: process.env.HUBOT_XMPP_PASSWORD
      host: process.env.HUBOT_XMPP_HOST
      port: process.env.HUBOT_XMPP_PORT or 5222

    @xmpp.conn.on 'end', @reconnect

  run: =>
    return @robot.logger.error 'Undefined HUBOT_XMPP_ADMIN_JID' unless @admin

    @connect()

module.exports.use = (robot) ->
  new XMPPAdapter robot
