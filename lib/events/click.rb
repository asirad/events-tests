require 'basic.rb'


module Events

  
  # @author Asirad
  # Class to create click sequences
  class Click < Basic
    
    
    # Create new empty sequence
    def create
      @sequence = ""
    end
    
    
    # Add new or next click to sequence
    # @param [String|Symbol] key Name of key
    # @note NOTE: Names are used from Android API (KeyEvent Class)
    def add(key)
      cmd = "input keyevent #{map_key(key)};"
      @sequence == "" ? @sequence = cmd : @sequence = @sequence + cmd
    end
    
    
    # Use ADB program to execute sequence
    def run
      `adb shell "#{@sequence}"`
    end
    
  end
  
  
end
