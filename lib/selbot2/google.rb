require 'uri'
require 'json'

module Selbot2
  class Google
    include Cinch::Plugin

    match /(?:g|google) (.+)/, prefix: Selbot2::PREFIX


    def execute(message, query)
      resp   = JSON.parse(RestClient.get("https://www.googleapis.com/customsearch/v1?cx=007816448168391566202%3Apybhzvkvbrq&key=#{ENV['GOOGLE_API_KEY']}&num=1&q=#{URI.escape query}"))
      result = resp.fetch('items').first

      if result
        message.reply "#{result['title']}: #{result['link']}"
      else
        message.reply "No results."
      end
    rescue => e
      message.reply e.message
    end

  end # Google
end # Selbot2

