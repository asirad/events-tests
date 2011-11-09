# Configure Project 
require './lib/setenv.rb'
include SetEnv

require 'touch.rb'
touch = Events::Touch.new
touch.create

puts "Recording click - Programs button"
seq = touch.record(10)

puts "Recording drag and drop - Drag and drop Contacts icon to main desktop"
seq += touch.record(10, :drag_and_drop)

puts "Recording drag and drop - Remove Contacts icon from main screen"
seq += touch.record(10, :drag_and_drop)

puts "Add recorded results to sequence steps"
touch.add(seq)

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





