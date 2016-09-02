module Selbot2
  class SeenEvent
    include DataMapper::Resource
    storage_names[:default] = 'seen_events'

    property :id, Serial
    property :nick, String
    property :message, Text
    property :event_type, String
    property :time, Time

    def to_s
      msg = "#{nick} was last seen #{Util.distance_of_time_in_words time} ago"
      msg << complete_message
    end

    private

    def complete_message
      case event_type
      when 'JOIN'
        ', joining.'
      when 'PART'
        ", leaving. (#{message})"
      when 'QUIT'
        ", quitting. (#{message})"
      when 'NICK'
        ", changing nick to #{message}."
      else
        user_message
      end
    end

    def user_message
      match = message.match(/^\001ACTION (.+?)\001/)
      if match
        ", saying '#{nick} #{match.captures.first}'"
      else
        ", saying '#{message}'."
      end
    end
  end
end
