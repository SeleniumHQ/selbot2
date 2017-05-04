#!/usr/bin/env ruby
require 'net/http'
require 'selbot2'
require 'octokit'

Cinch::Bot.new {
  configure do |c|
    c.server = "chat.freenode.net"
    c.nick   = "selbot2"
    c.channels = Selbot2::CHANNELS
    c.sasl.username = "selbot2"
    c.sasl.password = ENV['IRC_PASSWORD']
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
      Selbot2::Commits,
      Selbot2::NewIssue
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
    m.reply "https://botbot.me/freenode/selenium"
  end

  [
    {
      :expression => /:(source|code)/,
      :text       => "#{Selbot2::REPO}",
      :help       => "link to the source code"
    },
    {
      :expression => /:(api|apidocs)/,
      :text       => ".NET: http://goo.gl/uutZjZ | Java: http://goo.gl/Grc6tm | Ruby: http://goo.gl/jzh4RU | Python: http://goo.gl/sG1GfQ | Javascript: http://goo.gl/hohAut",
      :help       => "links to API docs"
    },
    {
      :expression => /:docs/,
      :text       => "https://seleniumhq.github.io/docs",
      :help       => "links to Selenium documentation"
    },
    {
      :expression => /:download\b/,
      :text       => "http://seleniumhq.org/download/ and http://selenium-release.storage.googleapis.com/index.html",
      :help       => "links to downloads pages"
    },
    {
      :expression => /:download(s|ing)/,
      :text       => "Please read this article about how to download files with Selenium, and why you shouldn't: http://ardesco.lazerycode.com/index.php/2012/07/how-to-download-files-with-selenium-and-why-you-shouldnt/",
      :help       => "links to article about downloading files"
    },
    {
      :expression => /:gist/,
      :text       => "Please paste >3 lines of code or text to https://gist.github.com and share the resulting URL",
      :help       => "link to gist.github.com",
    },
    {
      :expression => /:docker/,
      :text       => "docker-selenium project: https://github.com/SeleniumHQ/docker-selenium",
      :help       => "Docker images for Selenium Standalone Server",
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
      :text       => "#{Selbot2::REPO}/wiki/ChromeDriver | http://chromedriver.storage.googleapis.com/index.html ",
      :help       => "link to ChromeDriver (wiki + downloads)"
    },
    {
      :expression => /:edge(driver)?/,
      :text       => "Download: https://developer.microsoft.com/en-us/microsoft-edge/platform/documentation/dev-guide/tools/webdriver/ | Status: https://developer.microsoft.com/en-us/microsoft-edge/platform/documentation/webdriver-commands/",
      :help       => "link to Microsoft WebDriver (download + status)"
    },
    {
      :expression => /:(marionet+e|gecko(driver)?)/,
      :text       => "Info: https://developer.mozilla.org/en-US/docs/Mozilla/QA/Marionette/WebDriver | Status: https://developer.mozilla.org/en-US/docs/Mozilla/QA/Marionette/WebDriver/status",
      :help       => "link to Marionette (Gecko) WebDriver (info + status)"
    },
    {
      :expression => /:firefox/,
      :text       => "https://wiki.mozilla.org/Releases | Every version of Firefox can be found here http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/ ",
      :help       => "link to release plan and download page of every Firefox version"
    },
    {
      :expression => /:css/,
      :text       => "CSS Selector Tutorial https://saucelabs.com/resources/articles/selenium-tips-css-selectors",
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
      :text       => ".NET: http://goo.gl/t3faSQ | Java: http://goo.gl/5IVvjZ | Ruby: http://goo.gl/zNfSLK | Python: http://goo.gl/rHRdgk | IDE: http://goo.gl/NSHTwR | IE: http://goo.gl/LJ07LL | Javascript http://goo.gl/e6smYw",
      :help       => "links to change logs"
    },
    {
      :expression => /(can i|how do i|is it possible to).+set (a )?cookies?.*\?/i,
      :text       => "http://seleniumhq.org/docs/03_webdriver.html#cookies",
      :help       => "Help people with cookies."
    },
    {
      :expression => /:(testcase|repro|example|sscce)/i,
      :text       => "Please read http://sscce.org/",
      :help       => "Link to 'Short, Self Contained, Correct (Compilable), Example' site"
    },
    {
      :expression => /:(spec|w3c?)/i,
      :text       => "https://w3c.github.io/webdriver/webdriver-spec.html | https://github.com/w3c/webdriver | bugs: http://goo.gl/LxCtcV | tests: https://goo.gl/c0jYUV",
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
      :text       => "https://seleniumhq.github.io/docs/wd.html#waits",
      :help       => "link to docs section on explicit and implicit waits"
    },
    {
      :expression => /:latest/,
      :text       => "standalone-server: http://goo.gl/Z4Z4aM  Python: http://goo.gl/PXpx0Q   IEDriverServer(32bit): http://bit.ly/1jik2D9   IEDriverServer(64bit): http://bit.ly/1lHYaTF",
      :help       => "link to the latest selenium builds"
    },
    {
      :expression => /:fixit/i,
      :text       => "https://www.youtube.com/watch?v=xjzzLelV0Y0",
      :help       => "link to Oscar Rogers quote"
    },
    {
      :expression => /:ide/i,
      :text       => "Selenium IDE is no longer being maintained. You can ask a question, but most people here will be unable to help you. Instead, consider using WebDriver - http://www.seleniumhq.org/projects/webdriver/",
      :help       => "Let users know IDE is no longer maintained"
    },
    {
      :expression => /:friday/i,
      :text       => "https://www.youtube.com/watch?v=kfVsfOSbJY0",
      :help       => "Friday - Rebecca Black"
    },
    {
      :expression => /:phantomjs/,
      :text       => "No users will ever visit your site using a browser even approximating phantomjs. While phantomjs is based on a rendering engine used by one of the major desktop browsers (webkit), it's not the current version, and more importantly, the javascript engine is completely different.",
      :help       => "Don't use headless"
    },
    {
      :expression => /:shipit/,
      :text       => "https://media.giphy.com/media/143vPc6b08locw/giphy.gif",
      :help       => "link to SHIP IT gif"
    },
    {
      :expression => /┻━*┻/,
      :text       => "┬──┬ ノ( ゜-゜ノ)",
      :help       => "unflips the table"
    }
  ].each do |cmd|
    Selbot2::HELPS << [cmd[:expression].source, cmd[:help]]
    on(:message, cmd[:expression]) { |m| m.reply cmd[:text] }
  end

}.start

