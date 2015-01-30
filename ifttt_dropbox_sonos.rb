require 'rubygems'
require 'sonos'

class MotionEvents

  DROPBOX_PATH = ENV['HOME'] + "/Dropbox/IFTTT"
  EVENT_PREFIX = "motion"
  COOLDOWN_PERIOD = 10

  SONOS_SYSTEM_IP = "192.168.1.6"
  TRACK_ADDRESS = 'http://soundjax.com/reddo/75015%5ESIREN.mp3'

  def initialize
    @motion_event_processing = false
  end

  def monitor
    while(true)
      process_events

      if @motion_event_processing
        puts "Cooling down for #{COOLDOWN_PERIOD} seconds..."
        sleep COOLDOWN_PERIOD
        # delete any created during the cooldown period
        delete_events
      else
        puts "No motion events found"
        sleep COOLDOWN_PERIOD
      end

      @motion_event_processing = false
    end
  end

  def process_events
    Dir.glob("#{DROPBOX_PATH}/#{EVENT_PREFIX}*") do |filename|
      process_event(filename)
    end
  end

  def process_event(filename)
    if @motion_event_processing
      return
    else
      @motion_event_processing = true
    end

    room = File.read(filename).strip
    if room
      play_track(room,TRACK_ADDRESS)
    else
      puts "Room not specified in event file"
    end
  end

  def play_track(speaker_name, track_address)
    discovery = Sonos::Discovery.new(1, SONOS_SYSTEM_IP)
    system = Sonos::System.new(discovery.topology)

    speaker = nil
    system.speakers.each do |s|
      if s.name == speaker_name
        speaker = s
        break
      end
    end

    if speaker
      puts "Playing track '#{track_address}' on speaker '#{speaker_name}'"
      speaker.ungroup
      speaker.play track_address
      speaker.play
    else
      puts "Speaker #{speaker_name} not found in local system"
    end 
  end

  def delete_events
    Dir.glob("#{DROPBOX_PATH}/#{EVENT_PREFIX}*") do |filename|
      File.delete(filename)
    end
  end
end

MotionEvents.new.monitor