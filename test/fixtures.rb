require 'pathname'
require 'time'

module Fixtures
  module Time
    def self.reference
      Clock::UTC.iso8601(::Time.utc(2000))
    end
  end

  module ID
    def self.get(i=nil)
      i ||= 1

      first_octet = (i).to_s.rjust(8, '0')

      "#{first_octet}-0000-0000-0000-000000000000"
    end
  end

  module Stream
    def self.name(category=nil, id=nil)
      category ||= 'test'
      id ||= UUID.random
      category_name = "#{category}#{UUID.random.gsub('-', '')}"
      "#{category_name}-#{id}"
    end
  end

  module EventData
    module Read
      module JSON
        def self.data(increment=nil, time=nil)
          increment ||= 0

          reference_time = Time.reference
          time ||= reference_time

          id = ID.get(increment + 1)

          {
            'updated' => reference_time,
            'content' => {
              'eventType' => 'SomeEvent',
              'eventNumber' => increment,
              'eventStreamId' => 'someStream',
              'data' => {
                'someAttribute' => 'some value',
                'someTime' => time
              },
              'metadata' => {
                'someMetaAttribute' => 'some meta value'
              }
            },
            'links' => [
              {
                'uri' => "http://localhost:2113/streams/someStream/#{increment}",
                'relation' => 'edit'
              }
            ]
          }
        end

        def self.text
          data.to_json
        end
      end
    end

    def self.example(id=nil)
      id ||= '10000000-0000-0000-0000-000000000000'

      event_data = EventStore::Client::HTTP::EventData::Write.build

      event_data.id = id

      event_data.type = 'SomeEvent'

      event_data.data = {
        'some_attribute' => 'some value'
      }

      event_data.metadata = Metadata.data

      event_data
    end

    def self.write(count=nil, stream_name=nil)
      count ||= 1

      stream_name = Fixtures::Stream.name stream_name
      path = "/streams/#{stream_name}"

      post = EventStore::Client::HTTP::Request::Post.build

      count.times do |i|
        i += 1

        id = ID.get(i)

        event_data = Fixtures::EventData::Batch.example(id)

        json_text = event_data.serialize

        post_response = post.! json_text, path
      end

      stream_name
    end

    module Batch
      def self.example(id=nil)
        id ||= '10000000-0000-0000-0000-000000000000'

        event_data = EventStore::Client::HTTP::EventData.build

        batch = EventStore::Client::HTTP::EventData::Batch.build
        batch.add EventData.example(id)
        batch
      end

      def self.json_text
        example.serialize
      end
    end
  end

  module Metadata
    def self.data
      {
        some_meta_attribute: 'some metadata value'
      }
    end

    def self.json_text
      '"metaData":{"someMetaAttribute":"some metadata value"}'
    end
  end
end
