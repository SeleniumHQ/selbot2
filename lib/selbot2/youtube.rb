require 'json'

module Selbot2
  class Youtube
    include Cinch::Plugin

    HELPS << [":yt", "search YouTube"]

    prefix Selbot2::PREFIX
    match /(?:yt|youtube) (.+)/

    def initialize(*args)
      super

      @apiKey = ENV["youtube_key"]
    end

    def execute(message, query)
      resp = RestClient.get "https://www.googleapis.com/youtube/v3/search?part=snippet&q=#{escaper.escape query}&maxResults=1&key=#{@apiKey}"
      doc = JSON.parse(resp)

      message.reply Video.new(doc["items"][0]).reply
    end

    def escaper
      @escaper ||= URI::Parser.new
    end

    class Video
      def initialize(video)
        @video = video
      end

      def url
        "https://www.youtube.com/watch?v=#{@video["id"]["videoId"]}"
      end

      def title
        @video["snippet"]["title"]
      end

      def reply
        "#{title} - #{url}"
      end
    end

  end # Youtube
end # Selbot2
