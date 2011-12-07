#!/usr/bin/env ruby

require 'selbot2'

Cinch::Bot.new {
  configure do |c|
    c.server = "irc.freenode.net"
    c.nick   = "selbot2"
    c.channels = $DEBUG ? ["#selbot-test"] : ["#selenium", "#seleniumide"]
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
    helps = Selbot2::HELPS.sort_by { |e| e[0] }
    just = helps.map { |e| e[0].length }.max

    helps.each do |command, help|
      m.user.privmsg "#{command.ljust just} - #{help}"
    end
  end

  Selbot2::HELPS << [':log', "link to today's chat log at saucelabs"]
  on :message, /:log/ do |m|
    m.reply "http://selenium.saucelabs.com/irc/logs/selenium.#{(Time.new.gmtime - 25200).strftime('%F')}.log"
  end

  [
    {
      :expression => /:newissue/,
      :text       => "http://code.google.com/p/selenium/issues/entry",
      :help       => "link to issue the tracker"
    },
    {
      :expression => /:apidocs/,
      :text       => ".NET: http://goo.gl/Fm3cw | Java: http://goo.gl/kKQqM | Ruby: http://goo.gl/cFyyT | Python: http://goo.gl/5yWoR",
      :help       => "links to API docs"
    },
    {
      :expression => /:downloads/,
      :text       => "http://seleniumhq.org/download/ and http://code.google.com/p/selenium/downloads/list",
      :help       => "links to downloads pages"
    },
    {
      :expression => /:gist/,
      :text       => "Please paste >3 lines of text to http://gist.github.com",
      :help       => "link to gist.github.com",
    },
    {
      :expression => /:ask/,
      :text       => "If you have a question, please just ask it. Don't look for topic experts. Don't ask to ask. Don't PM. Don't ask if people are awake, or in the mood to help. Just ask the question straight out, and stick around. We'll get to it eventually :)",
      :help       => "Don't ask to ask."
    },
    {
      :expression => /:cla(\W|$)/,
      :text       => "http://goo.gl/qC50R",
      :help       => "link to Selenium's CLA"
    },
    {
      :expression => /:(mailing)?lists?/,
      :text       => "https://groups.google.com/forum/#!forum/selenium-users | https://groups.google.com/forum/#!forum/selenium-developers",
      :help       => "link to mailing lists"
    },
    {
      :expression => /:chrome(driver)?/,
      :text       => "http://code.google.com/p/selenium/wiki/ChromeDriver | http://code.google.com/p/chromium/downloads/list",
      :help       => "link to ChromeDriver (wiki + downloads)"
    },
    {
      :expression => /:clarify/,
      :text       => "Please clarify: Are you using WebDriver, RC or IDE? What version of Selenium? What programming language? What browser and browser version? What operating system?",
      :help       => "Please clarify your question."
    },
    {
      :expression => /:change(log|s)\b/,
      :text       => ".NET: http://goo.gl/SL88L | Java: http://goo.gl/50JPE | Ruby: http://goo.gl/K9ayk | Python: http://goo.gl/Ikm8u | IDE: http://goo.gl/tm4FM",
      :help       => "links to change logs"
    },
    {
      :expression => /(can i|how do i|is it possible to).+set (a )?cookies?.*\?/i,
      :text       => "http://seleniumhq.org/docs/03_webdriver.html#cookies",
      :help       => "Help people with cookies."
    },
    {
      :expression => /:ignores?/i,
      :text       => "http://selenium-ignores.jaribakken.com/",
      :help       => "Link to the @Ignore dashboard."
    }
  ].each do |cmd|
    Selbot2::HELPS << [cmd[:expression].source, cmd[:help]]
    on(:message, cmd[:expression]) { |m| m.reply cmd[:text] }
  end

}.start

