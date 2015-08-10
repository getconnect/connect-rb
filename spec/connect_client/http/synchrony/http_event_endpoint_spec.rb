require 'minitest/spec'
require 'minitest/autorun'
require 'webmock/minitest'
require 'connect_client/client'
require 'connect_client/configuration'
require 'connect_client/event_push_response'
require 'securerandom'
require 'em-synchrony'
require 'em-synchrony/em-http'

describe ConnectClient::Http::EventEndpoint, "Test with syncrony defined" do
  before do
    @async_endpoint = ConnectClient::Http::EventEndpoint.new (ConnectClient::Configuration.new '', '', true)
    @sample_event_data = { id: SecureRandom.uuid, timestamp: Time.now.utc.iso8601, name: 'sample' }
    @sample_event = ConnectClient::Event.new(@sample_event_data)
    @sample_events_reponse = '{"sample": [{"success": true}]}'
    @sample_collection = 'sample'
    @sample_batch_data = { @sample_collection.to_sym => [@sample_event_data] }
    @sample_batch = { @sample_collection.to_sym => [@sample_event] }
  end

  it "should get a push response back when pushing a single event to a collection" do
    stub_request(:post, "https://api.getconnect.io/events/#{@sample_collection}").
      with(:body => @sample_event_data).
      to_return(:status => 200, :body => "", :headers => { 'Content-Type'=>'application/json' })

    response = nil
    EM.synchrony do
      response = @async_endpoint.push @sample_collection, @sample_event
      EM.stop
    end
    response.must_be_instance_of ConnectClient::EventPushResponse
  end

  it "should get push response for a non sucessful error code" do
    stub_request(:post, "https://api.getconnect.io/events/#{@sample_collection}").
      with(:body => @sample_event_data).
      to_return(:status => 500, :body => "", :headers => { 'Content-Type'=>'application/json' })

    response = nil
    EM.synchrony do
      response = @async_endpoint.push @sample_collection, @sample_event
      EM.stop
    end
    response.http_status_code.to_s.must_equal '500'
  end

  it "should get a push response back when pushing batches" do
    stub_request(:post, "https://api.getconnect.io/events").
      with(:body => @sample_batch_data).
      to_return(:status => 200, :body => @sample_events_reponse, :headers => { 'Content-Type'=>'application/json' })

    response = nil
    EM.synchrony do
      response = @async_endpoint.push_batch @sample_batch
      EM.stop
    end
    response.must_be_instance_of ConnectClient::EventPushResponse
  end
end