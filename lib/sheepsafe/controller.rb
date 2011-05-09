require 'daemons'
require 'logger'
begin
  require 'growl'
rescue LoadError
end

module Sheepsafe
  class Controller
    LOG_FILE = Sheepsafe::Config::FILE.sub(/\.yml/, '.log')

    class TeeStdout
      def initialize(controller)
        @stdout, @controller = $stdout, controller
      end

      def write(*args,&block)
        @stdout.write(*args, &block)
        @controller.with_log_file {|f| f.write(*args, &block) }
      end

      def method_missing(meth, *args, &block)
        @stdout.send(meth, *args, &block)
        @controller.with_log_file {|f| f.send(meth, *args, &block) }
      end
    end

    def initialize(config = nil, network = nil, logger = nil)
      @config  = config  || Sheepsafe::Config.new
      @network = network || Sheepsafe::Network.new(@config)
      @logger  = logger
      $stdout  = TeeStdout.new(self)
    end

    def run
      log("Sheepsafe starting")

      if ARGV.first == 'proxy'  # 'sheepsafe proxy up/down/kick'
        bring_socks_proxy ARGV[1]
        return
      end

      # Always recycle the proxy server on network changes
      bring_socks_proxy 'down'
      if network_up?
        if network_changed?
          if switch_to_trusted?
            notify_ok "Switching to #{@config.trusted_location} location"
            system "scselect #{@config.trusted_location}"
          elsif switch_to_untrusted?
            notified = false
            loop do
              system "ssh -p #{@config.ssh_port} #{@config.ssh_host} true &> /dev/null"
              break if $?.success?
              notify_warning("Waiting for internet connection before switching") unless notified
              notified = true
              sleep 5
            end
            notify_warning "Switching to #{@config.untrusted_location} location"
            system "scselect #{@config.untrusted_location}"
            bring_socks_proxy 'up'
          end
          @config.last_network = @network
          @config.write
        elsif !@network.trustworthy?
          bring_socks_proxy 'up'
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
      @network.trustworthy?
    end

    def switch_to_untrusted?
      !@network.trustworthy?
    end

    def bring_socks_proxy(direction)
      cmd = case direction
            when 'up'   then 'start'
            when 'down' then 'stop'
            when 'kick' then 'restart'
            else
              direction
            end
      Daemons.run_proc('sheepsafe.proxy', :ARGV => [cmd], :dir_mode => :normal, :dir => "#{ENV['HOME']}/.sheepsafe") do
        pid = nil
        trap("TERM") do
          Process.kill("TERM", pid)
          exit 0
        end
        sleep 5                 # wait a bit before starting proxy
        exit_count = 0
        ssh_command = "ssh #{@config.ssh_args}"
        loop do
          pid = fork do
            exec(ssh_command)
          end
          Process.waitpid(pid)
          exit_count += 1
          if exit_count % 2 == 1 && exit_count < 10
            log "command '#{ssh_command}' exited #{exit_count} times:\nlast time with #{$?.exitstatus}"
          end
          sleep 1
        end
      end
    end

    def proxy_running?
      File.exist?("#{ENV['HOME']}/.sheepsafe/sheepsafe.proxy.pid") && File.read("#{ENV['HOME']}/.sheepsafe/sheepsafe.proxy.pid").to_i > 0
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
      if @logger
        @logger.info(msg)
      else
        with_log_file {|f| Logger.new(f).info(msg) }
      end
    end

    def with_log_file(&block)
      File.open(LOG_FILE, (File::WRONLY | File::APPEND), &block)
    end
  end
end
