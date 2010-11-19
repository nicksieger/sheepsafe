require 'yaml'

module Sheepsafe
  class Config
    FILE = File.expand_path('~/.sheepsafe.yml')
    DEFAULT_CONFIG = {"untrusted_location" => "Untrusted", "socks_port" => "9999", "trust_encrypted?" => "false"}
    ATTRS = %w(trusted_location untrusted_location last_network ssh_host ssh_port socks_port trust_encrypted?)
    ARRAY_ATTRS = %w(trusted_names untrusted_names)

    def self.load_config
      YAML.load_file(FILE)
    rescue Errno::ENOENT
      raise "Unable to read ~/.sheepsafe.yml; please run sheepsafe-install"
    end

    attr_reader :config

    def initialize(hash = nil)
      @config = DEFAULT_CONFIG.merge(hash || self.class.load_config)
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
      File.open(FILE, "w") {|f| f << YAML.dump(config) }
    end
  end
end
