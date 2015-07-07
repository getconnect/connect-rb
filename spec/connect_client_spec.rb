require 'minitest/spec'
require 'minitest/autorun'
require 'connect_client/configuration'
require 'connect_client'

describe ConnectClient do
  before do  
    ConnectClient.reset
  end

  it "should throw a configuration error configuration has not been called" do
    connect_event = proc { ConnectClient.push 'test', {} }.must_raise ConnectClient::UnconfiguredError
  end

  it "should respond to push" do
    ConnectClient.configure {}
    ConnectClient.respond_to?(:push).must_equal true
  end

  it "should support configuration via a block" do
    ConnectClient.configure do |config|
      config.must_be_instance_of ConnectClient::Configuration
    end
  end
end