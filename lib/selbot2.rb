require 'cinch'
require 'restclient'
require 'nokogiri'
require 'time'

module Selbot2
  PROJECT_NAME = 'SeleniumHQ/selenium'
  REPO = "https://github.com/#{PROJECT_NAME}"
  PREFIX = /:/
  CHANNELS = Array(ENV['SELBOT_CHANNEL'] || ["#selenium"])
  HELPS = []
end

require 'selbot2/helpers/appveyor'
require 'selbot2/helpers/git'
require 'selbot2/helpers/travis'

require 'selbot2/util'
require 'selbot2/issues'
require 'selbot2/revisions'
require 'selbot2/wiki'
require 'selbot2/youtube'
require 'selbot2/seleniumhq'
require 'selbot2/ci'
# require 'selbot2/twitter'
require 'selbot2/google'
require 'selbot2/whobrokeit'
require 'selbot2/commits'
require 'selbot2/newissue'
require 'selbot2/mention'
