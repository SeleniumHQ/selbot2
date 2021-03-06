#!/usr/bin/env ruby
require 'net/http'
require 'selbot2'
require 'octokit'

Cinch::Bot.new {
  configure do |c|
    c.server = "irc.libera.chat"
    c.nick   = "selbot2"
    c.channels = Selbot2::CHANNELS
    c.sasl.username = "selbot2"
    c.sasl.password = ENV['IRC_PASSWORD']
    c.plugins.prefix = Selbot2::PREFIX
    c.plugins.plugins = [
      Selbot2::Issues,
      Selbot2::Revisions,
      Selbot2::Wiki,
      Selbot2::Youtube,
      Selbot2::SeleniumHQ,
      Selbot2::CI,
      Selbot2::Google,
      Selbot2::WhoBrokeIt,
      Selbot2::Commits,
      Selbot2::NewIssue,
      Selbot2::Mention
    ]
  end

#  Selbot2::HELPS << [':help', "you're looking at it"]
#  on :message, /:help/ do |m|
#    helps = Selbot2::HELPS.sort_by { |e| e[0] }
#    just = helps.map { |e| e[0].length }.max
#
#    helps.each do |command, help|
#      m.user.privmsg "#{command.ljust just} - #{help}"
#    end
#  end

  Selbot2::HELPS << [':log', "link to today's chat log at logbot"]
  on :message, /:log/ do |m|
    m.reply "https://freenode.logbot.info/selenium"
  end

  [
    {
      :expression => /:help/,
      :text       => "DM of help content not allowed right now, feel free to look at the source for commands to use: https://github.com/SeleniumHQ/selbot2/blob/master/bin/selbot2.rb",
      :help       => "you're looking at it"
    },
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
      :text       => "https://selenium.dev/documentation",
      :help       => "links to Selenium documentation"
    },
    {
      :expression => /:download\b/,
      :text       => "http://selenium.dev/downloads/ and http://selenium-release.storage.googleapis.com/index.html",
      :help       => "links to downloads pages"
    },
    {
      :expression => /:download(s|ing)/,
      :text       => "Please read this article about how to download files with Selenium, and why you shouldn't: https://goo.gl/ZG8g9A",
      :help       => "links to article about downloading files"
    },
    {
      :expression => /:(gist|paste|pastebin)/,
      :text       => "Please paste >3 lines of code or text to https://gist.github.com if you have a github account, or https://pastebin.com if not, and share the resulting URL",
      :help       => "link to gist.github.com",
    },
    {
      :expression => /:docker/,
      :text       => "docker-selenium project: https://github.com/SeleniumHQ/docker-selenium",
      :help       => "Docker images for Selenium Grid",
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
      :text       => "Wiki: #{Selbot2::REPO}/wiki/ChromeDriver | Info: https://goo.gl/D2sZsH | Download: https://goo.gl/gQyZy4",
      :help       => "link to ChromeDriver (wiki, official site, downloads)"
    },
    {
      :expression => /:edge(driver)?/,
      :text       => "Dev-Guide: https://goo.gl/kRR8gz | Download: https://goo.gl/zvW1xW | Status: https://goo.gl/n531sd",
      :help       => "link to Microsoft WebDriver (download + status)"
    },
    {
      :expression => /:(marionet+e|gecko(driver)?)/,
      :text       => "Info: https://goo.gl/Xbtrrm | Download: https://goo.gl/iMvo1d | Status: https://goo.gl/N8DiZU | Mapping: https://goo.gl/xd7NgJ",
      :help       => "link to Marionette (Gecko) WebDriver (info + status)"
    },
    {
      :expression => /:safari(driver)?/,
      :text       => "Intro: https://goo.gl/sBhzTl",
      :help       => "link to SafariDriver"
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
      :text       => ".NET: http://goo.gl/t3faSQ | Java: http://goo.gl/5IVvjZ | Ruby: http://goo.gl/zNfSLK | Python: http://goo.gl/rHRdgk | IDE: https://goo.gl/x6bh5e | IE: http://goo.gl/LJ07LL | Javascript http://goo.gl/e6smYw",
      :help       => "links to change logs"
    },
    {
      :expression => /(can i|how do i|is it possible to).+set (a )?cookies?.*\?/i,
      :text       => "https://selenium.dev/documentation/en/support_packages/working_with_cookies/",
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
      :text       => "https://selenium.dev/documentation/en/webdriver/waits/",
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
      :text       => "If you want to create quick bug reproduction scripts, create scripts to aid in automation-aided exploratory testing, then you want to use Selenium IDE; a Chrome and Firefox add-on that will do simple record-and-playback of interactions with the browser. For a more detailed explanation regarding the original Selenium IDE: https://selenium.dev/blog/2017/firefox-55-and-selenium-ide/",
      :help       => "Let users know IDE is no longer maintained"
    },
    {
      :expression => /:friday/i,
      :text       => "https://www.youtube.com/watch?v=kfVsfOSbJY0",
      :help       => "Friday - Rebecca Black"
    },
    {
      :expression => /:phantomjs/,
      :text       => "PhantomJS support is deprecated. If you're looking for a headless solution for Selenium, use Chrome or Firefox in headless mode.",
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
    },
    {
      :expression => /:blame/,
      :text => "Saying \"It's broken\" is nondescript. If you have a question, please ask with details. If you have a reproducible test case, please submit to the appropriate project's bug tracker.",
      :help => "Provide more details for broken claim"
    },
    {
      :expression => /:tias/,
      :text => "Try it and see - you'll be able to find out much faster if your proposal works by trying it than by asking us if it will work.",
      :help => "Try it and see"
    },
    {
      :expression => /:path/,
      :text       => "Adding Executables to your PATH - https://selenium.dev/documentation/en/webdriver/driver_requirements/#adding-executables-to-your-path",
      :help       => "Add WebDriver to your PATH"
    },
    {
      :expression => /:usefullinks/,
      :text       => "Some good selenium resources are: the :docs, http://elementalselenium.com/ , Simon's blog: http://blog.rocketpoweredjetpants.com/ , https://github.com/christian-bromann/awesome-selenium, and https://saucelabs.com/blog/category/selenium-resources",
      :help       => "Useful Selenium resources"
    },
    {
      :expression => /:ie64/i,
      :text       => "The 64 bit IE Driver should not be used with IE10 or IE11.  You can read why here - http://jimevansmusic.blogspot.co.uk/2014/09/screenshots-sendkeys-and-sixty-four.html",
      :help       => "Why you shouldn't use the 64bit driver"
    },
    {
      :expression => /:slack/i,
      :text       => "We also have a Slack workspace at https://seleniumhq.slack.com which mirrors this channel as well as offers more specific channels. You can join in here: https://goo.gl/9o4J3Y",
      :help       => "Slack info and invite link."
    },
    {
      :expression => /:mirrored/i,
      :text       => "Gentle reminder to our Slack-only participants: this channel is mirrored to IRC, so Slack-only features like threads will not work properly for our IRC users. Let’s try to keep this community welcoming to all who find it by not using Slack-only features.",
      :help       => "This channel is mirrored to IRC"
    }
  ].each do |cmd|
    Selbot2::HELPS << [cmd[:expression].source, cmd[:help]]
    on(:message, cmd[:expression]) { |m| m.reply cmd[:text] }
  end

}.start

