require 'json'
require 'cgi'
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
          @http = EmHttp.new config.base_url, headers
        else
          @http = NetHttp.new config.base_url, headers
        end

      end

      def push(collection_name, event)
        path_uri_part = "/events/#{CGI.escape(collection_name.to_s)}"

        @http.push_events path_uri_part, event.data.to_json, event
      end

      def push_batch(events_by_collection)
        path_uri_part = "/events"

        @http.push_events path_uri_part, events_by_collection.to_json, events_by_collection
      end
    end

    private 

    class NetHttp
      def initialize(base_url, headers)
        require 'uri'
        require 'net/http'
        require 'net/https'
        
        @headers = headers
        @connect_uri = URI.parse(base_url)
        @http = Net::HTTP.new(@connect_uri.host, @connect_uri.port)
        setup_ssl if @connect_uri.scheme == 'https'
      end

      def push_events(path, body, events)
        response = @http.post(path, body, @headers)
        ConnectClient::EventPushResponse.new response.code, response['Content-Type'], response.body, events
      end

      private

      def setup_ssl
        root_ca = "#{ConnectClient::gem_root}/data/cacert.pem"
        standard_depth = 5

        @http.use_ssl = true
        @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        @http.verify_depth = standard_depth
        @http.ca_file = root_ca
      end
    end

    class EmHttp

      def initialize(base_url, headers)
        require 'em-http-request'
        require_relative 'deferred_http_response'

        @headers = headers
        @base_url = base_url.chomp('/')
      end

      def push_events(path, body, events)
        raise AsyncHttpError unless defined?(EventMachine) && EventMachine.reactor_running?          

        use_syncrony = defined?(EM::Synchrony)

        if use_syncrony
          push_events_using_synchrony(path, body, events)
        else
          push_events_using_deferred(path, body, events)
        end
      end

      def push_events_using_deferred(path, body, events)
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

      def push_events_using_synchrony(path, body, events)
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

    class AsyncHttpError < StandardError
      def message
        "You have tried to push events asynchronously without an event machine event loop running. The easiest way to do this is by passing a block to EM.run"
      end
    end
  end
end