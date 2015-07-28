module EventStore
  module Client
    module HTTP
      class EventReader
        attr_reader :stream_name

        dependency :request, EventStore::Client::HTTP::Request::Get
        dependency :logger, Telemetry::Logger

        def starting_position
          @starting_position ||= 0
        end

        def slice_size
          @slice_size ||= 20
        end

        def initialize(stream_name, starting_position=nil, slice_size=nil)
          @stream_name = stream_name
          @starting_position = starting_position
          @slice_size = slice_size
        end

        def self.build(stream_name, starting_position: nil, slice_size: nil)
          logger.trace "Building event reader"

          new(stream_name, starting_position, slice_size).tap do |instance|
            EventStore::Client::HTTP::Request::Get.configure instance
            Telemetry::Logger.configure instance
            logger.debug "Built event reader"
          end
        end

        def subscribe(&action)
          stream_reader = StreamReader::Continuous.build stream_name, starting_position: starting_position, slice_size: slice_size

          stream_reader.each do |slice|
            read_slice(slice, &action)
          end
        end

        def each(&action)
          stream_reader.each do |slice|
            read_slice(slice, &action)
          end
        end

        def read_slice(slice, &action)
          slice.each do |event_json_data|
            entry = get_entry(event_json_data)
            action.call entry
          end
        end

        def get_entry(event_json_data)
          json_text = get_json_text(event_json_data)
          parse_entry(json_text)
        end

        def get_json_text(event_json_data)
          uri = entry_link(event_json_data)
          body_text, _ = request.! uri
          body_text
        end

        def parse_entry(json_text)
          EventData::Read.parse json_text
        end

        def entry_link(event_json_data)
          event_json_data['links'].map do |link|
            link['uri'] if link['relation'] == 'edit'
          end.compact.first
        end

        def deserialize_entry(event_json_data)
          event_json_data
        end

        def self.logger
          Telemetry::Logger.get self
        end
      end
    end
  end
end