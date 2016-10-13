require 'json'

module Selbot2
  class Travis

    HOST = 'http://api.travis-ci.org/repos/SeleniumHQ'.freeze
    HEADERS = { accept: 'application/vnd.travis-ci.2+json' }.freeze

    attr_reader :builds, :master_builds

    def initialize(repo)
      @resource = RestClient::Resource.new(HOST + "/#{repo}", headers: HEADERS)
    end

    def builds
      data = JSON.parse(@resource['builds'].get)
      commits = data['commits']
      @builds ||= data['builds'].each do |build|
        build['commit'] = commits.find { |commit| build['commit_id'] == commit['id'] }
      end
    end

    def master_builds
      @master_builds ||= builds.select{ |build| build['commit']['branch'] == 'master' }
    end

    def last_build
      master_builds.first
    end

    def last_completed
      master_builds.find { |build| !build['duration'].nil? }
    end
  end
end
