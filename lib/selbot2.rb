require 'cinch'
require 'restclient'
require 'nokogiri'
require 'time'
require 'data_mapper'

module Selbot2
  PROJECT_NAME = 'SeleniumHQ/selenium'
  REPO = "https://github.com/#{PROJECT_NAME}"
  PREFIX = ":"
  CHANNELS = Array(ENV['SELBOT_CHANNEL'] || ["#selenium"])
  HELPS = []
end

require 'selbot2/helpers/git'
require 'selbot2/helpers/travis'

require 'selbot2/models/note'
require 'selbot2/models/seen_event'

require 'selbot2/util'
require 'selbot2/issues'
require 'selbot2/revisions'
require 'selbot2/wiki'
require 'selbot2/youtube'
require 'selbot2/notes'
require 'selbot2/seen'
require 'selbot2/seleniumhq'
require 'selbot2/ci'
# require 'selbot2/twitter'
require 'selbot2/google'
require 'selbot2/whobrokeit'
require 'selbot2/commits'
require 'selbot2/newissue'

unless ENV['DATABASE_URL'].nil?
  DataMapper.setup(:default, ENV['DATABASE_URL'])
  DataMapper.finalize
  DataMapper.auto_upgrade!
end