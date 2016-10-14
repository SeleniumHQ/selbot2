require 'json'

module Selbot2
  class Travis

    HOST = 'https://travis-ci.org/SeleniumHQ'.freeze
    API = 'https://api.travis-ci.org/repos/SeleniumHQ'.freeze
    HEADERS = { accept: 'application/vnd.travis-ci.2+json' }.freeze

    attr_reader :builds, :master_builds

    def initialize(repo)
      @resource = RestClient::Resource.new(API + "/#{repo}", headers: HEADERS)
    end

    def builds
      data = JSON.parse(@resource['builds'].get)
      commits = data['commits']
      @builds ||= data['builds'].each do |build|
        build['commit'] = commits.find { |commit| build['commit_id'] == commit['id'] }
      end
    end

    def master_builds
      @master_builds ||= builds.select{ |build| build['commit']['branch'] == 'master' && build['pull_request'] == false }
    end

    def last_build
      master_builds.first
    end

    def last_completed
      master_builds.find { |build| !build['duration'].nil? }
    end

    def blamed
      blame = nil
      master_builds.each do |build|
        blame = build if build['state'] == 'failed'
        break if build['state'] == 'passed'
      end
      blame
    end
  end
end
