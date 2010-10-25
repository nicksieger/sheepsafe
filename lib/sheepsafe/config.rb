require 'yaml'

module Sheepsafe
  class Config
    FILE = File.expand_path('~/.sheepsafe.yml')
    ATTRS = %w(trusted_location untrusted_location last_location ssh_host socks_port)
    ARRAY_ATTRS = %w(trusted_ssids trusted_bssids)

    def self.load_config
      YAML.load(FILE)
    rescue
      raise "Unable to read ~/sheepsafe.yml; please run sheepsafe-install"
    end

    attr_reader :config

    def initialize(hash = nil)
      @config = hash || self.class.load_config
    end

    ATTRS.each do |m|
      define_method(m) { config[m] }
      define_method("#{m}=") {|v| config[m] = v}
    end

    ARRAY_ATTRS.each do |m|
      define_method(m) { config[m] ||= [] }
      define_method("#{m}=") {|v| config[m] = [v].flatten}
    end

    def write
      File.open(FILE, "w") {|f| f << YAML.dump(@config) }
    end
  end
end
