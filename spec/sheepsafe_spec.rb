require 'rspec'
require 'sheepsafe'

describe Sheepsafe::Controller do
  let(:config) do
    mock("config", :trusted_location => "trusted_location", :untrusted_location => "untrusted_location",
         :last_network= => nil, :write => nil)
  end

  let (:status) do
    mock("status", :current_network => "current_network")
  end

  let(:controller) do
    # Stub out logging
    Sheepsafe::Controller.new(config, status, mock("logger", :info => nil)).tap do |c|
      c.stub!(:notify_ok)
      c.stub!(:notify_warning)
    end
  end

  context "#network_changed?" do
    it "is when the current_network is different than the last_network" do
      config.should_receive(:last_network).and_return "last_network"
      status.should_receive(:current_network).and_return "current_network"
      controller.network_changed?.should be_true
    end
  end

  context "#switch_to_trusted?" do
    it "is when the current network is trusted" do
      status.stub_chain(:current_network, :trusted?).and_return true
      controller.switch_to_trusted?.should be_true
    end
  end

  context "#switch_to_untrusted?" do
    it "is when the current network is trusted" do
      status.stub_chain(:current_network, :trusted?).and_return false
      controller.switch_to_untrusted?.should be_true
    end
  end

  context "network didn't change" do
    before :each do
      config.should_receive(:last_network).and_return "last_network"
      status.should_receive(:current_network).and_return "last_network"
    end

    it "does nothing" do
      config.should_not_receive(:write)
      controller.run
    end
  end

  context "network changed" do
    before :each do
      controller.stub!(:network_changed?).and_return true
      controller.stub!(:switch_to_trusted?).and_return false
      controller.stub!(:switch_to_untrusted?).and_return false
    end

    it "writes the last network to the configuration" do
      status.should_receive(:current_network).and_return "current_network"
      config.should_receive(:last_network=).with("current_network").ordered
      config.should_receive(:write).ordered
      controller.run
    end

    context "to trusted" do
      it "changes to the trusted location" do
        controller.should_receive(:switch_to_trusted?).and_return true
        controller.should_receive(:system).with("scselect trusted_location")
        controller.should_receive(:bring_socks_proxy).with('down')
        controller.run
      end
    end

    context "to untrusted" do
      it "changes to the untrusted location" do
        controller.should_receive(:switch_to_untrusted?).and_return true
        controller.should_receive(:system).with("scselect untrusted_location")
        controller.should_receive(:bring_socks_proxy).with('up')
        controller.run
      end
    end
  end
end

describe Sheepsafe::Status do
  let(:status) { Sheepsafe::Status.new }

  its(:current_location) { should_not be_nil }
  its(:current_network) { should_not be_nil }
end

describe Sheepsafe::Network do
  let(:current_network) { Sheepsafe::Network.new }

  context "with trusted SSID" do
    let(:config) { Sheepsafe::Config.new({"trusted_names" => [current_network.current_ssid]}) }
    subject { Sheepsafe::Network.new(config) }

    it { should be_trusted }
  end

  context "with trusted BSSID" do
    let(:config) { Sheepsafe::Config.new({"trusted_names" => [current_network.current_bssid]}) }
    subject { Sheepsafe::Network.new(config) }

    it { should be_trusted }
  end

  context "with no trusted names" do
    subject { Sheepsafe::Network.new }

    it { should_not be_trusted }
  end
end
