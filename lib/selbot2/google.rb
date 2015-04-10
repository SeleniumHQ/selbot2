require 'uri'
require 'json'

module Selbot2
  class Google
    include Cinch::Plugin

    prefix Selbot2::PREFIX
    match /(?:g|google) (.+)/


    def execute(message, query)
      link = "http://lmgtfy.com/?q=#{URI.escape query}"

      message.reply "Here you go: #{link}"
    rescue => e
      message.reply e.message
    end

  end # Google
end # Selbot2

