#!/usr/bin/env ruby
require 'cinch'
require 'selbot2'


channel = $DEBUG ? "#selbot-test" : "#selenium"

Cinch::Bot.new {
  configure do |c|
    c.server = "irc.freenode.net"
    c.nick   = "selbot2"
    c.channels = [channel]
    c.plugins.plugins = [
      Selbot2::Issues,
      Selbot2::Revisions,
      Selbot2::Commits,
      Selbot2::Wiki,
      Selbot2::Youtube
    ]
  end
}.start

