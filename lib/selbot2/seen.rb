module Selbot2
  require 'dm-ar-finders'
  class Seen
    include Cinch::Plugin

    HELPS << [':seen <nick>', 'show when <nick> was last seen']

    listen_to :channel, :join, :part, :quit, :nick
    match /seen (.+)/, prefix: Selbot2::PREFIX

    def listen(m)
      return unless m.user
      nick = m.command == 'NICK' ? m.user.last_nick : m.user.nick

      event = SeenEvent.first_or_create(nick: nick)
      event.update(message: m.message,
                   event_type: m.command,
                   time: Time.now)
    end

    def execute(message, str)
      str.split(/\s+/).each { |nick| check_nick(message, nick) }
    end

    private

    def check_nick(message, nick)
      if [@bot.nick.downcase, message.user.nick.downcase].include? nick.downcase
        message.reply 'Yes.'
      elsif (event = SeenEvent.find_by_sql(['SELECT * FROM seen_events WHERE lower(nick) = ?', nick.downcase]).first)
        message.reply event.to_s
      else
        message.reply "I haven't seen #{nick}."
      end
    end
  end
end
