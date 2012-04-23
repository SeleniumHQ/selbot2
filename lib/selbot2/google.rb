require 'uri'
require 'json'

module Selbot2
  class Google
    include Cinch::Plugin

    prefix Selbot2::PREFIX
    match /(?:g|google) (.+)/


    def execute(message, query)
      resp   = JSON.parse(RestClient.get("http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{URI.escape query}"))
      result = resp.fetch('responseData').fetch('results').first

      if result
        message.reply "#{result['titleNoFormatting']}: #{result['url']}"
      else
        message.reply "No results."
      end
    rescue => e
      message.reply e.message
    end

  end # Google
end # Selbot2

