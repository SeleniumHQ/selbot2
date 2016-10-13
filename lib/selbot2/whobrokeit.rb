module Selbot2
  class WhoBrokeIt
    include Cinch::Plugin

    HELPS << [':whobrokeit', 'Announces who broke it, along with the commit']

    prefix Selbot2::PREFIX
    match /whobrokeit/

    def execute(m)
      travis = Travis.new('selenium')
      last_completed = travis.last_completed
      sha = last_completed['commit']['sha']
      response = 'simonstewart'
      response << " | #{Selbot2::RevisionFinder.find(sha)}" if last_completed['state'] == 'failed'
      m.reply response
    end
  end
end
