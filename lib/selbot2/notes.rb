module Selbot2
  class Notes
    include Cinch::Plugin
    include Persistable

    HELPS << [":note <receiver> <message>", "send a note"]
    MAX_NOTES = 5

    listen_to :message, :join

    prefix Selbot2::PREFIX
    match /note (.+?) (.+)/

    STATE = "notes.yml"

    class Note
      attr_reader :message

      def initialize(from, to, message, time)
        @from    = from
        @to      = to
        @message = message
        @time    = time
      end

      def to_s
        "#{@to}: note from #{@from} #{Util.distance_of_time_in_words @time} ago: #{@message} "
      end

      def issues
        IssueFinder.each(@message).to_a
      end

      def revisions
        RevisionFinder.each(@message).to_a
      end
    end # Note

    def initialize(*args)
      super
      @notes = load || {}
      @notes.default_proc = lambda { |hash, key| hash[key] = [] }
    end

    def execute(message, receiver, note)
      return unless message.params.last =~ /^:note/ # anchor to the beginning

      if [@bot.nick, message.user.nick].include? receiver
        message.channel.action "looks the other way"
        return
      end

      if @notes[receiver].size >= MAX_NOTES
        message.reply "#{receiver} already has #{MAX_NOTES} notes."
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
        note.issues.each { |str| m.channel.send str }
        note.revisions.each { |str| m.channel.send str }
      end

      save @notes
    end

  end
end


