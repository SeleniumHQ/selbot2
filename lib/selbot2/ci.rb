module Selbot2
  class CI
    include Cinch::Plugin

    HELPS << [":ci", "Links to Selenium's CI"]
    HELPS << [":ci status", "Summary the current CI state"]

    LINKS = "Jenkins: #{Selbot2::Jenkins::HOST}"

    prefix Selbot2::PREFIX
    match /ci( .+)?/

    def execute(m, arg)
      arg = arg.strip if arg

      if arg.nil? || arg.empty?
        m.reply LINKS
      else
        case arg
        when 'status'
          m.reply Jenkins.current_status
        else
          m.reply "unknown subcommand #{arg.inspect}"
        end
      end
    end

  end # CI
end # Selbot2
