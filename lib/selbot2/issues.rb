module Selbot2
  class Issues
    include Cinch::Plugin

    HELPS << ["#<issue-number>", "show issue"]
    IGNORED_NICKS = %w[seljenkinsbot]

    ISSUE_EXP = /(?:^|\s)#(\d+)/
    listen_to :message

    def listen(m)
      return if IGNORED_NICKS.include? m.user.nick

      issues = m.message.scan(ISSUE_EXP).flatten
      issues.each do |num|
        resp = find(num)
        resp && m.reply(resp)
      end
    end

    private

    def find(num)
      response = RestClient.get(url_for(num))
      data = Nokogiri.XML(response).css("entry").first

      Issue.new(data).reply if data
    rescue => ex
      p [ex.message, ex.backtrace.first]
    end

    private

    def url_for(num)
      q = "id:#{num}"
      "https://code.google.com/feeds/issues/p/selenium/issues/full?q=#{escaper.escape q}"
    end

    def escaper
      @escaper ||= URI::Parser.new
    end

    class Issue
      def initialize(doc)
        @doc = doc
      end

      def owner
        @doc.xpath(".//issues:owner/issues:username").text
      end

      def id
        @id ||= @doc.xpath("./issues:id").text
      end

      def duplicate?
        status == "duplicate" && duplicate_id
      end

      def duplicate_url
        url_for(duplicate_id) if duplicate?
      end

      def url
        url_for id
      end

      def state
        @doc.xpath("./issues:state").text
      end

      def summary
        @doc.css("title").text
      end

      def labels
        @doc.xpath("./issues:label").map { |e| e.text }
      end

      def status
        @doc.xpath("./issues:status").text.downcase
      end

      def reply
        str = "%g#{owner}%n #{state}/#{status} %B#{summary}%n - #{url} [#{labels.join(' ')}]"
        str << " (duplicate of #{duplicate_url})" if duplicate?

        Util.format_string str
      end

      private

      def url_for(id)
        "http://code.google.com/p/selenium/issues/detail?id=#{id}"
      end

      def duplicate_id
        node = @doc.xpath("./issues:mergedInto/issues:id").first
        node && node.text
      end

    end
  end
end
