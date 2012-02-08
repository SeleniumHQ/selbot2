module Selbot2
  module SvnHelper
   URL         = "http://selenium.googlecode.com/svn/"
   DATE_FORMAT = "%Y-%m-%d %H:%M"

   def svn(*args)
     command = ["svn", "--xml", "--non-interactive", args, URL].flatten
     out = %x{#{command.join(' ')}}

     raise "command failed: #{command.inspect}" unless $?.success?

     Nokogiri.XML(out)
   end

  end
end
