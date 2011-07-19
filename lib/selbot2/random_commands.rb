module Selbot2
  class RandomCommands
    include Cinch::Plugin

    on :message, /:newissue/ do |m|
      m.reply "http://code.google.com/p/selenium/issues/entry"
    end

    on :message, /:apidocs/ do |m|
      m.reply ".NET: http://goo.gl/Fm3cw | Java: http://goo.gl/kKQqM | Ruby: http://goo.gl/cFyyT"
    end

    on :message, /:downloads/ do |m|
      m.reply "http://code.google.com/p/selenium/downloads/list"
    end

    on :message, /:gist/ do |m|
      m.reply "Please paste >3 lines of text to http://gist.github.com"
    end

    on :message, /:ask/ do |m|
      m.reply "If you have a question, please just ask it. Don't look for topic experts. Don't ask to ask. Don't PM. Don't ask if people are awake, or in the mood to help. Just ask the question straight out, and stick around. We'll get to it eventually :)"
    end
    
  end
end
