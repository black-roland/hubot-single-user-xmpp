Readline = require 'readline'

Robot = require("hubot").Robot
Adapter = require("hubot").Adapter
TextMessage = require("hubot").TextMessage

xmpp = require("simple-xmpp")

class XMPPAdapter extends Adapter

  send: (envelope, strings...) ->
    xmpp.send (envelope.user || envelope),"#{str}" for str in strings

  emote: (envelope, strings...) ->
    @send envelope, "* #{str}" for str in strings

  reply: (envelope, strings...) ->
    strings = strings.map (s) -> "#{s}"
    @send envelope, strings...

  run: ->
    self = @

    xmpp.on 'online', () =>
      @robot.logger.info 'hubot online, ready to go!'
      if process.env.HUBOT_XMPP_ADMIN_JID
        xmpp.subscribe process.env.HUBOT_XMPP_ADMIN_JID
        # xmpp.send process.env.HUBOT_XMPP_ADMIN_JID, "I'm ready!"

    xmpp.on 'chat', (from, message) =>
      @robot.logger.debug "message received,#{from}: #{message}"
      @receive new TextMessage from, message , 'messageId'

    xmpp.connect
      jid:  process.env.HUBOT_XMPP_JID,
      password: process.env.HUBOT_XMPP_PWD,
      host: process.env.HUBOT_XMPP_HOST,
      port: process.env.HUBOT_XMPP_PORT || 5222

    xmpp.getRoster

    self.emit 'connected'

exports.use = (robot) ->
  new XMPPAdapter robot

