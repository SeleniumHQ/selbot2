module Selbot2
  class CI
    include Cinch::Plugin

    HELPS << [":ci", "Links to Selenium's CI"]
    HELPS << [":ci status", "Summary the current CI state"]

    LINKS = "Jenkins: http://sci.illicitonion.com:8080/ | Dashboard: http://selenium-ci.jaribakken.com/"

    prefix Selbot2::PREFIX
    match /ci( .+)?/

    def execute(m, arg)
      arg = arg.strip if arg

      if arg.nil? || arg.empty?
        m.reply LINKS
      else
        case arg
        when 'status'
          m.reply ci_status
        else
          m.reply "unknown subcommand #{arg.inspect}"
        end
      end
    end

    private

    def ci_status
      Jenkins.current_status
    end

  end # CI
end # Selbot2
