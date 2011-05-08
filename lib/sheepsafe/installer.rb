module Sheepsafe
  class Installer
    PLIST_FILE = File.expand_path("~/Library/LaunchAgents/sheepsafe.plist")

    attr_reader :config, :network, :controller

    def initialize(config = nil, network = nil, controller = nil)
      require 'highline/import'
      @config  = config  || (File.readable?(Sheepsafe::Config::FILE) ? Sheepsafe::Config.new : Sheepsafe::Config.new({}))
      @network = network || Sheepsafe::Network.new(@config)
      @controller = controller || Sheepsafe::Controller.new(@config, @network, Logger.new(Sheepsafe::Controller::LOG_FILE))
      update_config_with_network
    end

    def install
      intro_message
      config_prompts
      setup_network_location
      write_config
      write_launchd_plist
      register_launchd_task
      announce_done
    end

    def intro_message
      say(<<-MSG)
Welcome to Sheepsafe!

So you want to protect yourself from FireSheep snoopers like me, eh?
Follow the prompts to get started.
MSG
    end

    def config_prompts
      say "First thing we need is the name of a server you can reach via SSH."

      config.ssh_host = ask "SSH connection (server name or user@server) >\n" do |q|
        q.default = config.ssh_host
      end

      config.ssh_port = ask "SSH Port >\n" do |q|
        q.default = config.ssh_port || 22
      end

      say "Testing connectivitity to #{config.ssh_host}..."
      system "ssh -p #{config.ssh_port} #{config.ssh_host} true"
      unless $?.success?
        abort "Sorry! that ssh host was no good."
      end

      config.socks_port = ask "Ok, next we need to pick a port on localhost where the proxy runs >\n" do |q|
       q.default = config.socks_port || 9999
      end

      config.trusted_location = ask "Next, a name for the \"trusted\" network location >\n" do |q|
        q.default = config.trusted_location
      end

      config.trusted_names = ask "Next, one or more trusted network names/SSIDs (comma-separated) >\n" do |q|
        q.default = @names.join(',')
      end.split(",").map(&:strip)
    end

    def setup_network_location
      if `networksetup -listlocations` !~ /Untrusted/m &&
          agree("Next, I'll create and switch to the \"Untrusted\" location in Network Preferences. OK\? (yes/no)\n")
        system "networksetup -createlocation Untrusted populate"
      end

      if agree "Next, I'll set up the SOCKS proxy in the \"Untrusted\" location for you. OK\? (yes/no)\n"
        system "networksetup -switchtolocation Untrusted"
        system "networksetup -setsocksfirewallproxy AirPort localhost #{config.socks_port}"
      end
    end

    def write_config
      say "Saving configuration to #{Sheepsafe::Config::FILE}..."
      config.write
    end

    # Write a launchd plist file to .~/Library/LaunchAgents/sheepsafe.plist.
    #
    # For details see http://tech.inhelsinki.nl/locationchanger/
    def write_launchd_plist
      say "Setting up launchd configuration file #{PLIST_FILE}..."
      Dir.mkdir(File.dirname(PLIST_FILE)) unless File.directory?(File.dirname(PLIST_FILE))
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
    <string>#{sheepsafe_bin_path}</string>
  </array>
  <key>WatchPaths</key>
  <array>
    <string>/Library/Preferences/SystemConfiguration</string>
  </array>
        <!-- We specify PATH here because /usr/local/bin, where grownotify -->
        <!-- is usually installed, is not in the script path by default. -->
        <key>EnvironmentVariables</key>
        <dict>
                <key>PATH</key><string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/bin</string>
        </dict>
</dict>
</plist>
PLIST
      File.open(PLIST_FILE, "w") {|f| f << plist }
    end

    # Register the task with launchd.
    def register_launchd_task
      say "Registering #{PLIST_FILE}"
      system "launchctl load #{PLIST_FILE}"
    end

    def announce_done
      controller.run   # Choose the right network and get things going
      say("Sheepsafe installation done!")
    end

    def uninstall
      if controller.proxy_running?
        say "Shutting down SOCKS proxy..."
        controller.bring_socks_proxy 'down'
      end
      if File.exist?(PLIST_FILE)
        say "Uninstalling Sheepsafe from launchd..."
        system "launchctl unload #{PLIST_FILE}"
        File.unlink PLIST_FILE rescue nil
      end
      Dir['~/.sheepsafe.*'].each {|f| File.unlink f rescue nil}
      say "Uninstall finished."
    end

    def update
      system "launchctl unload #{PLIST_FILE}"
      write_launchd_plist
      register_launchd_task
    end

    def add
      @config.trusted_names << @network.ssid
      @config.last_network = nil
      say "Adding #{config.trusted_names[num]} to your trusted locations"
      write_config
      @controller.run
    end

    def list
      say "Currently trusted locations:"
      puts @config.trusted_names
    end

    #
    # Needed? Remove current network from trusted
    #

    private
    def update_config_with_network
      unless config.trusted_location
        config.trusted_location = network.current_location
      end
      @names = [network.ssid, network.bssid]
    end

    def sheepsafe_bin_path
      begin
        Gem.bin_path('sheepsafe')
      rescue Exception
        File.expand_path('../../../bin/sheepsafe', __FILE__)
      end
    end
  end
end
