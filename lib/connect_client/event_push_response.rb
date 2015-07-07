require 'json'

module ConnectClient
  class EventPushResponse
    attr_reader :data
    attr_reader :http_status_code

    def initialize(code, content_type, response_body, events_pushed)
      @http_status_code = code.to_s

      if content_type.include? 'application/json'
        body = response_body
        body = '{}' if response_body.to_s.empty?
        parse_body(body, events_pushed)
      else
        @data = response_body
      end
    end

    def success?
      @http_status_code.start_with? '2'
    end

    def to_s
      %{
        Status: #{@http_status_code}
        Successful: #{success?}
        Data: #{data}
      }
    end

    private

    def parse_body(body, events_pushed)
      @data = JSON.parse(body, :symbolize_names => true)

      if (events_pushed.is_a?(Hash) && @data.is_a?(Hash))
        @data.merge!(events_pushed) do |collection_name, responses, events|
          responses.zip(events).map do |response, event|
            response[:event] = event.data 
            response
          end
        end
      else
        @data[:event] = events_pushed.data
      end
    end
  end
end