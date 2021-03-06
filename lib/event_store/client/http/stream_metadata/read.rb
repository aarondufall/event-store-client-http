module EventStore
  module Client
    module HTTP
      module StreamMetadata
        class Read
          attr_reader :stream_name

          dependency :logger, Telemetry::Logger
          dependency :session, Session

          def initialize(stream_name)
            @stream_name = stream_name
          end

          def self.build(stream_name, session: nil)
            instance = new stream_name

            Session.configure instance, session: session
            Telemetry::Logger.configure instance

            instance
          end

          def self.call(stream_name, session: nil)
            instance = build stream_name, session: session
            instance.()
          end

          def self.configure(receiver, stream_name, attr_name: nil, session: nil)
            attr_name ||= :read_stream_metadata

            instance = build stream_name, session: session
            receiver.public_send "#{attr_name}=", instance
            instance
          end

          def call
            logger.opt_trace "Retrieving stream metadata (URI: #{uri.to_s.inspect})"

            if uri.nil?
              logger.opt_debug "No stream metadata; stream does not exist (URI: #{uri.to_s.inspect})"
              return nil
            end

            response = Request::Retry.(session.connection) do
              ::HTTP::Commands::Get.(uri, headers, connection: session.connection)
            end

            logger.opt_debug "Retrieved stream metadata (URI: #{uri.to_s.inspect}, Content Length: #{response['Content-Length']})"

            event_data = Serialize::Read.(response.body, EventData::Read, :json)
            metadata = event_data.data

            return {} if metadata.nil?

            logger.opt_data JSON.pretty_generate(metadata)

            metadata
          end

          def headers
            {
              'Accept' => media_type
            }
          end

          def media_type
            'application/vnd.eventstore.atom+json'
          end

          def uri
            @uri ||= URI::Get.(stream_name, session: session)
          end

          module EventData
            class Read < EventStore::Client::HTTP::EventData::Read
              def self.parse(json_text)
                event_data = JSON.parse(json_text, :symbolize_names => true)

                return build(data: {}) if event_data.empty?

                data = deserialize event_data
                build data
              end
            end
          end
        end
      end
    end
  end
end
