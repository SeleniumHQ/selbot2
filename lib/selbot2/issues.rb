module Selbot2
  class Issues
    include Cinch::Plugin

    HELPS << ["#<issue-number>", "show issue"]
    IGNORED_NICKS = %w[seljenkinsbot]

    ISSUE_EXP = /(?:^|\s)(\S+?)?#(\d+)/
    listen_to :message

    def listen(m)
      return if IGNORED_NICKS.include? m.user.nick

      issues = m.message.scan(ISSUE_EXP)
      issues.each do |prefix, num|
        resp = find(prefix, num)
        resp && m.reply(resp)
      end
    end

    private

    def find(project_name, num)
      project_name ||= "selenium"

      if project_name.include? "/"
        fetch_github_issue(project_name, num)
      else
        fetch_gcode_issue(project_name, num)
      end
    rescue => ex
      p [ex.message, ex.backtrace.first]
    end

    private

    def fetch_github_issue(project_name, num)
      data = JSON.parse(RestClient.get("http://github.com/api/v2/json/issues/show/#{project_name}/#{num}"))

      user    = data['user']
      state   = data['state']
      labels  = data['labels'] || []
      summary = data['title']
      url     = "http://github.com/#{project_name}/issues/#{num}"

      str = "%g#{user}%n #{state} %B#{summary}%n - #{url} [#{labels.join(' ')}]"
      Util.format_string str
    rescue RestClient::ResourceNotFound
      nil
    end

    def fetch_gcode_issue(project_name, num)
      q = escaper.escape "id:#{num}"
      url = "https://code.google.com/feeds/issues/p/#{project_name}/issues/full?q=#{q}"

      response = RestClient.get(url)
      data = Nokogiri.XML(response).css("entry").first

      GCodeIssue.new(data, project_name).reply if data
    end

    def escaper
      @escaper ||= URI::Parser.new
    end

    class GCodeIssue
      def initialize(doc, project_name)
        @doc = doc
        @project_name = project_name
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
        "https://code.google.com/p/#{@project_name}/issues/detail?id=#{id}"
      end

      def duplicate_id
        node = @doc.xpath("./issues:mergedInto/issues:id").first
        node && node.text
      end

    end
  end
end
