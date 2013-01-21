require 'octokit'
require 'time'
require 'pry'

module Selbot2
  class Git

    def initialize(repo = "seleniumhq/selenium")
      @repo   = repo
      @client = Octokit.new
    end

    def commits_since(time)
      @client.commits_between(@repo, time.iso8601, Time.now.iso8601)
    end

    def last(n)
      @client.commits(REPO, :per_page => n)
    end

    def commit(sha)
      @client.commit(@repo, sha)
    end

  end
end

if __FILE__ == $0
  git = Selbot2::Git.new
  commit = git.commit("695e6a407063")

  p commit
  binding.pry

end
