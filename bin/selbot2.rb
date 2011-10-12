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

  Selbot2::HELPS << [':help', "you're looking at it"]
  on :message, /:help/ do |m|
    just = Selbot2::HELPS.map { |e| e[0].length }.max
    Selbot2::HELPS.each { |command, help| m.user.privmsg "#{command.ljust just} - #{help}" }
  end

  on :message, /:log/ do |m|
    m.reply "http://selenium.saucelabs.com/irc/logs/selenium.#{(Time.new.gmtime - 25200).strftime('%F')}.log"
  end

  [
    [/:newissue/, "http://code.google.com/p/selenium/issues/entry", "link to issue the tracker"],
    [/:apidocs/, ".NET: http://goo.gl/Fm3cw | Java: http://goo.gl/kKQqM | Ruby: http://goo.gl/cFyyT", "links to API docs"],
    [/:downloads/, "http://seleniumhq.org/download/ and http://code.google.com/p/selenium/downloads/list", "links to downloads pages"],
    [/:gist/, "Please paste >3 lines of text to http://gist.github.com", "link to gist.github.com", "link to Selenium's CLA"],
    [/:ask/, "If you have a question, please just ask it. Don't look for topic experts. Don't ask to ask. Don't PM. Don't ask if people are awake, or in the mood to help. Just ask the question straight out, and stick around. We'll get to it eventually :)", "Don't ask to ask."],
    [/:cla/, "http://goo.gl/qC50R", "link to today's chat log at saucelabs"],
    [/:(mailing)?lists?/, "https://groups.google.com/forum/#!forum/selenium-users | https://groups.google.com/forum/#!forum/selenium-developers", "link to mailing lists"],
    [/:chrome(driver)?/, "http://code.google.com/p/selenium/wiki/ChromeDriver | http://code.google.com/p/chromium/downloads/list", "link to ChromeDriver (wiki + downloads)"],
  ].each do |exp, msg, help_text|
    Selbot2::HELPS << [exp.source, help_text]
    on(:message, exp) { |m| m.reply msg }
  end

}.start

