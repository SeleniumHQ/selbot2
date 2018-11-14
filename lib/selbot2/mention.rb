module Selbot2
  class Mention
    include Cinch::Plugin

    HELPS << ["!m <name>", "Mention someone for their good work"]

    match /m (\w+)/, prefix: '!'

    def execute(m, name)
      m.reply "You're doing good work, #{name}!"
    end

  end # Mention
end # Selbot2
