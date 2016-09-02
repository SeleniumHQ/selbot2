module Selbot2
  class Seen
    include Cinch::Plugin

    HELPS << [':seen <nick>', 'show when <nick> was last seen']

    listen_to :channel, :join, :part, :quit, :nick
    prefix Selbot2::PREFIX
    match /seen (.+)/

    def listen(m)
      return unless m.user
      nick = m.command == 'NICK' ? m.user.last_nick : m.user.nick

      event = SeenEvent.first_or_create(nick: nick.downcase)
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
      elsif (event = SeenEvent.first(nick: nick.downcase))
        message.reply event.to_s
      else
        message.reply "I haven't seen #{nick}."
      end
    end
  end
end
