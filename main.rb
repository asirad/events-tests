# Configure Project 
require './lib/setenv.rb'
include SetEnv

require 'touch.rb'
touch = Events::Touch.new
touch.create
touch.delay_between_cmd = 10
touch.steps = 6

puts "Recording click - Programs button"
touch.add(touch.record(10))

puts "Recording drag and drop - Drag and drop Contacts icon to main desktop"
touch.add(touch.record(10, :drag_and_drop))

puts "Recording drag and drop - Remove Contacts icon from main screen"
touch.add(touch.record(10, :soft_drag_and_drop))

puts "Execute steps"
touch.run


# Require all important files from library
#require 'click.rb'

# Run test
#click = Events::Click.new
#click.create
#click.add(:KEYCODE_DPAD_RIGHT)
#click.add(:KEYCODE_DPAD_RIGHT)
#click.add(:KEYCODE_DPAD_CENTER)
#click.add(:KEYCODE_DPAD_LEFT)
#click.add(:KEYCODE_DPAD_LEFT)
#click.send_text(1234)
#click.run





