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
      resp = RestClient.get "http://code.google.com/p/selenium/w/list?can=1&q=#{escaper.escape query}&colspec=PageName+Summary+Changed+ChangedBy"
      doc = Nokogiri.HTML(resp)

      rows = doc.css("#resultstable > tr")
      rows[0..2].map { |d| Page.new(d).reply unless d.text =~ /did not generate any results/ }.compact
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
