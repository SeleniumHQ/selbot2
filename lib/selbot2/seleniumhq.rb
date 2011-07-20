require 'restclient'
require 'json'

module Selbot2
  class SeleniumHQ
    include Cinch::Plugin

    HELPS << [":sehq", "search SeleniumHQ"]

    prefix Selbot2::PREFIX
    match /sehq (.+)/

    def execute(message, query)
      resp = fetch(query)
      if items = resp['items']
        replies = items[0..2].map { |d| Result.new(d).reply }

        replies.each_with_index do |rep, idx|
          message.reply "#{idx + 1}: #{rep}"
        end

        if (ts = total_results_in(resp)) && ts > 3
          message.reply "(+ #{ts - 3} more)"
        end
      else
        message.reply "No results."
      end
    end

    def escaper
      @escaper ||= URI::Parser.new
    end

    def fetch(query)
      str = RestClient.get "https://www.googleapis.com/customsearch/v1?cx=016909259827549404702%3Ahzru01fldsm&key=AIzaSyC3Nf0aBxyTLp9aZZkbAJkq0sXXWU35bJ4&q=#{escaper.escape query}"
      JSON.parse(str)
    end

    def total_results_in(resp)
      resp['queries']['request'].first['totalResults']
    rescue
      nil
    end

    class Result
      def initialize(data)
        @data = data
      end

      def title
        @data['title']
      end

      def url
        @data['link']
      end

      def reply
        Util.format_string "%g#{title}%n: #{url}"
      end
    end # Page
  end # Wiki
end # Selbot2
