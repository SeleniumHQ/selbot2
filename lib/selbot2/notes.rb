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

      if [@bot.nick, message.user.nick].include? receiver
        message.channel.action 'looks the other way'
        return
      end

      if Note.all(to: receiver.downcase).size >= MAX_NOTES
        message.reply "#{receiver} already has #{MAX_NOTES} notes."
        return
      end

      Note.create(from: message.user.nick, to: receiver.downcase, message: note, time: Time.now)

      message.reply 'ok!'
    end

    def listen(m)
      notes = Note.all(to: m.user.nick.downcase)
      return unless notes.any?

      notes.each do |note|
        m.channel.send note.to_s
        note.issues.each { |str| m.channel.send str }
        note.revisions.each { |str| m.channel.send str }
      end
      notes.destroy
    end

  end
end


