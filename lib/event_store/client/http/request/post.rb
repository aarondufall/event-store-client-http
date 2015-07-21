module EventStore
  module Client
    module HTTP
      module Request
        class Post
          dependency :logger, Telemetry::Logger
          dependency :client, Net::HTTP

          def initialize(client)
            @client = client
          end

          def self.build(client=nil)
            new(client).tap do |instance|
              Telemetry::Logger.configure instance
              instance.configure_client(client)
            end
          end

          def configure_client(client=nil)
            if client.nil?
              ClientBuilder.configure_client self
            else
              self.client = client
            end
          end

          def !(data, path, expected_version: nil)
            logger.debug "Posting to #{path}"
            logger.data data

            response = post(data, path)

            logger.debug "POST Response\nPath: #{path}\nStatus: #{(response.code + " " + response.message).rstrip}"

            response
          end

          def post(data, path)
            request = build_request(data, path)
            client.request(request)
          end

          def build_request(data, path, expected_version=nil)
            request = Net::HTTP::Post.new(path)

            set_event_store_content_type(request)
            set_expected_version(request, expected_version) if expected_version

            request.body = data

            request
          end

          def media_type
            'application/vnd.eventstore.events+json'
          end

          def set_event_store_content_type(request)
            request['Content-Type'] = media_type
          end

          def set_expected_version(request, expected_version)
            request['ES-ExpectedVersion'] = expected_version
          end
        end
      end
    end
  end
end
