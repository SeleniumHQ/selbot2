module Selbot2
  class Revisions
    include Cinch::Plugin
    include SvnHelper

    match /\br(\d+)/, :use_prefix => false

    def execute(message, rev)
      resp = find(rev)
      resp && message.reply(resp)
    end

    private

    def find(num)
      doc = svn "log", "-r#{num}"
      entry = doc.css("logentry").first

      entry && Entry.new(entry).reply
    rescue => ex
      p [ex.message, ex.backtrace.first]
    end

    class Entry
      def initialize(doc)
        @doc = doc
      end

      def revision
        @doc['revision']
      end

      def author
        @doc.css("author").text
      end

      def date
        Time.parse @doc.css("date").text
      end

      def message
        @doc.css("msg").text
      end

      def url
        "http://code.google.com/p/selenium/source/detail?r=#{revision}"
      end

      def reply
        Util.format_string "%g#{author}%n #{Util.distance_of_time_in_words date} ago - %B#{message.split("\n").first}%n - #{url}"
      end
    end

  end
end