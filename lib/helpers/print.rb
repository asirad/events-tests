

module Helpers
  
  
  # @author Asirad
  # Class to print formatted messages
  module Print
    
    
    # Print formatter message
    # @param [String|Hash] msg Message to print with/without tag
    def p(msg)
      if msg.is_a?(Hash)
        tag = msg.keys.first
        value = msg[tag]
      else
        value = msg
      end
      
      case tag.to_s
      when "ok" then print_ok(value)
      when "error" then print_error(value)
      when "record" then print_record(value)
      when "execute" then print_execute(value)
      when "warning" then print_warning(value)
      else print_none(value)
      end
    end
    
    
    private #-------------------- PRIVATE -----------------------
    

    # Method to print formatted message
    # @param [String] tag Some tag as prefix
    # @param [String] msg Message from user
    def print_formatted(tag, msg)
      puts "#{tag}: #{msg}"
    end
    
    
    # Method to create tag and execute formatted print
    # @param [String] msg Message from user
    def print_ok(msg)
      tag = '[    OK     ]'
      print_formatted(tag,msg)
    end
    
    
    # Method to create tag and execute formatted print
    # @param [String] msg Message from user
    def print_error(msg)
      tag = '[   ERROR   ]'
      print_formatted(tag,msg)
    end
    
    
    # Method to create tag and execute formatted print
    # @param [String] msg Message from user
    def print_record(msg)
      tag = '[   RECORD  ]'
      print_formatted(tag,msg)
    end
    
    
    # Method to create tag and execute formatted print
    # @param [String] msg Message from user
    def print_execute(msg)
      tag = '[  EXECUTE  ]'
      print_formatted(tag,msg)
    end
    
    
    # Method to create tag and execute formatted print
    # @param [String] msg Message from user
    def print_warning(msg)
      tag = '[  WARNING  ]'
      print_formatted(tag,msg)
    end
    
    
    # Method to create tag and execute formatted print
    # @param [String] msg Message from user
    def print_info(msg)
      tag = '[   INFO    ]'
      print_formatted(tag,msg)
    end
    
    
    # Method to create tag and execute formatted print
    # @param [String] msg Message from user
    def print_none(msg)
      tag = '             '
      print_formatted(tag,msg)
    end
    
    
  end
  
  
end

