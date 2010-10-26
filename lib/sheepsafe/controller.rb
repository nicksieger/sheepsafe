require 'daemons'

module Sheepsafe
  class Controller
    def initialize(config = nil, status = nil)
      @config = config || Sheepsafe::Config.new
      @status = status || Sheepsafe::Status.new(@config)
    end

    def run
      if network_changed?
        if switch_to_trusted?
          system "scselect #{@config.trusted_location}"
          bring_socks_proxy 'down'
        elsif switch_to_untrusted?
          bring_socks_proxy 'up'
          system "scselect #{@config.untrusted_location}"
        end
        @config.last_network = @status.current_network
        @config.write
      end
    end

    def network_changed?
      @status.current_network != @config.last_network
    end

    def switch_to_trusted?
      @status.current_network.trusted?
    end

    def switch_to_untrusted?
      !@status.current_network.trusted?
    end

    def bring_socks_proxy(direction)
      Daemons.run_proc '.sheepsafe.proxy', :ARGV => [direction == 'up' ? 'start' : 'stop'], :dir_mode => :normal, :dir => ENV['HOME'] do
        exec("ssh -ND #{@config.socks_port} #{@config.ssh_host}")
      end
    end
  end
end
