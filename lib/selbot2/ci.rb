module Selbot2
  class CI
    include Cinch::Plugin

    HELPS << [":ci", "Links to Selenium's CI"]
    HELPS << [":ci repo", "Link and Travis CI status for given repo"]

    JENKINS = 'http://ci.seleniumhq.org:8080/'
    TRAVIS = Selbot2::Travis::HOST

    prefix Selbot2::PREFIX
    match /ci\s?([\w|-]*)/

    def execute(m, repo)
      repo = repo.strip if repo

      repo = 'selenium' if repo.nil? || repo.empty?
      travis = Travis.new(repo)
      last_build = travis.last_build
      if last_build
        response = "Travis: #{TRAVIS}/#{repo}"
        response << "  Status: #{ format_state(last_build['state']) }"
        response << "  Last: #{ format_state(travis.last_completed['state']) }" if last_build['duration'].nil?
        response << "  |  Jenkins: #{JENKINS}" if repo == 'selenium'
      else
        response = "SeleniumHQ has no such repo '#{repo}'"
      end
      m.reply response
    end

    def format_state(state)
      if state == 'passed'
        color = '%g'
      elsif state == 'failed'
        color = '%r'
      else
        color = '%y'
      end
      Util.format_string("#{color + state.upcase}%n")
    end

  end # CI
end # Selbot2