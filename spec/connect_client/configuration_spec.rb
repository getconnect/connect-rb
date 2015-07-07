require 'minitest/spec'
require 'minitest/autorun'
require 'connect_client/configuration'

describe ConnectClient::Configuration do

  it "should default the base_url to production" do
    config = ConnectClient::Configuration.new

    config.base_url.must_equal 'https://api.getconnect.io'
  end

  it "should default async to false" do
    config = ConnectClient::Configuration.new

    config.async.must_equal false
  end

  it "should support setting the project id" do
    config = ConnectClient::Configuration.new
    id = 'id'

    config.project_id = id

    config.project_id.must_equal id
  end

  it "should support setting the push key" do
    config = ConnectClient::Configuration.new
    key = 'key'

    config.api_key = key

    config.api_key.must_equal key
  end

  it "should support setting whether requests are async" do
    config = ConnectClient::Configuration.new
    async = true

    config.async = async

    config.async.must_equal async
  end

  it "should support setting the base url" do
    config = ConnectClient::Configuration.new
    url = 'url'

    config.base_url = url

    config.base_url.must_equal url
  end

end