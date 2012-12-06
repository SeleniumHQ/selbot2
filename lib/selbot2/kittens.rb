module Selbot2
  class Kittens
    include Cinch::Plugin

    HELPS << [":kittens", "Announces who broke it"]

    prefix Selbot2::PREFIX
    match /kittens/

    def execute(m)
      m.reply "Before you say you cannot provide html, think of the kittens! http://jimevansmusic.blogspot.ca/2012/12/not-providing-html-page-is-bogus.html"
    end
  end # Kittens
end # Selbot2


