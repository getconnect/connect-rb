require_relative 'http/event_endpoint'
require_relative 'event'

module ConnectClient
  class Client

    def initialize(config)
      @end_point = ConnectClient::Http::EventEndpoint.new config
    end

    def push(collection_name_or_batches, event_or_events = nil)
      has_multiple_events = event_or_events.is_a?(Array)
      has_collection_name = collection_name_or_batches.is_a?(String) || collection_name_or_batches.is_a?(Symbol)
      is_batch = !has_collection_name || has_multiple_events

      if is_batch
        batch = create_batch(has_collection_name, collection_name_or_batches, event_or_events)
        @end_point.push_batch batch
      else
        @end_point.push(collection_name_or_batches, ConnectClient::Event.new(event_or_events))
      end
    end

    private

    def create_batch(has_collection_name, collection_name_or_batches, event_or_events)

      batches = has_collection_name ?
                { collection_name_or_batches.to_sym => event_or_events } :
                collection_name_or_batches

      create_event = Proc.new do |event_data| 
          ConnectClient::Event.new event_data
      end

      map_all_events = Proc.new do |col_name, events| 
        [col_name, events.map(&create_event)]
      end

      Hash[batches.map(&map_all_events)]
    end
  end
end