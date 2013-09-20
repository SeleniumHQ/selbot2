require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task :update_fixtures do
  sh 'curl https://code.google.com/p/selenium/issues/detail?id=7 > spec/fixtures/blocking_issue.html' 
  sh 'curl https://code.google.com/p/selenium/issues/detail?id=161 > spec/fixtures/duplicate_issue.html' 
end

task :default => :spec