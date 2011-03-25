module Selbot2
  class Seen
    include Cinch::Plugin
    include Persistable

    listen_to :channel, :join, :part, :quit, :nick
    prefix Selbot2::PREFIX
    match /seen (.+)/

    def initialize(*args)
      super

      @users = load || {}
    end

    def listen(m)
      nick = m.command == 'NICK' ? m.user.last_nick : m.user.nick

      @users[nick] = Event.new(nick, m.message, m.command, Time.now)
      save @users
    end

    def execute(message, nick)
      if [@bot.nick, message.user.nick].include? nick
        message.reply "Yes."
      elsif @users.key? nick
        message.reply @users[nick].to_s
      else
        message.reply "I haven't seen #{nick}."
      end
    end

    class Event
      def initialize(nick, message, type, time)
        @nick    = nick
        @message = message
        @type    = type
        @time    = time
      end

      def to_s
        msg = "#{@nick} was last seen #{Util.distance_of_time_in_words @time} ago"

        case @type
        when 'JOIN'
          msg << ", joining."
        when 'PART'
          msg << ", leaving."
        when 'QUIT'
          msg << ", quitting."
        when 'NICK'
          msg << ", changing nick to #{@message}."
        else
          msg << ", saying '#{@message}'."
        end
      end
    end

  end
end