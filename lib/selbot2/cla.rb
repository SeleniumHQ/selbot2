require 'uri'

module Selbot2
  class CLA
    include Cinch::Plugin

    prefix Selbot2::PREFIX
    match /(?:cla) (.+)/


    def execute(message, query)
      commits_url = "https://github.com/SeleniumHQ/selenium/commits?author=#{URI.escape query}"
      resp   = RestClient.get(commits_url)
      result = Nokogiri.XML(resp)

      if result.css('.commit').any?
        message.reply "#{query} has signed the CLA and has #{result.css('.commit').size} commits."
      else
        message.reply "#{query} has NOT signed the CLA."
      end
    rescue => e
      message.reply e.message
    end

  end # Cla
end # Selbot2

