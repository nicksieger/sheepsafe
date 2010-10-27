module Sheepsafe
  class Network
    attr_reader :current_location

    def initialize(config = nil)
      @current_location = `networksetup -getcurrentlocation`.chomp
      @data = YAML.load(`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I`.gsub(/^\s*([^:]+)/, '"\1"'))
      @config = config || Sheepsafe::Config.new({})
    end

    def trusted?
      @config.trusted_names.include?(ssid) || @config.trusted_names.include?(bssid)
    end

    def up?
      @data['AirPort'] != false
    end

    def ssid
      @data['SSID']
    end

    def bssid
      @data['BSSID']
    end
  end
end
