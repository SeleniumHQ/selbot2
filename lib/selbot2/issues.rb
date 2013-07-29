module Selbot2
  class Issues
    include Cinch::Plugin

    HELPS << ["#<issue-number>", "show issue"]
    IGNORED_NICKS = %w[seljenkinsbot Selenium-Git]

    listen_to :message

    def listen(m)
      return if IGNORED_NICKS.include? m.user.nick
      IssueFinder.each(m.message) { |resp| m.reply(resp) }
    end

  end

  class IssueFinder
    RX = /
      (?:^|\s)     # space or BOL
      (?!http)     # ignore url anchors
      (?:\(|\[)?   # optional opening parentheses or brace
      ([\w\/-]+?)? # capture 1 - project name
      \#
      (\d+)        # capture 2 - issue number
      (?:\)|\])?   # optional closing parentheses or brace
    /x

    def self.each(str)
      finder = new
      result = []

      str.scan(RX).each do |prefix, num|
        found = finder.find(prefix, num)
        if found
          yield found if block_given?
          result << found
        end
      end

      result
    end

    def find(project_name, num)
      return if project_name && project_name =~ /^http/

      project_name ||= "selenium"

      case project_name
      when "moz", "mozilla", "bugzilla"
        fetch_moz_issue(num)
      when /\//
        fetch_github_issue(project_name, num)
      else
        fetch_gcode_issue(project_name, num)
      end
    rescue => ex
      p [ex.message, ex.backtrace.first]
    end

    private

    def fetch_moz_issue(num)
      data = JSON.parse(RestClient.get("https://api-dev.bugzilla.mozilla.org/latest/bug?id=#{num}"))

      bug     = Array(data['bugs']).first || return
      user    = bug['assigned_to'] && bug['assigned_to']['real_name']
      state   = "#{bug['status']}/#{bug['resolution']}"
      summary = bug['summary']
      url     = "https://bugzilla.mozilla.org/show_bug.cgi?id=#{num}"

      Util.format_string "%g#{user}%n #{state} %B#{summary}%n - #{url}"
    rescue RestClient::ResourceNotFound
      p [ex.message, ex.backtrace.first]
      nil
    end

    def fetch_github_issue(project_name, num)
      issue = JSON.parse(RestClient.get("https://api.github.com/repos/#{project_name}/issues/#{num}"))

      user    = issue['user'] && issue['user']['login']
      state   = issue['state']
      labels  = (issue['labels'] || []).map { |e| e['name'] }
      summary = issue['title']
      url     = issue['html_url']

      str = "%g#{user}%n #{state} %B#{summary}%n - #{url} [#{labels.join(' ')}]"
      Util.format_string str
    rescue RestClient::Gone
      fetch_github_pull_request(project_name, num)
    rescue RestClient::ResourceNotFound => ex
      p [ex.message, ex.backtrace.first]
      nil
    end

    def fetch_github_pull_request(project_name, num)
      issue = JSON.parse(RestClient.get("https://api.github.com/repos/#{project_name}/pulls/#{num}"))

      user    = issue['user'] && issue['user']['login']
      state   = issue['state']
      merged  = issue['merged'] ? 'merged' : 'not merged'
      summary = issue['title']
      url     = issue['html_url']

      str = "%g#{user}%n #{state}, #{merged} %B#{summary}%n - #{url}"
      Util.format_string str
    end

    def fetch_gcode_issue(project_name, num)
      q = escaper.escape "id:#{num}"
      url = "https://code.google.com/feeds/issues/p/#{project_name}/issues/full?q=#{q}"

      response = RestClient.get(url)
      data = Nokogiri.XML(response).css("entry").first

      GCodeIssue.new(data, project_name).reply if data
    rescue RestClient::ResourceNotFound => ex
      p [ex.message, ex.backtrace.first]
      nil
    end

    def escaper
      @escaper ||= URI::Parser.new
    end
  end # IssueFidner

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
