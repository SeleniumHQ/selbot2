module Selbot2
  class Youtube
    include Cinch::Plugin

    HELPS << [":yt", "search YouTube"]

    prefix Selbot2::PREFIX
    match /(?:yt|youtube) (.+)/

    def execute(message, query)
      xml = RestClient.get "http://gdata.youtube.com/feeds/api/videos?q=#{escaper.escape query}&max-results=1&v=2"
      doc = Nokogiri.XML(xml)

      message.reply Video.new(doc.css("entry").first).reply
    end

    def escaper
      @escaper ||= URI::Parser.new
    end

    class Video
      def initialize(doc)
        @doc = doc
      end

      def url
        @doc.css("link[rel=alternate]").first['href']
      end

      def title
        @doc.css("title").text
      end

      def reply
        "#{title} - #{url}"
      end
    end

  end # Youtube
end # Selbot2
