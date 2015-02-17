require 'fileutils'

module Selbot2
  class Log
    include Cinch::Plugin

    listen_to :channel, :join, :part, :quit, :nick

    def listen(m)
      return unless m.user
      nick = m.command == 'NICK' ? m.user.last_nick : m.user.nick

      e = Event.new(nick, m.message, m.command, Time.now)
      FileUtils.mkpath "log/#{(Time.new).strftime('%Y/%m')}"
      File.open("log/#{(Time.new).strftime('%Y/%m/%d')}.txt", 'a') {|f| f.puts(e.to_s) }
    end

    private

    class Event
      def initialize(nick, message, type, time)
        @nick    = nick
        @message = message
        @type    = type
        @time    = time
      end

      def to_s
        msg = "#{(Time.new).strftime('[%Y-%m-%d %H:%M:%S] ')}"

        case @type
        when 'JOIN'
          msg << "#{@nick}, joining. (#{@message})"
        when 'PART'
          msg << "#{@nick}, leaving. (#{@message})"
        when 'QUIT'
          msg << "#{@nick}, quitting. (#{@message})"
        when 'NICK'
          msg << "#{@nick}, changing nick to #{@message}."
        else
          if @message =~ /^\001ACTION (.+?)\001/
            msg << "*#{@nick} #{$1}'"
          else
            msg << "#{@nick}: #{@message}"
          end
        end
      end
    end

  end
end
