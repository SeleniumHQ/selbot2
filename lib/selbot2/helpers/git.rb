require 'rugged'
require 'fileutils'
require 'pry'

module Selbot2
  class Git
    attr_reader :remote, :repo

    def initialize
      path = ENV['GIT_REPO_PATH'] || File.expand_path("tmp/git")

      unless File.exist?(path)
        raise "git repo not found at #{path.inspect}"
      end

      @repo   = Rugged::Repository.new(path)
      @remote = Rugged::Remote.lookup(@repo, 'origin')
    end

    def last_commit
      @repo.last_commit
    end

    def update
      @remote.connect(:fetch) { @remote.download }
    end

    def commits_since(time)
      head_walker.take_while do |commit|
        commit.time > time
      end
    end

    def last(n)
      head_walker.first(n)
    end

    def commit(sha)
      if sha == 'HEAD'
        sha = @repo.head.target
      end

      obj = @repo.lookup(sha)
      obj if obj.type == :commit
    end

    private

    def head_walker
      walker = Rugged::Walker.new(@repo)
      walker.push @repo.last_commit
      walker.sorting Rugged::SORT_DATE

      walker
    end

  end
end

if __FILE__ == $0
  git = Selbot2::Git.new
  commit = git.commit("695e6a407063")

  p commit

  git.commits_since(Time.now - 60*60*24*4).each do |obj|
    p [obj.message, obj.time]
  end
end
