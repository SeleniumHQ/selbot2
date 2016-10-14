module Selbot2
  class WhoBrokeIt
    include Cinch::Plugin

    HELPS << [':whobrokeit', 'Announces who broke it, along with the commit']

    prefix Selbot2::PREFIX
    match /whobrokeit/

    def execute(m)
      travis = Travis.new('selenium')
      broken = travis.blamed
      response = 'simonstewart'
      response << " | #{Selbot2::RevisionFinder.find(broken['commit']['sha'])}" if broken
      m.reply response
    end
  end
end
