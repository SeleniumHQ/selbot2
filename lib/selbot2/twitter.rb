require 'json'
require 'twitter'

module Selbot2
  class Twitter
    include Cinch::Plugin

    HELPS << [":fset", "post to twitter an F*SeTips, sorry committers only."]

    self.prefix = Selbot2::PREFIX
    match /fset (.+)/

    COMMITTERS = [
      "adamgoucher",
      "ajay",
      "andreastt",
      "automatedtester",
      "barancev",
      "berrada",
      "davehunt",
      "dawagner",
      "eranm",
      "freynaud",
      "hugs",
      "jarib",
      "jimevans",
      "jleyba",
      "krosenvold",
      "llaskin",
      "lukeis",
      "nirvdrum",
      "plightbo",
      "rosspatterson",
      "samit",
      "santiycr",
      "simonstewart"
    ]

    def initialize(*args)
      super

      cfg = JSON.parse(File.open("twitter.conf").read)
      ::Twitter.configure do |config|
        config.consumer_key = cfg['consumerKey']
        config.consumer_secret = cfg['consumerSecret']
        config.oauth_token = cfg['accessToken']
        config.oauth_token_secret = cfg['accessTokenSecret']
      end
    end

    def execute(message, query)
      if !COMMITTERS.include? message.user.nick.downcase
        message.reply "sorry, you're not allowed to."
        return
      end
      if !query.downcase.include? "fuck"
        message.reply "you forgot to be a potty mouth."
        return
      end

      if query.length > 140
        message.reply "you message is too long by #{query.length - 140} characters"
        return
      end

      ::Twitter.update(query)
      message.reply "ok"
    end

  end #
end # Selbot2
