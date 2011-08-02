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
      Selbot2::Seen,
      Selbot2::SeleniumHQ
    ]
  end

  on :message, /:help/ do |m|
    just = Selbot2::HELPS.map { |e| e[0].length }.max
    Selbot2::HELPS.each { |command, help| m.reply "#{command.ljust just} - #{help}" }
  end

  on :message, /:newissue/ do |m|
    m.reply "http://code.google.com/p/selenium/issues/entry"
  end

  on :message, /:apidocs/ do |m|
    m.reply ".NET: http://goo.gl/Fm3cw | Java: http://goo.gl/kKQqM | Ruby: http://goo.gl/cFyyT"
  end

  on :message, /:downloads/ do |m|
    m.reply "http://seleniumhq.org/download/"
  end

  on :message, /:gist/ do |m|
    m.reply "Please paste >3 lines of text to http://gist.github.com"
  end

  on :message, /:ask/ do |m|
    m.reply "If you have a question, please just ask it. Don't look for topic experts. Don't ask to ask. Don't PM. Don't ask if people are awake, or in the mood to help. Just ask the question straight out, and stick around. We'll get to it eventually :)"
  end

}.start

