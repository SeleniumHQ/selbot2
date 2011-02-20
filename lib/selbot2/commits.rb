require "uri"

module Selbot2
  class Commits
    include SvnHelper
    include Cinch::Plugin

    timer 30, :method => :poll

    def initialize(*args)
      super

      @last_revision = fetch_latest_revision
    end

    def poll
      if @last_revision <= 0
        bot.debug "ignoring revision #{@last_revision} for #{URL}"
        return
      else
        bot.debug "polling #{URL} @ #{@last_revision}"
      end

      current_revision = fetch_latest_revision
      return if current_revision == @last_revision

      revisions_between(@last_revision + 1, current_revision).each do |rev|
        Channel(channel).send rev.reply
      end

      @last_revision = current_revision
    end

    private

    def channel
      $DEBUG ? "#selbot-test" : "#selenium"
    end

    def fetch_latest_revision
      doc = svn("info")

      commit = doc.css("commit").first
      (commit && commit['revision']).to_i
    end


    def revisions_between(first, last)
      doc = svn("log", "-r#{first}:#{last}")
      doc.css("logentry").map { |entry| Revision.new(entry) }
    end

    class Revision
      attr_reader :url, :revision, :author, :date, :message

      def initialize(doc)
        @doc = doc
      end

      def revision
        @doc['revision'].to_i
      end

      def author
        @doc.css("author").text
      end

      def date
        Time.parse(@doc.css("date").text)
      end

      def message
        @doc.css("msg").text.to_s.strip
      end

      def url
        "http://code.google.com/p/selenium/source/detail?r=#{revision}"
      end

      def reply
        Util.format_string "%g#{author}%n #{Util.distance_of_time_in_words date} ago - %B#{message.split("\n").first}%n - #{url}"
      end

    end

  end # SvnPoller
end # Selbot2

