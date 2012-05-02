module Selbot2
  class CI
    include Cinch::Plugin

    HELPS << [":whobrokeit", "Announces who broke it"]

    prefix Selbot2::PREFIX
    match /whobrokeit/

    def execute(m, arg)
      m.reply "simonstewart"
    end
  end # CI
end # Selbot2
