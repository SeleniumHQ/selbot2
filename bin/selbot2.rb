#!/usr/bin/env ruby

require 'selbot2'

Cinch::Bot.new {
  configure do |c|
    c.server = "chat.freenode.net"
    c.nick   = "selbot2"
    c.channels = Selbot2::CHANNELS
    c.plugins.plugins = [
      Selbot2::Issues,
      Selbot2::Revisions,
      Selbot2::Wiki,
      Selbot2::Youtube,
      Selbot2::Notes,
      Selbot2::Seen,
      Selbot2::SeleniumHQ,
      Selbot2::CI,
      Selbot2::Google,
      Selbot2::WhoBrokeIt,
      Selbot2::Commits
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

  Selbot2::HELPS << [':log', "link to today's chat log at illictonion"]
  on :message, /:log/ do |m|
    m.reply "https://raw.github.com/SeleniumHQ/irc-logs/master/#{(Time.new.gmtime - 25200).strftime('%Y/%m/%d')}.txt"
  end

  [
    {
      :expression => /:newissue/,
      :text       => "https://code.google.com/p/selenium/issues/entry",
      :help       => "link to issue the tracker"
    },
    {
      :expression => /:(source|code)/,
      :text       => "https://code.google.com/p/selenium/source/checkout",
      :help       => "link to the source code"
    },
    {
      :expression => /:(api|apidocs)/,
      :text       => ".NET: http://goo.gl/lvxok | Java: http://goo.gl/Wvl4G | Ruby: http://goo.gl/ue5sM | Python: http://goo.gl/sCwQ3s | Javascript: http://goo.gl/9aYaOG",
      :help       => "links to API docs"
    },
    {
      :expression => /:download\b/,
      :text       => "http://seleniumhq.org/download/ and http://selenium-release.storage.googleapis.com/index.html",
      :help       => "links to downloads pages"
    },
    {
      :expression => /:downloads/,
      :text       => "Please read this article about how to download files with Selenium, and why you shouldn't: http://ardesco.lazerycode.com/index.php/2012/07/how-to-download-files-with-selenium-and-why-you-shouldnt/",
      :help       => "links to article about downloading files"
    },
    {
      :expression => /:gist/,
      :text       => "Please paste >3 lines of text to https://gist.github.com",
      :help       => "link to gist.github.com",
    },
    {
      :expression => /:(gist-?usage|using-?gist)/,
      :text       => "https://github.com/radar/guides/blob/master/using-gist.markdown",
      :help       => "how to use gists",
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
      :text       => "https://code.google.com/p/selenium/wiki/ChromeDriver | http://chromedriver.storage.googleapis.com/index.html ",
      :help       => "link to ChromeDriver (wiki + downloads)"
    },
    {
      :expression => /:firefox/,
      :text       => "https://wiki.mozilla.org/Releases | Every version of Firefox can be found here http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/ ",
      :help       => "link to release plan and download page of every Firefox version"
    },
    {
      :expression => /:css/,
      :text       => "CSS Selector Tutorial http://saucelabs.com/resources/selenium/css-selectors",
      :help       => "links to CSS Selector Tutorial"
    },
    {
      :expression => /:regex/,
      :text       => "You can play with Regular Expressions here: http://rubular.com/ or http://www.regexr.com/",
      :help       => "links to GUI REGEX tool"
    },

    {
      :expression => /:clarify/,
      :text       => "Please clarify: Are you using WebDriver, RC or IDE? What version of Selenium? What programming language? What browser and browser version? What operating system?",
      :help       => "Please clarify your question."
    },
    {
      :expression => /:change(log|s)\b/,
      :text       => ".NET: http://goo.gl/zBIjE | Java: http://goo.gl/5B23U | Ruby: http://goo.gl/yN6Qm | Python: http://goo.gl/7BtCb | IDE: http://goo.gl/50vLB | IE: http://goo.gl/VYNFyb",
      :help       => "links to change logs"
    },
    {
      :expression => /(can i|how do i|is it possible to).+set (a )?cookies?.*\?/i,
      :text       => "http://seleniumhq.org/docs/03_webdriver.html#cookies",
      :help       => "Help people with cookies."
    },
    {
      :expression => /:ignores?/i,
      :text       => "http://ignores.ci.seleniumhq.org/",
      :help       => "Link to the @Ignore dashboard."
    },
    {
      :expression => /:(testcase|repro|example|sscce)/i,
      :text       => "Please read http://sscce.org/",
      :help       => "Link to 'Short, Self Contained, Correct (Compilable), Example' site"
    },
    {
      :expression => /:(spec|w3c?)/i,
      :text       => "https://w3c.github.io/webdriver/webdriver-spec.html | https://github.com/w3c/webdriver | bugs: http://goo.gl/LxCtcV",
      :help       => "Links to the WebDriver spec."
    },
    {
      :expression => /:kittens\b/,
      :text       => "Before you say you cannot provide html, think of the kittens! http://jimevansmusic.blogspot.ca/2012/12/not-providing-html-page-is-bogus.html",
      :help       => "Letting users know they need to provide html"
    },
    {
      :expression => /m-?day/i,
      :text       => "M-Day: is already! Marionette is IN Firefox!",
      :help       => "What is M-day?"
    },
    {
      :expression => /:waits/,
      :text       => "http://docs.seleniumhq.org/docs/04_webdriver_advanced.jsp#explicit-and-implicit-waits",
      :help       => "link to sehq section on explicit and implicit waits"
    }
  ].each do |cmd|
    Selbot2::HELPS << [cmd[:expression].source, cmd[:help]]
    on(:message, cmd[:expression]) { |m| m.reply cmd[:text] }
  end

}.start
