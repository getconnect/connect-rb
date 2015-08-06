require_relative 'connect_client/client'
require_relative 'connect_client/configuration'

module ConnectClient
  class << self
    def gem_root
      File.expand_path '../..', __FILE__
    end

    def configure
      config = Configuration.new
      yield(config)

      @client = ConnectClient::Client.new config
    end

    def reset
      @client = nil
    end

    def method_missing(method, *args, &block)
      return super unless client.respond_to?(method)
      client.send(method, *args, &block)
    end

    def respond_to?(method)
      return (!@client.nil? && @client.respond_to?(method)) || super
    end   

    private

    def client
      raise UnconfiguredError if @client.nil?

      @client
    end 
  end

  class UnconfiguredError < StandardError
    def message
      "Connect must configured before it can be used, please call Connect.configure"
    end
  end
end