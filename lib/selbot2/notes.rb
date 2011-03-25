require "yaml"

module Selbot2
  class Notes
    include Cinch::Plugin
    
    listen_to :message, :join
    
    prefix ":"
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
        "[#{@time.asctime}] #{@from} said: #{text}"
      end
    end # Note
    
    def initialize(*args)
      super
      @notes = load_notes || Hash.new { |hash, key| hash[key] = [] }
    end
    
    def execute(message, receiver, note)
      if [@bot.nick, message.user.nick].include? receiver
        message.channel.action "looks the other way"
        return
      end
      
      @notes[receiver] << Note.new(message.user.nick, receiver, note, Time.now)
      save_notes
      
      message.reply "ok!"
    end
    
    def listen(m)
      return unless @notes.has_key? m.user.nick
      
      @notes.delete(m.user.nick).each do |note|
        m.user.send note.to_s
      end
    end
    
    private
    
    def load_notes
      notes = nil
      
      if File.exist?(STATE)
        notes = YAML.load_file(STATE)
      end
      
      notes
    end
    
    def save_notes
      File.open(STATE, "w") { |file| YAML.dump(@notes, file) }
    end
  end
end


