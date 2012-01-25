module Selbot2
  class Jenkins
    HOST = "http://sci.illicitonion.com:8080/"

    def self.current_status
      new(RestClient::Resource.new(HOST)).current_status
    end

    def initialize(resource)
      @resource = resource
    end

    def current_status
      counts = Hash.new(0)
      last_build_states.each do |build|
        state = build['building'] ? 'building' : build['result'].to_s.downcase
        counts[state] += 1
      end

      "#{counts['building']} building | #{counts['success']} successful | #{counts['unstable']} unstable | #{counts['failed']} failing | #{counts['aborted']} aborted"
    end

    private

    def last_build_states
      str = @resource['/api/json?tree=jobs[lastBuild[result,building]]'].get :accept => "application/json"
      JSON.parse(str).fetch('jobs').map { |e| e['lastBuild'] }
    end
  end
end