module Selbot2
  class CI
    include Cinch::Plugin

    HELPS << [':ci', "Links to Selenium's CI"]
    HELPS << [':ci repo', 'Link and Travis CI status for given repo']

    JENKINS = 'http://ci.seleniumhq.org:8080'.freeze

    match /ci\s?([\w|-]*)/

    def execute(m, repo)
      repo = repo.strip if repo

      repo = 'selenium' if repo.nil? || repo.empty?
      statuses = [ci_status(Travis.new(repo)), ci_status(AppVeyor.new(repo))]
      statuses << JENKINS if repo.casecmp('selenium').zero?
      statuses.compact!
      statuses.any? ? m.reply(statuses.join(' | ')) : m.reply("SeleniumHQ has no such repo '#{repo}'")
    end

    def ci_status(ci)
      return unless ci.builds.any?
      status = "#{ci.class.const_get :HOST}/#{ci.repo}"
      status << " #{format_state(ci.last_state)}" if ci.last_build
      # Only show last finished state for now, message is getting long
      # status << "  Last: #{ format_state(ci.last_state) }" if ci.last_state and not ['passed', 'success'].include? ci.status
      status
    end

    def format_state(state)
      case state
      when 'passed', 'success'
        color = '%g'
      when 'failed'
        color = '%r'
      else
        color = '%o'
      end
      Util.format_string("#{color + state.upcase}%n")
    end
  end # CI
end # Selbot2
