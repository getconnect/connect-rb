require 'minitest/spec'
require 'minitest/autorun'
require 'connect_client/event'
require 'connect_client/event_push_response'


describe ConnectClient::EventPushResponse do
  before do
    @json_content_type = 'application/json; charset=utf-8'
    @sample_event = ConnectClient::Event.new({name: 'test'})
    @sample_event_data = @sample_event.data
  end

  it "should be successful when status code is 201" do
    
    body = ''
    code = 201
    
    event_response = ConnectClient::EventPushResponse.new code, @json_content_type, body, @sample_event

    event_response.success?.must_equal true
  end

  it "should pass through string body if content type is not json" do
    
    body = ''
    code = 500
    
    event_response = ConnectClient::EventPushResponse.new code, @json_content_type, body, @sample_event

    event_response.success?.must_equal false
  end

  it "should not be successful when status code is 500" do
    
    body = ''
    code = 500
    
    event_response = ConnectClient::EventPushResponse.new code, @json_content_type, body, @sample_event

    event_response.success?.must_equal false
  end

  it "should not parse body that is not json content" do
    
    content_type = 'text/html'
    body = '<html><html>'
    code = 500
    
    event_response = ConnectClient::EventPushResponse.new code, content_type, body, @sample_event

    event_response.data.must_equal body
  end

  it "should set status code even if body is not json content" do
    
    content_type = 'text/html'
    body = '<html><html>'
    code = 500
    
    event_response = ConnectClient::EventPushResponse.new code, content_type, body, @sample_event

    event_response.http_status_code.must_equal '500'
  end


  it "should pass through error message in data" do

    body = '{ "errorMessage": "something went wrong" }'
    code = 500
    
    event_response = ConnectClient::EventPushResponse.new code, @json_content_type, body, @sample_event

    event_response.data[:errorMessage].must_equal 'something went wrong'
  end

  it "should pass back event in response when successful" do
    
    body = ''
    code = 200
    
    event_response = ConnectClient::EventPushResponse.new code, @json_content_type, body, @sample_event

    event_response.data[:event].must_be_same_as  @sample_event_data
  end

  it "should pass through original event with error" do

    
    body = '{ "errorMessage": "something went wrong" }'
    code = 500

    event_response = ConnectClient::EventPushResponse.new code, @json_content_type, body, @sample_event

    event_response.data[:event].must_be_same_as  @sample_event_data
  end
  
  it "should pass through success status under collection name for batch" do

    
    body = %@
      {
        "collectionName": [{
          "success": true
        }]
      }
    @
    code = 200
  
    events = { :collectionName => [@sample_event] }
    event_response = ConnectClient::EventPushResponse.new code, @json_content_type, body, events

    event_response.data[:collectionName][0][:success].must_equal true
  end
  
  it "should pass through duplicate status under collection name for batch" do

    
    body = %@
      {
        "collectionName": [{
          "duplicate": true
        }]
      }
    @
    code = 200
  
    events = { :collectionName => [@sample_event] }
    event_response = ConnectClient::EventPushResponse.new code, @json_content_type, body, events

    event_response.data[:collectionName][0][:duplicate].must_equal true
  end
  
  it "should show event under collection name for batch" do
    
    body = %@
      {
        "collectionName": [{
          "success": true
        }]
      }
    @
    code = 200

    events = { :collectionName => [@sample_event] }
    event_response = ConnectClient::EventPushResponse.new code, @json_content_type, body, events

    event_response.data[:collectionName][0][:event].must_be_same_as @sample_event_data
  end  
end