require 'minitest/spec'
require 'minitest/autorun'
require 'connect_client/event'

describe ConnectClient::Event do
  it "should throw a validation exception if a property starts with tp_" do
    connect_event = proc { ConnectClient::Event.new({tp_foo: 'bar'}) }.must_raise ConnectClient::EventDataValidationError
  end
  
  it "should supply an id if none present" do
    connect_event = ConnectClient::Event.new({foo: 'bar'})
    uuid_regex = /[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}/

    connect_event.data[:id].must_match uuid_regex
  end

  it "should pass through id supplied" do
    connect_event = ConnectClient::Event.new({id: :bar})
    
    connect_event.data[:id].must_equal :bar
  end
  
  it "should supply timestamp if none present" do
    iso_date = '2015-07-01T04:07:57Z'
    a_time = Time.parse(iso_date);

    Time.stub :now, a_time do
      connect_event = ConnectClient::Event.new({foo: 'bar'})
      connect_event.data[:timestamp].must_equal iso_date
    end
  end

  it "should turn timestamp into iso string" do
    iso_date = '2015-07-01T04:07:57Z'
    a_time = Time.parse(iso_date);

    connect_event = ConnectClient::Event.new({foo: 'bar', timestamp: a_time})
    connect_event.data[:timestamp].must_equal iso_date
  end

  it "should pass through timestamp string if supplied" do
    iso_date = '2015-07-01T04:07:57Z'

    connect_event = ConnectClient::Event.new({foo: 'bar', timestamp: iso_date})
    connect_event.data[:timestamp].must_equal iso_date
  end

  it "should turn Time into iso8601" do
    iso_date = '2015-07-01T04:07:57Z'
    some_time = Time.parse('2015-07-01T05:07:57+01:00')

    nested_hash_values = {
      this: {
        is: {
          nested: [[some_time]]
        }
      }
    }

    connect_event = ConnectClient::Event.new(nested_hash_values)
    connect_event.data[:this][:is][:nested][0][0].must_equal iso_date
  end

  it "should turn DateTime into iso8601" do
    iso_date = '2015-07-01T04:07:57Z'
    some_date_time = DateTime.parse('2015-07-01T05:07:57+01:00')

    nested_hash_values = {
      this: {
        is: {
          nested: [[some_date_time]]
        }
      }
    }

    connect_event = ConnectClient::Event.new(nested_hash_values)
    connect_event.data[:this][:is][:nested][0][0].must_equal iso_date
  end

  it "should turn Date into iso8601" do
    some_date = Date.parse('2015-07-01')

    nested_hash_values = {
      this: {
        is: {
          nested: [[some_date]]
        }
      }
    }

    connect_event = ConnectClient::Event.new(nested_hash_values)
    connect_event.data[:this][:is][:nested][0][0].must_equal some_date.to_time.utc.iso8601
  end
end