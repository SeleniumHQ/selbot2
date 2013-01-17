require 'rugged'
require 'fileutils'

module Selbot2
  class Git
    URL = 'http://code.google.com/p/selenium/'
    
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
      @remote = Rugged::Remote.new(@repo, URL)
    end
    
    def update
      @remote.connect(:fetch) do 
        @remote.download
        @remote.update_tips!
      end
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
  
  git.update
end