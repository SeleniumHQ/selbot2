require 'uri'
require 'json'

module Selbot2
  class Google
    include Cinch::Plugin

    prefix Selbot2::PREFIX
    match /(?:g|google) (.+)/


    def execute(message, query)
      resp   = JSON.parse(RestClient.get("https://www.googleapis.com/customsearch/v1?cx=005991058577830013072%3Awcdcytdwbcy&key=AIzaSyC3Nf0aBxyTLp9aZZkbAJkq0sXXWU35bJ4&num=1&q=#{URI.escape query}"))
      result = resp.fetch('items').first

      if result
        message.reply "#{result['title']}: #{result['url']}"
      else
        message.reply "No results."
      end
    rescue => e
      message.reply e.message
    end

  end # Google
end # Selbot2

