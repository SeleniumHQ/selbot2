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
        "#{@to}: note from #{@from} #{Util.distance_of_time_in_words @time} ago: #{@message} "
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
        m.channel.send note.to_s
      end

      save @notes
    end

  end
end


