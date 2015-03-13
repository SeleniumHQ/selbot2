module Selbot2
  class Wiki
    include Cinch::Plugin

    HELPS << [":wiki", "search the wiki"]

    prefix Selbot2::PREFIX
    match /wiki (.+)/

    def execute(message, query)
      replies = replies_for("pagename:#{query}")

      if replies.empty?
        replies = replies_for(query)
      end

      if replies.empty?
        message.reply "No results."
        return
      end

      replies.each_with_index do |resp, idx|
        message.reply "#{idx + 1}: #{resp}"
      end
    end

    def escaper
      @escaper ||= URI::Parser.new
    end

    def replies_for(query)
      resp = RestClient.get "https://github.com/SeleniumHQ/selenium/wiki"
      doc = Nokogiri.HTML(resp.downcase)

      rows = doc.css("#wiki-content a[href*='#{query.downcase}']")
      rows[0..2].map { |d| Page.new(d).url }.compact
    end

    class Page
      def initialize(doc)
        @doc = doc
      end

      def name
        @doc.text.strip
      end

      def url
        path = @doc['href']

        "https://github.com#{path}"
      end

    end # Page
  end # Wiki
end # Selbot2
