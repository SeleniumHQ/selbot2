module Selbot2
  class Note
    include DataMapper::Resource
    storage_names[:default] = 'notes'

    property :id, Serial
    property :sender, String
    property :receiver, String, index: true
    property :message, Text
    property :time, Time

    def to_s
      "note from #{sender} #{Util.distance_of_time_in_words time} ago: #{message} "
    end

    def issues
      IssueFinder.each(message).to_a
    end

    def revisions
      RevisionFinder.each(message).to_a
    end
  end
end
