require 'yaml'


# @author Asirad
# Module to set all necessary paths and variables for project
module SetEnv

  puts File.dirname(__FILE__)
  $LOAD_PATH.unshift File.dirname(__FILE__) unless $LOAD_PATH.include?(File.dirname(__FILE__))
  $PROJECT_PATH = File.dirname(__FILE__).gsub(/\/lib/,"")
  Dir.glob("#{$LOAD_PATH.first}/**/*").each do |e|
    $LOAD_PATH.unshift e if File.directory? e and !$LOAD_PATH.include?(e)
  end

    
end
