module Sheepsafe
  class Status
    attr_reader :current_location, :current_network

    def initialize(config = nil)
      @current_location = `networksetup -getcurrentlocation`.chomp
      @current_network = Network.new config
    end
  end
end
