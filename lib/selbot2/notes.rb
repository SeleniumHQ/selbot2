module Selbot2
  class Notes
    include Cinch::Plugin
    include Persistable

    HELPS << [":note <receiver> <message>", "send a note"]

    listen_to :message, :join

    prefix Selbot2::PREFIX
    match /note (.+?) (.+)/

    STATE = "notes.yml"

    class Note
      def initialize(from, to, message, time)
        @from    = from
        @to      = to
        @message = message
        @time    = time
      end

      def to_s
        "[#{Util.distance_of_time_in_words @time}] #{@from} said: #{@message}"
      end
    end # Note

    def initialize(*args)
      super
      @notes = load || {}
      @notes.default_proc = lambda { |hash, key| hash[key] = [] }
    end

    def execute(message, receiver, note)
      if [@bot.nick, message.user.nick].include? receiver
        message.channel.action "looks the other way"
        return
      end

      @notes[receiver] << Note.new(message.user.nick, receiver, note, Time.now)
      save @notes

      message.reply "ok!"
    end

    def listen(m)
      return unless @notes.has_key? m.user.nick

      @notes.delete(m.user.nick).each do |note|
        m.user.send note.to_s
      end

      save @notes
    end

  end
end


