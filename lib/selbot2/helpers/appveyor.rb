require 'json'

module Selbot2
  class AppVeyor
    API = 'https://ci.appveyor.com/api/projects/SeleniumHQ'.freeze
    HOST = 'https://ci.appveyor.com/project/SeleniumHQ'.freeze
    HEADERS = { accept: 'application/json' }.freeze

    attr_reader :repo

    def initialize(repo)
      @repo = repo
      @resource = RestClient::Resource.new(API + "/#{repo}", headers: HEADERS)
    end

    def builds
      JSON.parse(@resource['history'].get(params: { recordsNumber: 50 }))['builds']
    rescue RestClient::ExceptionWithResponse
      []
    end

    def master_builds
      @master_builds ||= builds.select { |build| build['branch'] == 'master' && build['pullRequestId'].nil? }
    end

    def last_build
      @last_build ||= master_builds.first
    end

    def last_completed
      @last_completed ||= master_builds.find { |build| !build['finished'].nil? }
    end

    def blamed
      blame = nil
      master_builds.each do |build|
        blame = build if build['status'] == 'failed'
        break if build['status'] == 'passed'
      end
      blame
    end

    def status
      last_build['status']
    end

    def last_state
      last_completed['status'] if last_completed
    end
  end
end
