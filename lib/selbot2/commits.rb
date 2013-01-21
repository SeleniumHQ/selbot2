require "uri"

module Selbot2
  class Commits
    include Cinch::Plugin

    MAX_REVS = 10
    HELPS << [":last [num]", "show last num revisions (default = 1)"]

    prefix Selbot2::PREFIX
    match /last( \d+)?/

    def initialize(*args)
      super

      @git = Git.new
      @last_commit = @git.last_commit
    end

    def execute(message, num)
      if num.to_i > 0
        num = num.to_i
      else
        num = 1
      end

      num = MAX_REVS if num > MAX_REVS

      @git.last(num).each do |commit|
        message.user.privmsg Util.format_revision(obj)
      end
    end

    private

  end # Commits
end # Selbot2

