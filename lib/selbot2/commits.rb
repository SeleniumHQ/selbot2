require "uri"

module Selbot2
  class Commits
    include SvnHelper
    include Cinch::Plugin

    MAX_REVS = 10
    HELPS << [":last [num]", "show last num revisions (default = 1)"]

    timer 30, :method => :poll

    prefix Selbot2::PREFIX
    match /last( \d+)?/


    def initialize(*args)
      super

      @last_revision = fetch_latest_revision
    end

    def execute(message, num)
      if num.to_i > 0
        num = num.to_i
      else
        num = 1
      end

      num = MAX_REVS if num > MAX_REVS

      start = @last_revision - num + 1
      if @last_revision && start >= 0
        revisions_between(start, @last_revision).each do |rev|
          message.reply rev.reply
        end
      end
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
        Selbot2::CHANNELS.each { |channel| Channel(channel).send rev.reply }
      end

      @last_revision = current_revision
    end

    private

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

      def short_message
        message.split("\n").first
      end

      def url
        "http://code.google.com/p/selenium/source/detail?r=#{revision}"
      end

      def reply
        Util.format_string "%g#{author}%n #{Util.distance_of_time_in_words date} ago - %B#{short_message}%n - #{url}"
      end

    end

  end # SvnPoller
end # Selbot2

