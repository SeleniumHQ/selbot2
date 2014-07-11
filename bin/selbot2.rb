#!/usr/bin/env ruby

require 'selbot2'
require 'yaml'

bot = Cinch::Bot.new {
  configure do |c|
    c.server = "chat.freenode.net"
    c.nick   = "selbot2"
    c.channels = Selbot2::CHANNELS
    c.plugins.plugins = [
      Selbot2::Issues,
      Selbot2::Revisions,
      Selbot2::Wiki,
      Selbot2::Youtube,
      Selbot2::Notes,
      Selbot2::Seen,
      Selbot2::SeleniumHQ,
      Selbot2::CI,
      Selbot2::Google,
      Selbot2::WhoBrokeIt,
      Selbot2::Commits
    ]
  end
  
  yamlFilePath = "res" + File::Separator + "commands.yaml"
  commands = YAML.load_file(yamlFilePath)

  Selbot2::HELPS << [':help', "you're looking at it"]
  on :message, /:help/ do |m|
    helps = Selbot2::HELPS.sort_by { |e| e[0] }
    just = helps.map { |e| e[0].length }.max

    helps.each do |command, help|
      m.user.privmsg "#{command.ljust just} - #{help}"
    end
  end

  Selbot2::HELPS << [':log', "link to today's chat log at illictonion"]
  on :message, /:log/ do |m|
    m.reply "https://raw.github.com/SeleniumHQ/irc-logs/master/#{(Time.new.gmtime - 25200).strftime('%Y/%m/%d')}.txt"
  end

  commands.each do |cmd|
    Selbot2::HELPS << [cmd[:expression].source, cmd[:help]]
    on(:message, cmd[:expression]) { |m| m.reply cmd[:text] }
  end
  
  Selbot2::HELPS << [':add_factoid', "Add a factoid"]
  on :message, /:add_factoid/ do |m|
	factoid = m.raw
	#Strip out all the unnecessary stuff from irc
	factoid = factoid.gsub(/.*\/\:/, "/:")
	factoid = factoid.gsub(/ @.*/, "")
	factoid_split = factoid.split("|")
	#Should have regexp to use, the factoid text and help 
	if factoid_split.size == 3 && factoid =~ /\/.+\/\|.+\|.+/ #Simple regexp to check input
		factoid_split[0] = factoid_split[0].gsub(/\//,"")
		regexp = Regexp.new factoid_split[0]
		new_factoid = {:expression => regexp, :text => factoid_split[1], :help => factoid_split[2]}
		commands << new_factoid
		File.open(yamlFilePath, 'w') do |factoid|
			factoid.write commands.to_yaml
		end
		m.reply "Successfully added factoid!"
		Selbot2::HELPS << [new_factoid[:expression].source, new_factoid[:help]]
		bot.on(:message, new_factoid[:expression]) { |t| t.reply new_factoid[:text] }
	else
		m.reply "Failed to add factoid. Please make sure you provide the regexp, factoid text and help in the format: '/the_regexp/|the_text|the_help'"
		return;
	end
  end
}; bot.start
