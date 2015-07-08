require 'minitest/spec'
require 'minitest/autorun'
require 'webmock/minitest'
require 'connect_client/http/event_endpoint'
require 'connect_client/event_push_response'
require 'connect_client/event'
require 'connect_client/configuration'
require 'securerandom'

describe ConnectClient::Http::EventEndpoint do
  before do  
    @endpoint = ConnectClient::Http::EventEndpoint.new (ConnectClient::Configuration.new)
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
      with(:body => @sample_event_data, :headers => { 'Accept' => 'application/json' }).
      to_return(:status => 200, :body => "", :headers => { 'Content-Type'=>'application/json' })

    response = @endpoint.push @sample_collection, @sample_event

    response.must_be_instance_of ConnectClient::EventPushResponse
  end  

  it "should get push to overriden base_url" do
    overriden_url_config = ConnectClient::Configuration.new '', '', false, 'https://whatever.test'
    endpoint = ConnectClient::Http::EventEndpoint.new overriden_url_config
    stub_request(:post, "https://whatever.test/events/#{@sample_collection}").
      with(:body => @sample_event_data, :headers => { 'Accept' => 'application/json' }).
      to_return(:status => 200, :body => "", :headers => { 'Content-Type'=>'application/json' })

    response = endpoint.push @sample_collection, @sample_event

    response.must_be_instance_of ConnectClient::EventPushResponse
  end

  it "should get push response for a non sucessful error code" do
    overriden_url_config = ConnectClient::Configuration.new '', '', false, 'https://whatever.test'
    endpoint = ConnectClient::Http::EventEndpoint.new overriden_url_config
    stub_request(:post, "https://whatever.test/events/#{@sample_collection}").
      with(:body => @sample_event_data, :headers => { 'Accept' => 'application/json' }).
      to_return(:status => 500, :body => "", :headers => { 'Content-Type'=>'application/json' })

    response = endpoint.push @sample_collection, @sample_event

    response.http_status_code.to_s.must_equal '500'
  end

  it "should get a push response back when pushing batches" do
    stub_request(:post, "https://api.getconnect.io/events").
      with(:body => @sample_batch_data, :headers => { 'Accept' => 'application/json' }).
      to_return(:status => 200, :body => @sample_events_reponse, :headers => { 'Content-Type'=>'application/json' })

    response = @endpoint.push_batch @sample_batch
    response.must_be_instance_of ConnectClient::EventPushResponse
  end

  it "should get a push response back when pushing a single event to a collection async" do
    stub_request(:post, "https://api.getconnect.io/events/#{@sample_collection}").
      with(:body => @sample_event_data, :headers => { 'Accept' => 'application/json' }).
      to_return(:status => 200, :body => "", :headers => { 'Content-Type'=>'application/json' })

    EM.run do
      @async_endpoint.push(@sample_collection, @sample_event).response_received { |response|
        begin
          response.must_be_instance_of ConnectClient::EventPushResponse
        ensure
          EM.stop
        end
      }.error_occured { |error|
        EM.stop
        raise error
      }
    end
  end

  it "should get push response for a non sucessful error code async" do
    stub_request(:post, "https://api.getconnect.io/events/#{@sample_collection}").
      with(:body => @sample_event_data, :headers => { 'Accept' => 'application/json' }).
      to_return(:status => 500, :body => "", :headers => { 'Content-Type'=>'application/json' })

    EM.run do
      @async_endpoint.push(@sample_collection, @sample_event).response_received { |response|
        begin
          response.http_status_code.to_s.must_equal '500'
        ensure
          EM.stop
        end
      }.error_occured { |error|
        EM.stop
        raise error
      }
    end
  end

  it "should get a push response back when pushing batches" do
    stub_request(:post, "https://api.getconnect.io/events").
      with(:body => @sample_batch_data, :headers => { 'Accept' => 'application/json' }).
      to_return(:status => 200, :body => @sample_events_reponse, :headers => { 'Content-Type'=>'application/json' })

    EM.run do
      @async_endpoint.push_batch(@sample_batch).response_received { |response|
        begin
          response.must_be_instance_of ConnectClient::EventPushResponse
        ensure
          EM.stop
        end
      }.error_occured { |error|
        EM.stop
        raise error
      }
    end
  end

  it "should throw an async exception if EM is not running" do
    proc { @async_endpoint.push_batch(@sample_batch) }.must_raise ConnectClient::Http::AsyncHttpError
  end  
end