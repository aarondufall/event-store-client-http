module EventStore
  module Client
    module HTTP
      module Request
        class Post
          class ExpectedVersionError < RuntimeError; end
          class Error < RuntimeError; end

          include Request

          dependency :post, ::HTTP::Commands::Post

          def configure_dependencies
            ::HTTP::Commands::Post.configure self, connection: session.connection
          end

          def call(data, uri, expected_version: nil)
            logger.opt_trace "Issuing POST (Path: #{uri}, Expected Version: #{expected_version.inspect})"
            logger.opt_data data

            uri = session.build_uri(uri)

            headers = self.headers(expected_version)

            response = Retry.(session.connection) do
              post.(data, uri, headers)
            end

            if response.status_code == 400 && response.reason_phrase == 'Wrong expected EventNumber'
              error_message = "Wrong expected version number: #{expected_version} (URI: #{uri})"
              logger.error error_message
              raise ExpectedVersionError, error_message
            end

            if response.status_code != 201
              error_message = "Post command failed (Status Code: #{response.status_code}, Reason Phrase: #{response.reason_phrase})"
              logger.error error_message
              raise Error, error_message
            end

            logger.opt_debug "Issued POST (Path: #{uri}, Status Line: #{response.status_line.inspect})"

            response
          end
          alias :! :call # TODO: Remove deprecated actuator [Kelsey, Thu Oct 08 2015]

          def headers(expected_version=nil)
            headers = {}
            set_event_store_content_type_header(headers)
            unless expected_version.nil?
              expected_version = -1 if expected_version == self.class.no_stream_version
              set_expected_version_header(headers, expected_version)
            end
            headers
          end

          def self.no_stream_version
            :no_stream
          end

          def media_type
            'application/vnd.eventstore.events+json'
          end

          def set_event_store_content_type_header(request)
            request['Content-Type'] = media_type
          end

          def set_expected_version_header(request, expected_version)
            request['ES-ExpectedVersion'] = expected_version
          end
        end
      end
    end
  end
end
