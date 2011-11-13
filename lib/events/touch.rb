require "basic.rb"


module Events
  
  
  # @author Asirad
  # Class to handle touch events e.g. drag and drop some item
  # @todo TODO: Check scrolling option.
  #       It should be possible to scroll pages but I didn't have time to check that
  class Touch < Basic
    
    
    attr_reader :recorded
    attr_accessor :steps, :delay_between_cmd, :number_of_empty
    
    
    # Costructor
    def initialize
      @steps = 3
      @events_number = 0
      @delay_between_cmd = 5
      @number_of_empty = 3
    end
    
    
    # Record touch events
    # @param  [Integer] time How long events should be recorded
    # @param  [String|Symbol|Optional] option Do clear staff if option is set to :drag_and_drop
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
      File.open("#{$PROJECT_PATH}/var/recorded") { |f| @recorded = f.read }
      `rm #{$PROJECT_PATH}/var/recorded`
      filter_only_events
      hex_to_dec
      clear_drag_and_drop if option.to_s == "drag_and_drop"
      clear_soft_drag_and_drop(@steps) if option.to_s == "soft_drag_and_drop"
      @recorded
    end
    
    
    # Create new touch sequence
    def create
      @touch_seq = []
      @events_number = 0
      true
    end
    
    
    # Add recorded touch to sequence
    # @param [String] recorded Recorded event
    def add(recorded)
      @touch_seq[@events_number] = ''
      recorded.each_line { |line| @touch_seq[@events_number] += "adb shell sendevent #{line}" }
      @events_number += 1
    end
    
    
    # Run touch sequence
    def run
      @touch_seq.each do |e|
        `#{e}`
        sleep @delay_between_cmd
      end
    end
    
    
    private #------------------- PRIVATE ------------------------
    
    
    # Clear recorded information
    def clear
      @recorded = ''
    end
    
    
    # Filter only touch events
    # @note NOTE: ADB can print some additional information. 
    #             This method leaves only touch events and delete other information
    def filter_only_events
      filtered = ''
      @recorded.each_line  { |line| filtered += line if line =~ /^\/dev\/input\/event.*/ }
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
    # @note NOTE: ADB tool returns a lot events. It takes a lot time to reproduce action.
    #             ADB needs only few first points and last to reproduce path
    def clear_drag_and_drop
      if @recorded.lines.count > 20
        cleared = []
        table_to_clear = @recorded.split(/\n/)
        last = table_to_clear.size-1
        cleared << table_to_clear[0..3]
        cleared << find_element_entry(table_to_clear, :first_0)
        cleared << find_element_entry(table_to_clear, :first_1)
        0.upto(@number_of_empty) { cleared << find_element_entry(table_to_clear, :null) }
        cleared << find_element_entry(table_to_clear, :last_0)
        cleared << find_element_entry(table_to_clear, :last_1)
        0.upto(@number_of_empty) { cleared << find_element_entry(table_to_clear, :null) }
        cleared << table_to_clear[last-1..last]
        cleared.flatten!
        
        @recorded = ''
        cleared.each { |e| @recorded += "#{e}\n" }
      end
    end
    
    
    # Find specific element in table
    # @note NOTE: To drag something from one point to another we don't need point between start and end
    #             ADB needs only information that process is working and another commands
    # @param  [Array] table Table contains recorded entries 
    # @param  [Symbol|String] type Type of search
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
    
    
    # Method to generate soft move between start and end points
    # @param  [Integer] steps Number of steps between start and end
    # @return [String] Returns sequence
    # @todo IMPROVE: There is hardcoded string. This string should be from recorded entries
    def clear_soft_drag_and_drop(steps)
      if @recorded.lines.count > 20
        cleared = []
        table_to_clear = @recorded.split(/\n/)
        last = table_to_clear.size-1
        steps = find_elements(table_to_clear, steps)
        cleared << table_to_clear[0..3]
        steps.each do |i|
          cleared << i[0]
          cleared << i[1]
          0.upto(@number_of_empty) { |n| cleared << '/dev/input/event0 0 0 0' }
        end
        cleared << table_to_clear[last-5..last]
        cleared.flatten!
        
        @recorded = ''
        cleared.each { |e| @recorded += "#{e}\n" }
      end
    end
    
    
    # Method to find specific number of elements
    # @note NOTE: This method is used to build soft move
    # @param  [Array] table Entries where method should find specific entries
    # @param  [Integer] number Number of elements to find
    # @return [Array] Returns array of entries
    def find_elements(table, number)
      list_of_moves = []
      results = []
      matches = []
      step_size = []
      selected_step_size = 0
      selected_direction = nil
      matches << table.grep(/.*0003\s0\s.*/)
      matches << table.grep(/.*0003\s1\s.*/)
      step_size << matches[0].size.to_i / number
      step_size << matches[1].size.to_i / number
      
      # Set step size as all steps if step size is lower than 1 
      if step_size[0] <= 1 or step_size[1] <= 1
        if matches[0].size > matches[1].size
          selected_step_size = matches[0].size
          selected_direction = 0
        else
          selected_step_size = matches[1].size
          selected_direction = 0
        end
      # Set grater number as step size
      elsif step_size[0] > step_size[1]
        selected_step_size = step_size[0]
        selected_direction = 0
      else
        selected_step_size = step_size[1]
        selected_direction = 1
      end
      
      0.upto(number) do |i|
        list_of_moves << matches[selected_direction][i*selected_step_size]
      end
      
      found = 0
      last_0 = nil
      last_1 = nil
      table.each_with_index do |e|
        if selected_direction == 1
          if e =~ /.*0003\s0\s.*/
            last_0 = e
          end
        else
          if e =~ /.*0003\s1\s.*/
            last_1 = e
          end
        end
        if e == list_of_moves[found]
          results[found] = [ last_0, e ] if selected_direction == 1
          results[found] = [ e, last_1 ] if selected_direction == 0
          found += 1
        end
      end
      
      results
    end
    
    
  end
  
  
end
