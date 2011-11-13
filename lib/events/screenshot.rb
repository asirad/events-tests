

module Events


  # @author Asirad
  # Class to record and save screenshots from android
  class Screenshot
    
    
    attr_accessor :no, :prefix
    

    # Constructor
    # @note NOTE: Before create object destination folder should be set
    # @param [String] folder Destination folder
    def initialize(folder)
      @destination_folder = folder
      @no     ||= 0
      @prefix ||= "screenshot"
    end
    
    
    # Check if directory exists and file doesn't
    def check
      `mkdir #{@destination_folder}` unless File.directory?(@destination_folder)
      if File.exists?("#{@destination_folder}/#{@prefix}#{@no}.png")      
        @no += 1
        check
      end
    end
    
    
    # Method to take screenshot and convert it to PNG file
    def take
      check
      `adb pull /dev/graphics/fb0 fb0`
      `dd bs=1920 count=800 if=fb0 of=fb0b`
      `ffmpeg -vframes 1 -vcodec rawvideo -f rawvideo -pix_fmt rgb565 -s 480x800 -i fb0 -f image2 -vcodec png #{@destination_folder}/#{@prefix}#{@no}.png`
      `rm fb0b`
    end
    
    
  end

  
end
