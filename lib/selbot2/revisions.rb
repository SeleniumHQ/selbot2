module Selbot2
  class Revisions
    include Cinch::Plugin

    HELPS << ["r<revision>", "show revision"]

    listen_to :message

    def listen(m)
      RevisionFinder.each(m.message) do |resp|
        m.reply(resp)
      end
    end

    private

    module RevisionFinder
      include SvnHelper

      RX = /\br(\d+|HEAD)\b/

      module_function

      def each(str)
        nums = str.scan(RX).flatten

        result = []

        nums.each do |num|
          reply = find(num)
          if reply
            yield reply if block_given?
            result << reply
          end
        end

        result
      end

      def find(num)
        doc = svn "log", "-r#{num}"
        entry = doc.css("logentry").first

        entry && Entry.new(entry).reply
      rescue => ex
        p [ex.message, ex.backtrace.first]
      end
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
        "https://code.google.com/p/selenium/source/detail?r=#{revision}"
      end

      def reply
        Util.format_revision author, date, message, revision
      end
    end

  end
end
