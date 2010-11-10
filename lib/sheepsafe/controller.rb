require 'daemons'
require 'logger'
begin
  require 'growl'
rescue LoadError
end

module Sheepsafe
  class Controller
    LOG_FILE = Sheepsafe::Config::FILE.sub(/\.yml/, '.log')

    def initialize(config = nil, network = nil, logger = nil)
      @config  = config  || Sheepsafe::Config.new
      @network = network || Sheepsafe::Network.new(@config)
      @logger  = logger  || begin
                              STDOUT.reopen(File.open(LOG_FILE, (File::WRONLY | File::APPEND)))
                              Logger.new(STDOUT)
                            end
    end

    def run
      if ARGV.first == 'proxy'  # 'sheepsafe proxy up/down/kick'
        bring_socks_proxy(ARGV[1] == 'kick' ? 'restart' : ARGV[1])
        return
      end

      log("Sheepsafe starting")
      if network_up?
        if network_changed?
          if switch_to_trusted?
            notify_ok "Switching to #{@config.trusted_location} location"
            system "scselect #{@config.trusted_location}"
            bring_socks_proxy 'down'
          elsif switch_to_untrusted?
            bring_socks_proxy 'up'
          end
          @config.last_network = @network
          @config.write
        elsif !@network.trusted?
          # recycle the proxy server on network changes
          bring_socks_proxy 'restart'
        end
      else
        log("AirPort is off")
      end
      log("Sheepsafe finished")
    end

    def network_up?
      @network.up?
    end

    def network_changed?
      @config.last_network.nil? || @network.ssid != @config.last_network.ssid || @network.bssid != @config.last_network.bssid
    end

    def switch_to_trusted?
      @network.trusted?
    end

    def switch_to_untrusted?
      !@network.trusted?
    end

    def bring_socks_proxy(direction)
      Daemons.run_proc('.sheepsafe.proxy', :ARGV => [direction == 'up' ? 'start' : 'stop'],
                       :dir_mode => :normal, :dir => ENV['HOME']) do
        pid = nil
        trap("TERM") do
          Process.kill("TERM", pid)
          exit 0
        end
        notified = false
        loop do
          require 'open-uri'
          length = open("http://example.com") {|f| f.meta['content-length'] } rescue nil
          break if length == "596" # successful contact w/ example.com
          notify_warning("Waiting for internet connection before switching") unless notified
          notified = true
          sleep 5
        end
        notify_warning "Switching to #{@config.untrusted_location} location"
        system "scselect #{@config.untrusted_location}"
        loop do
          pid = fork do
            exec("ssh -ND #{@config.socks_port} #{@config.ssh_host}")
          end
          Process.waitpid(pid, Process::WNOHANG)
          sleep 1
        end
      end
    end

    def proxy_running?
      File.exist?("#{ENV['HOME']}/.sheepsafe.proxy.pid")
    end

    def notify_ok(msg)
      when_growl_available { Growl.notify_ok(msg) }
      log(msg)
    end

    def notify_warning(msg)
      when_growl_available { Growl.notify_warning(msg) }
      log(msg)
    end

    def when_growl_available(&block)
      block.call if defined?(Growl)
    end

    def log(msg)
      @logger.info(msg)
    end
  end
end
