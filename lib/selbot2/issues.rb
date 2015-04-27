module Selbot2
  class Issues
    include Cinch::Plugin

    HELPS << ["#<issue-number>", "show issue"]
    HELPS << [":openissues", "show the number of open issues in the tracker"]
    IGNORED_NICKS = %w[seljenkinsbot Selenium-Git]

    listen_to :message

    if ENV['OPEN_ISSUE_INTERVAL']
      timer ENV['OPEN_ISSUE_INTERVAL'].to_i, method: :send_open_count
    end

    def listen(m)
      return if IGNORED_NICKS.include? m.user.nick

      if m.message =~ /^:(open|open-?issues)/
        m.reply open_count.to_s
      else
        IssueFinder.each(m.message) { |resp| m.reply(resp) }
      end
    end

    def send_open_count
      Channel("#selenium").notice(open_count)
    end

    def open_count
      issues_response = RestClient.get("#{Selbot2::REPO}/issues")
      pr_response     = RestClient.get("#{Selbot2::REPO}/pulls")

      issues_node     = Nokogiri::HTML.parse(issues_response).css("div[id$='toolbar'] a[href*='is'][href*='open']").first
      pr_node         = Nokogiri::HTML.parse(pr_response).css("div[id$='toolbar'] a[href*='is'][href*='open']").first      

      counts = []

      [issues_node, pr_node].each do |node|
        if node && node.text =~ /(\d+) Open/
          counts << "#{$1}"
        end
      end

      msg = "Open issues: %B#{counts[0]}%n\n"
      msg = "#{msg} Open pull requests: %B#{counts[1]}%n\n"
      msg += "#{Selbot2::REPO}/issues | #{Selbot2::REPO}/pulls"
      msg = "%r#{ENV['OPEN_ISSUE_ALERT']}%n #{msg}"

      Util.format_string(msg)
    rescue => ex
      p [ex.message, ex.backtrace.first]
    end
  end

  class IssueFinder
    RX = /
      (?:^|\s)     # space or BOL
      (?!http)     # ignore url anchors
      (?:\(|\[)?   # optional opening parentheses or brace
      ([\w\/\.-]+?)? # capture 1 - project name
      \#
      (\d+)        # capture 2 - issue number
      (?:\)|\])?   # optional closing parentheses or brace
    /x

    def self.each(str)
      finder = new
      result = []

      str.scan(RX).uniq.each do |prefix, num|
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

      project_name ||= "seleniumhq/selenium"

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
      q = escaper.escape "#{num}"
      url = "https://code.google.com/p/#{project_name}/issues/detail?id=#{q}"

      response = RestClient.get(url)
      data = Nokogiri::HTML.parse(response).css("#maincol").first

      GCodeIssue.new(data, project_name).reply if data && data.text !~ /project has moved/i
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
      @doc.xpath(".//td[@id='issuemeta']//th[contains(., 'Owner:')]/../td").text.gsub("\n", '').strip
    end

    def id
      @id ||= @doc.css("a[href^='detail?id=']").text
    end

    def duplicate?
      status == "Duplicate" && duplicate_id
    end

    def duplicate_url
      url_for(duplicate_id) if duplicate?
    end

    def url
      url_for id
    end

    def state
      @doc.css("#color_control").attr('class').text == 'closed_colors' ? 'closed': 'open'
    end

    def summary
      @doc.css("span.h3").text
    end

    def labels
      l = ''
      for label in @doc.css("#issuemeta a.label") do
        l += label.text + " "
      end
      l
    end

    def status
      @doc.css("#issuemeta td")[0].text.gsub("\n ", '')
    end

    def reply
      str = "%g#{owner}%n #{state}/#{status} %B#{summary}%n - #{url} [#{labels}]"
      str << " (duplicate of #{duplicate_url})" if duplicate?

      Util.format_string str
    end

    private

    def url_for(id)
      "https://code.google.com/p/#{@project_name}/issues/detail?id=#{id}"
    end

    def duplicate_id
      node = @doc.xpath(".//td[@id='issuemeta']//th[contains(.,'Merged:')]/..//a").first
      node && node.text.split(' ')[1]
    end
  end

end
