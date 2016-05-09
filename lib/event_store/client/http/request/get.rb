module EventStore
  module Client
    module HTTP
      module Request
        class Get
          include Request

          attr_accessor :long_poll

          def call(uri)
            logger.opt_trace "Issuing GET (URI: #{uri})"

            uri = session.build_uri(uri)

            response = Retry.(session.connection) do
              ::HTTP::Commands::Get.(uri, headers, connection: session.connection)
            end

            body = response.body

            logger.opt_debug "Received GET (URI: #{uri})"
            logger.opt_data "Response body (Length: #{body.to_s.length}):\n#{body}"

            return body, response
          end
          alias :! :call # TODO: Remove deprecated actuator [Kelsey, Thu Oct 08 2015]

          def headers
            headers = {}
            set_event_store_accept_header headers
            set_event_store_long_poll_header headers if long_poll
            headers
          end

          def media_type
            'application/vnd.eventstore.atom+json'
          end

          def set_event_store_accept_header(request)
            request['Accept'] = media_type
          end

          def set_event_store_long_poll_header(request)
            request['ES-LongPoll'] = Defaults.long_poll_duration
          end

          def enable_long_poll
            self.long_poll = true
          end

          module Defaults
            def self.long_poll_duration
              duration = ENV['LONG_POLL_DURATION']
              duration || 15
            end
          end
        end
      end
    end
  end
end
