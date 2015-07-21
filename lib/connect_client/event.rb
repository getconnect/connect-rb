require 'securerandom'
require 'json'
require 'time'

module ConnectClient
  class Event

    @@RESERVED_PROPERTY_REGEX = /tp_.+/i

    attr_reader :data

    def initialize(data)
      event_data_defaults = { id: SecureRandom.uuid, timestamp: Time.now }
      @data = map_iso_dates event_data_defaults.merge(data)
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

    private

    def map_iso_dates(data)
      utc_converter = lambda { |value|
        value_to_convert = value
        map_utc = lambda { |value_item| utc_converter.call(value_item) }

        return value_to_convert.map(&map_utc)  if value_to_convert.respond_to? :map

        value_to_convert = value_to_convert.to_time if value_to_convert.respond_to? :to_time
        value_to_convert = value_to_convert.utc if value_to_convert.respond_to? :utc
        value_to_convert = value_to_convert.iso8601 if value_to_convert.respond_to? :iso8601

        value_to_convert
      }

      mappedData = data.map do |key, value|
        if value.is_a? Hash
          [key, map_iso_dates(value)]
        else
          [key, utc_converter.call(value)]
        end
      end

      Hash[mappedData]
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