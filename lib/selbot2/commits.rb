require "uri"

module Selbot2
  class Commits
    include Cinch::Plugin

    MAX_REVS = 10
    HELPS << [":last [num]", "show last num revisions (default = 1)"]

    timer 30, :method => :poll

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
        message.user.privmsg reply_for(commit)
      end
    end

    def poll
      bot.debug "polling git @ #{@last_commit.oid.inspect}"

      @git.update

      if @git.last_commit.oid == @last_commit.oid
        return
      end

      @git.commits_since(@last_commit.time) do |commit|
        Selbot2::CHANNELS.each { |channel| Channel(channel).send reply_for(commit) }
      end

      @last_commit = @git.last_commit
    end

    private

    def reply_for(obj)
      Util.format_revision obj.author[:name],
                           Time.at(obj.time).utc,
                           obj.message.strip,
                           obj.oid[0,7]

    end

  end # Commits
end # Selbot2

