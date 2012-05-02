require 'cinch'
require "restclient"
require "nokogiri"
require "time"

module Selbot2
  PREFIX = ":"
  CHANNELS = $DEBUG ? ["#selbot-test"] : ["#selenium", "#seleniumide"]
  HELPS = []
end

require 'selbot2/helpers/jenkins'

require 'selbot2/persistable'
require 'selbot2/util'
require 'selbot2/svn_helper'
require 'selbot2/issues'
require 'selbot2/revisions'
require 'selbot2/commits'
require 'selbot2/wiki'
require 'selbot2/youtube'
require 'selbot2/notes'
require 'selbot2/seen'
require 'selbot2/seleniumhq'
require 'selbot2/ci'
require 'selbot2/twitter'
require 'selbot2/google'
require 'selbot2/whobrokeit'
