require 'json'

module Selbot2
  class Youtube
    include Cinch::Plugin

    HELPS << [":yt", "search YouTube"]

    self.prefix = Selbot2::PREFIX
    match /(?:yt|youtube) (.+)/

    def initialize(*args)
      super

      @apiKey = ENV["youtube_key"]
    end

    def execute(message, query)
      # illicitonion happens to run a proxy for YouTube search which conveniently avoids Google's EC2 block.
      # 10/28/16: illicitonion's proxy is down indefinitely, temporary proxy added
      resp = RestClient.get "http://lucastproxy.dynu.com:9292/youtube/v3/search?part=snippet&q=#{escaper.escape query}&maxResults=1&key=#{@apiKey}"
      doc = JSON.parse(resp)
      results = doc.fetch("items", [])
      if results.any?
        message.reply Item.new(results.first).reply
      else
        message.reply "No results for '#{query}'!"
      end
    end

    def escaper
      @escaper ||= URI::Parser.new
    end

    class Item
      def initialize(item)
        @item = item
      end

      def url
        if @item["id"]["kind"].include? "playlist"
          "https://www.youtube.com/playlist?list=#{@item["id"]["playlistId"]}"
        else
          "https://www.youtube.com/watch?v=#{@item["id"]["videoId"]}"
        end
      end

      def title
        @item["snippet"]["title"]
      end

      def reply
        "#{title} - #{url}"
      end
    end

  end # Youtube
end # Selbot2
