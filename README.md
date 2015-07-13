# [hubot-single-user-xmpp](https://github.com/black-roland/hubot-single-user-xmpp)

Hubot XMPP adapter for single-user usage.

## Features
* The ability to chat without prefixing all messages with Hubot name or alias.
* Filtering. Allowed only messages from the administrator JID (`HUBOT_XMPP_ADMIN_JID`).
* Substitute room JID with administrator JID.

## Configuration

`HUBOT_XMPP_USERNAME` — Hubot JID. Ex.: `hubot@github.com`

`HUBOT_XMPP_PASSWORD` — Account password.

`HUBOT_XMPP_HOST` — The host name you want to connect to if its different than what is in the username JID.

`HUBOT_XMPP_PORT` — The port to connect to on the Jabber server (optional, default 5222).

`HUBOT_XMPP_ADMIN_JID` — Administrator (single-user) JID.
