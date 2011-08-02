$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'selbot2'

def fixture(name)
  File.read(File.join(File.expand_path("../fixtures/", __FILE__), name))
end