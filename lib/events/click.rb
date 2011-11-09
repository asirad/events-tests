require 'basic.rb'


module Events

  
  # @author Asirad
  # Class to create move sequences
  class Click < Basic
    
    
    # Create new empty move
    def create
      @move = ""
    end
    
    
    # Add new or next move to sequence
    # @param [String|Symbol] key Name of key
    # @note Names are used from Android API (KeyEvent Class)
    def add(key)
      cmd = "input keyevent #{map_key(key)};"
      @move == "" ? @move = cmd : @move = @move + cmd
    end
    
    
    # Use ADB program to execute sequence
    def run
      `adb shell "#{@move}"`
    end
    
  end
  
  
end
