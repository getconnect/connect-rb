module ConnectClient
  module Http
    class DeferredHttpResponse
      include EventMachine::Deferrable
      alias_method :response_received, :callback
      alias_method :error_occured, :errback
    end
  end
end