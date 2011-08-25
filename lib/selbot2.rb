require 'cinch'
require "restclient"
require "nokogiri"
require "time"

module Selbot2
  PREFIX = ":"

  HELPS = []
end

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

# find a way to not maintain this manually
Selbot2::HELPS << [":newissue", "link to issue the tracker"]
Selbot2::HELPS << [":apidocs", "links to API docs"]
Selbot2::HELPS << [":downloads","link to the downloads page"]
Selbot2::HELPS << [":gist", "link to gist.github.com"]
Selbot2::HELPS << [":ask", "don't ask to ask."]
Selbot2::HELPS << [":help", "you're looking at it"]
Selbot2::HELPS << [":cla", "link to Selenium's CLA"]
Selbot2::HELPS << [":log", "link to today's chat log at saucelabs"]
