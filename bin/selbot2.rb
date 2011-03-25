#!/usr/bin/env ruby

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
      Selbot2::Youtube,
      Selbot2::Notes,
      Selbot2::Seen
    ]
  end

  on :message, /:newissue/ do |m|
    m.reply "http://code.google.com/p/selenium/issues/entry"
  end

  on :message, /:apidocs/ do |m|
    m.reply "http://selenium.googlecode.com/svn/trunk/docs/api/java/index.html (java), http://selenium.googlecode.com/svn/trunk/docs/api/rb/index.html (ruby)"
  end
}.start

