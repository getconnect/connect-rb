require 'securerandom'
require 'json'
require 'time'

module ConnectClient
  class Event

    @@RESERVED_PROPERTY_REGEX = /tp_.+/i

    attr_reader :data

    def initialize(data)
      event_data_defaults = { id: SecureRandom.uuid, timestamp: Time.now.utc.iso8601 }
      @data = event_data_defaults.merge(data)

      if (@data[:timestamp].respond_to? :iso8601)
        @data[:timestamp] = @data[:timestamp].iso8601
      end

      validate
    end

    def validate
      invalid_properties = @data.keys.grep(@@RESERVED_PROPERTY_REGEX)

      raise EventDataValidationError.new(invalid_properties) if invalid_properties.any?
    end

    def to_json(options = nil)
      @data.to_json
    end

    def to_s
      "Event Data: #{@data}"
    end
  end

  class EventDataValidationError < StandardError
    attr_reader :invalid_property_names

    def initialize(invalid_property_names)
      @invalid_property_names = invalid_property_names
    end

    def message
      messages = ['The following properties use the reserved prefix tp_:'] + @invalid_property_names.map do |property_name|
        "->#{property_name}"
      end
      messages.join "\n"
    end
  end
end