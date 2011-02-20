module Selbot2
  class Wiki
    include Cinch::Plugin

    prefix ":"
    match /wiki (.+)/

    def execute(message, query)
      resp = RestClient.get "http://code.google.com/p/selenium/w/list?can=1&q=#{escaper.escape query}&colspec=PageName+Summary+Changed+ChangedBy"
      doc = Nokogiri.HTML(resp)

      rows = doc.css("#resultstable tr")
      replies = rows[1..3].map { |d| Page.new(d).reply }

      replies.each_with_index do |resp, idx|
        message.reply "#{idx + 1}: #{resp}"
      end

      more = rows.size - replies.size
      if more > 0
        message.reply "(+ #{more} more)"
      end
    end

    def escaper
      @escaper ||= URI::Parser.new
    end

    class Page
      def initialize(doc)
        @doc = doc
      end

      def name
        @doc.css("td.id").text.strip
      end

      def url
        el = @doc.css("td.id a").first
        path = el && el['href']

        "http://code.google.com#{path}"
      end

      def summary
        @doc.css("td.col_1 a").text.strip
      end

      def reply
        Util.format_string "%g#{name}%n: #{summary.split("\n").first} - #{url}"
      end
    end # Page
  end # Wiki
end # Selbot2
