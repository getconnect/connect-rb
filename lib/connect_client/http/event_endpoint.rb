require 'json'
require_relative '../event_push_response'

module ConnectClient
  module Http
    class EventEndpoint
      def initialize(config)
        headers = {
          "Content-Type" => "application/json", 
          "Accept" => "application/json",
          "Accept-Encoding" => "identity",
          "X-Api-Key" => config.api_key,
          "X-Project-Id" => config.project_id
        }

        if config.async
          @http = Async.new config.base_url, headers
        else
          @http = Sync.new config.base_url, headers
        end

      end

      def push(collection_name, event)
        path_uri_part = "/events/#{collection_name}"

        @http.send path_uri_part, event.data.to_json, event
      end

      def push_batch(events_by_collection)
        path_uri_part = "/events"

        @http.send path_uri_part, events_by_collection.to_json, events_by_collection
      end
    end

    private 

    class Sync
      def initialize(base_url, headers)
        require 'uri'
        require 'net/http'
        require 'net/https'
        
        @headers = headers
        @connect_uri = URI.parse(base_url)
        @http = Net::HTTP.new(@connect_uri.host, @connect_uri.port)
        setup_ssl if @connect_uri.scheme == 'https'
      end

      def send(path, body, events)
        response = @http.post(path, body, @headers)
        ConnectClient::EventPushResponse.new response.code, response['Content-Type'], response.body, events
      end

      private

      def setup_ssl
        @http.use_ssl = true
        @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        @http.verify_depth = 5
        @http.ca_file = File.expand_path("../../../../data/cacert.pem", __FILE__)        
      end
    end

    class Async

      def initialize(base_url, headers)
        require 'em-http-request'

        @headers = headers
        @base_url = base_url.chomp('/')
      end

      def send(path, body, events)
        raise AsyncHttpError unless defined?(EventMachine) && EventMachine.reactor_running?

        use_syncrony = defined?(EM::Synchrony)

        if use_syncrony
          send_using_synchrony(path, body, events)
        else
          send_using_deferred(path, body, events)
        end
      end

      def send_using_deferred(path, body, events)
        deferred = DeferredHttpResponse.new
        url_string = "#{@base_url}#{path}".chomp('/')
        http = EventMachine::HttpRequest.new(url_string).post(:body => body, :head => @headers)
        http_callback = Proc.new do
          begin
            response = create_response http, events
            deferred.succeed response
          rescue => error
            deferred.fail error
          end
        end

        http.callback &http_callback
        http.errback &http_callback

        deferred
      end

      def send_using_synchrony(path, body, events)
        url_string = "#{@base_url}#{path}".chomp('/')
        http = EventMachine::HttpRequest.new(url_string).
                post(:body => body, :head => @headers)

        create_response http, events
      end

      def create_response(http_reponse, events)
        status = http_reponse.response_header.status
        content_type = http_reponse.response_header['Content-Type']
        if (http_reponse.error.to_s.empty?)
          ConnectClient::EventPushResponse.new status, content_type, http_reponse.response, events
        else
          ConnectClient::EventPushResponse.new status, content_type, http_reponse.error, events
        end
      end
    end

    class DeferredHttpResponse
      if defined?(EventMachine::Deferrable)
        include EventMachine::Deferrable
        alias_method :response_received, :callback
        alias_method :error_occured, :errback
      end
    end

    class AsyncHttpError < StandardError
      def message
        "An EventMachine loop must be running to send an async http request via 'em-http-request'"
      end
    end
  end
end