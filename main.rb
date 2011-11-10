# Configure Project 
require './lib/setenv.rb'
include SetEnv

require 'touch.rb'
touch = Events::Touch.new
touch.create                    # Create new sequence
touch.delay_between_cmd = 10    # Delay between events
touch.steps = 6                 # Steps between start and end points

p :record => "Record touch"
touch.add(touch.record(10))
p :record => "Record scroll"
touch.add(touch.record(10, :soft_drag_and_drop))
p :record => "Record touch"
touch.add(touch.record(10))

p :execute => "3 steps"
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





