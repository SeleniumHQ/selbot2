require "yaml"

module Selbot2
  module Persistable
    def load
      YAML.load_file(persistable_path) if File.exist?(persistable_path)
    end

    def save(obj)
      File.open(persistable_path, "w") { |file| YAML.dump(obj, file) }
    end

    def persistable_path
      "#{ self.class.name.gsub(/[^A-z]/, '').downcase }.yml"
    end
  end
end