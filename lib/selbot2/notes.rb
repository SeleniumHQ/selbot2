module Selbot2
  require 'dm-ar-finders'
  class Notes
    include Cinch::Plugin

    HELPS << [':note <receiver> <message>', 'send a note']
    MAX_NOTES = 5

    listen_to :message, :join

    match /note (.+?) (.+)/

    def execute(message, receiver, note)
      return unless message.params.last =~ /^:note/ # anchor to the beginning
      return if bad_nick?(message, receiver) || max?(message, receiver)

      Note.create(sender: message.user.nick,
                  receiver: receiver,
                  message: note,
                  time: Time.now)

      message.reply 'ok!'
    end

    def listen(m)
      notes = Note.find_by_sql(['SELECT * FROM notes WHERE lower(receiver) = ?', m.user.nick.downcase])
      return unless notes.any?

      send_notes(m.user.nick, m.channel, notes)
      notes.destroy
    end

    private

    def bad_nick?(message, receiver)
      if [@bot.nick, message.user.nick].include? receiver
        message.channel.action 'looks the other way'
      end
    end

    def max?(message, receiver)
      if Note.find_by_sql(['SELECT * FROM notes WHERE lower(receiver) = ?', receiver.downcase]).size >= MAX_NOTES
        message.reply "#{receiver} already has #{MAX_NOTES} notes."
      end
    end

    def send_notes(nick, channel, notes)
      notes.each do |note|
        channel.send "#{nick}: #{note.to_s}"
        note.issues.each { |str| channel.send str }
        note.revisions.each { |str| channel.send str }
      end
    end
  end
end
