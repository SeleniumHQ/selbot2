module Selbot2
  class Revisions
    include Cinch::Plugin
    include SvnHelper

    HELPS << ["r<revision>", "show revision"]

    listen_to :message

    REVISION_EXP = /\br(\d+|HEAD)\b/

    def listen(m)
      revs = m.message.scan(REVISION_EXP).flatten
      revs.each do |rev|
        resp = find(rev)
        resp && m.reply(resp)
      end
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
        "https://code.google.com/p/selenium/source/detail?r=#{revision}"
      end

      def reply
        Util.format_revision author, date, message, revision
      end
    end

  end
end
