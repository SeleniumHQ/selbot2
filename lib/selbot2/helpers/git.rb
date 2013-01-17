require 'rugged'
require 'fileutils'

module Selbot2
  class Git
    attr_reader :remote, :repo

    def self.instance
      @instance ||= new
    end

    def initialize
      path = ENV['GIT_REPO_PATH'] || File.expand_path("tmp/git")

      unless File.exist?(path)
        raise "git repo not found at #{path.inspect}"
      end

      @repo   = Rugged::Repository.new(path)
      @remote = Rugged::Remote.lookup(@repo, 'origin')
    end

    def commits_since(time)
      @remote.connect(:fetch) { @remote.download }

      walker = Rugged::Walker.new(@repo)
      walker.push @repo.last_commit
      walker.sorting Rugged::SORT_DATE

      found = []
      walker.each do |commit|
        p commit
        found << commit
        break if commit.time <= time
      end

      found
    end

    def commit(sha)
      if sha == 'HEAD'
        sha = @repo.head.target
      end

      obj = @repo.lookup(sha)
      obj if obj.type == "commit"
    rescue
    end

  end
end

if __FILE__ == $0
  git = Selbot2::Git.new
  commit = git.commit("695e6a407063")

  git.commits_since(Time.now - 60*60*24).each do |obj|
    p [obj.type, obj.message]
  end
end
