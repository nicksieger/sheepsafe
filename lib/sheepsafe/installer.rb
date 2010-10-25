module Sheepsafe
  class Installer
    PLIST_FILE = File.expand_path("~/Library/LaunchAgents/sheepsafe.plist")

    attr_reader :config, :status

    def initialize
      @config = File.readable?(Sheepsafe::Config::FILE) ? Sheepsafe::Config.new : Sheepsafe::Config.new({})
      @status = Sheepsafe::Status.new(@config)
      update_config_with_status
    end

    def run
    end

    def write_config
      config.write
    end

    # Write a launchd plist file to .~/Library/LaunchAgents/sheepsafe.plist.
    #
    # For details see http://tech.inhelsinki.nl/locationchanger/
    def write_launchd_plist
      plist = <<-PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
	"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>org.rubygems.sheepsafe</string>
	<key>ProgramArguments</key>
	<array>
		<string>#{Gem.bin_path('sheepsafe')}</string>
	</array>
	<key>WatchPaths</key>
	<array>
		<string>/Library/Preferences/SystemConfiguration</string>
	</array>
</dict>
</plist>
PLIST
      File.open(PLIST_FILE, "w") {|f| f << plist }
    end

    # Register the task with launchd.
    def register_launchd_task
      system "launchctl load #{PLIST_FILE}"
    end

    def update_config_with_status
      unless config.trusted_location
        config.trusted_location = status.current_location
      end
      if config.trusted_ssids.empty?
        config.trusted_ssids = [status.current_network.current_ssid]
      end
      if config.trusted_bssids.empty?
        config.trusted_bssids = [status.current_network.current_bssid]
      end
    end
  end
end
