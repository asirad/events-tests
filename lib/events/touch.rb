require 'ruby-debug'


module Events
  
  
  # @author Asirad
  # Class to handle touch events e.g. drag and drop some item
  # @todo TODO: Implement touch speed.
  #       It should be possible to set speed and to do this clear method should be able
  #       to select more than start and end points of direction
  class Touch
    
    
    attr_reader :recorded
    
    
    # Record touch events
    # @param [Integer] time How long events should be recorded
    # @param [String|Symbol] option Do clear staff if option is set to :drag_and_drop
    # @return [String] Returns events recorded entries
    def record(time, option=nil)
      clear
      t = Thread.new do
        `adb shell getevent > #{$PROJECT_PATH}/var/recorded`
      end
      sleep time
      t.kill
      pidof = `pidof -s adb shell getevent`
      `kill #{pidof}`
      File.open("#{$PROJECT_PATH}/var/recorded") do |f|
        @recorded = f.read
      end
      `rm #{$PROJECT_PATH}/var/recorded`
      filter_only_events
      hex_to_dec
      clear_drag_and_drop if option.to_s == "drag_and_drop"
      @recorded
    end
    
    
    # Create new touch sequence
    def create
      @touch_seq = ''
      true
    end
    
    
    # Add last recorded touch events to touch sequence
    def add(recorded)
      recorded.each_line { |line| @touch_seq += "adb shell sendevent #{line}" }
    end
    
    
    # Run touch sequence
    def run
      `#{@touch_seq}`
    end
    
    
    private #------------------- PRIVATE ------------------------
    
    
    # Clear recorded information
    def clear
      @recorded = ''
    end
    
    
    # Filter only touch events
    # @note ADB can print some additional information. 
    #       This method leaves only touch events and delete other information
    def filter_only_events
      filtered = ''
      @recorded.each_line do |line|
        filtered += line if line =~ /^\/dev\/input\/event.*/
      end
      @recorded = filtered
    end
    
    
    # Convert values from Hex to Decimal
    def hex_to_dec
      converted = ''
      @recorded.each_line do |line|
        part_of_line = line.split(/\s/)
        converted += "#{part_of_line[0].chop} #{part_of_line[1]} #{part_of_line[2].hex} #{part_of_line[3].hex}\n"
      end
      @recorded = converted
    end
    
    
    # Clear events from ADB tool.
    # @note ADB tool returns a lot events. It takes a lot time to reproduce action.
    #       ADB needs only few first points and last to reproduce path
    def clear_drag_and_drop
      debugger
      if @recorded.lines.count > 20
        cleared = []
        table_to_clear = @recorded.split(/\n/)
        last = table_to_clear.size-1
        cleared << table_to_clear[0..3]
        cleared << find_element_entry(table_to_clear, :first_0)
        cleared << find_element_entry(table_to_clear, :first_1)
        0.upto(5) { cleared << find_element_entry(table_to_clear, :null) }
        cleared << find_element_entry(table_to_clear, :last_0)
        cleared << find_element_entry(table_to_clear, :last_1)
        0.upto(5) { cleared << find_element_entry(table_to_clear, :null) }
        cleared << table_to_clear[last-1..last]
        cleared.flatten!
        
        @recorded = ''
        cleared.each do |e|
          @recorded += "#{e}\n"
        end
      end
    end
    
    
    # Find specific element in table
    # @note To drag something from one point to another we don't need point between start and end
    #       ADB needs only information that process is working and another commands
    # @param [Array] table Table contains recorded entries 
    # @param [Symbol|String] type Type of search
    # @return [String] Returns entry from table with recorded entries
    def find_element_entry(table, type)
      if type.to_s == "first_1"
        4.upto(table.size) do |e|
          return table[e] if table[e] =~ /.*0003\s1\s.*/
        end
      elsif type.to_s == "first_0"
        4.upto(table.size) do |e|
          return table[e] if table[e] =~ /.*0003\s0\s.*/
        end
      elsif type.to_s == "last_1"
        table.size.downto(0) do |e|
          return table[e] if table[e] =~ /.*0003\s1\s.*/
        end
      elsif type.to_s == "last_0"
        table.size.downto(0) do |e|
          return table[e] if table[e] =~ /.*0003\s0\s.*/
        end
      elsif type.to_s == "null"
        table.each do |e|
          return e if e =~ /.*0000\s0\s0.*/
        end
      end
    end

        
  end
  
  
end