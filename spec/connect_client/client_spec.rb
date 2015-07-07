require 'minitest/spec'
require 'minitest/autorun'
require 'webmock/minitest'
require 'connect_client/client'
require 'connect_client/event_push_response'
require 'connect_client/configuration'
require 'securerandom'

describe ConnectClient::Client do
  before do  
    @client = ConnectClient::Client.new (ConnectClient::Configuration.new)
    @async_client = ConnectClient::Client.new (ConnectClient::Configuration.new '', '', true)
    @sample_event = { id: SecureRandom.uuid, timestamp: Time.now.utc.iso8601, name: 'sample' }
    @sample_events = [@sample_event]
    @sample_events_reponse = '{"sample": [{"success": true}]}'
    @sample_collection = 'sample'
    @sample_collection_sym = :sample
  end

  it "should get a push response back when pushing a single event to a collection passed by string" do
    stub_request(:post, "https://api.getconnect.io/events/#{@sample_collection}").
      with(:body => @sample_event).
      to_return(:status => 200, :body => "", :headers => { 'Content-Type'=>'application/json' })

    response = @client.push @sample_collection, @sample_event

    response.must_be_instance_of ConnectClient::EventPushResponse
  end

  it "should get a push response back when pushing a single event to a collection passed by symbol" do
    stub_request(:post, "https://api.getconnect.io/events/#{@sample_collection}").
      with(:body => @sample_event).
      to_return(:status => 200, :body => "", :headers => { 'Content-Type'=>'application/json' })

    response = @client.push @sample_collection_sym, @sample_event

    response.must_be_instance_of ConnectClient::EventPushResponse
  end

  it "should get a push response back when pushing multiple events to a collection passed by string" do
    stub_request(:post, "https://api.getconnect.io/events").
      with(:body => { @sample_collection.to_sym => @sample_events }).
      to_return(:status => 200, :body => @sample_events_reponse, :headers => { 'Content-Type'=>'application/json' })

    response = @client.push @sample_collection, @sample_events

    response.must_be_instance_of ConnectClient::EventPushResponse
  end

  it "should get a push response back when pushing multiple events to a collection passed by symbol" do
    stub_request(:post, "https://api.getconnect.io/events").
      with(:body => { @sample_collection_sym => @sample_events }).
      to_return(:status => 200, :body => @sample_events_reponse, :headers => { 'Content-Type'=>'application/json' })

    response = @client.push @sample_collection_sym, @sample_events

    response.must_be_instance_of ConnectClient::EventPushResponse
  end

  it "should get a push response back when pushing batches" do
    batch = { @sample_collection.to_sym => @sample_events }
    stub_request(:post, "https://api.getconnect.io/events").
      with(:body => batch).
      to_return(:status => 200, :body => @sample_events_reponse, :headers => { 'Content-Type'=>'application/json' })

    response = @client.push batch
    response.must_be_instance_of ConnectClient::EventPushResponse
  end
end