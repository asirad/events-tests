require 'yaml'


# @author Asirad
# Module to set all necessary paths and variables for project
# @note NOTE: $PROJECT_PATH is available and contains path to directory above lib
module SetEnv


  # Add all directories that contains custom libraries
  $LOAD_PATH.unshift File.dirname(__FILE__) unless $LOAD_PATH.include?(File.dirname(__FILE__))
  $PROJECT_PATH = File.dirname(__FILE__).gsub(/\/lib/,"")
  Dir.glob("#{$LOAD_PATH.first}/**/*").each do |e|
    $LOAD_PATH.unshift e if File.directory? e and !$LOAD_PATH.include?(e)
  end


  # Require custom modifications
  require 'print.rb'
  include Helpers::Print
  
    
end
