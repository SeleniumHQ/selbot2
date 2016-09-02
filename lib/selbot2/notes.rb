module Selbot2
  class Notes
    include Cinch::Plugin

    HELPS << [':note <receiver> <message>', 'send a note']
    MAX_NOTES = 5

    listen_to :message, :join

    prefix Selbot2::PREFIX
    match /note (.+?) (.+)/

    def execute(message, receiver, note)
      return unless message.params.last =~ /^:note/ # anchor to the beginning
      return if bad_nick?(message, receiver) || max?(message, receiver)

      Note.create(from: message.user.nick,
                  to: receiver.downcase,
                  message: note,
                  time: Time.now)

      message.reply 'ok!'
    end

    def listen(m)
      notes = Note.all(to: m.user.nick.downcase)
      return unless notes.any?

      send_notes(m.channel, notes)
      notes.destroy
    end

    private

    def bad_nick?(message, receiver)
      if [@bot.nick, message.user.nick].include? receiver
        message.channel.action 'looks the other way'
      end
    end

    def max?(message, receiver)
      if Note.all(to: receiver.downcase).size >= MAX_NOTES
        message.reply "#{receiver} already has #{MAX_NOTES} notes."
      end
    end

    def send_notes(channel, notes)
      notes.each do |note|
        channel.send note.to_s
        note.issues.each { |str| channel.send str }
        note.revisions.each { |str| channel.send str }
      end
    end
  end
end
