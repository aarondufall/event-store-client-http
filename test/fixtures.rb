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

  # module ATOM
  #   module Document
  #     def self.data
  #       JSON.parse(text)
  #     end

  #     def self.text
  #       File.read(filepath)
  #     end

  #     def self.filepath
  #       pathname = Pathname.new __FILE__
  #       pathname = Pathname.new pathname.dirname
  #       pathname += 'data/someStream.json'
  #       pathname.to_s
  #     end
  #   end
  # end

  module Stream
    def self.name(category=nil, id=nil)
      category ||= 'test'
      id ||= UUID.random
      category_name = "#{category}#{UUID.random.gsub('-', '')}"
      "#{category_name}-#{id}"
    end

    module Slice
      def self.data
        JSON.parse(text)
      end

      def self.text
        File.read(filepath)
      end

      def self.filepath
        pathname = Pathname.new __FILE__
        pathname = Pathname.new pathname.dirname
        pathname += 'data/slice.json'
        pathname.to_s
      end
    end

    module Entry
      def self.data(i=nil)
        i ||= 1

        id = ID.get(i)

        {
          id: id,
          type: 'SomeEvent',
          number: 1,
          position: 11,
          stream_name: 'someStream',
          uri: 'http://127.0.0.1:2113/streams/someStream/1',
          created_time: '2015-06-08T04:37:01.066935Z',
          data: {
            'some_attribute' => 'some value',
            'some_time' => '2015-06-07T23:37:01Z'
          },
          metadata: {
            "some_meta_attribute" => "some meta value"
          }
        }
      end

      module JSON
        def self.data(i=nil)
          i ||= 1

          id = ID.get(i)

          {
            eventId: id,
            eventType: 'SomeEvent',
            eventNumber: 1,
            positionEventNumber: 11,
            streamId: 'someStream',
            id: 'http://127.0.0.1:2113/streams/someStream/1',
            updated: '2015-06-08T04:37:01.066935Z',
            data: {
              'someAttribute' => 'some value',
              'someTime' => '2015-06-07T23:37:01Z'
            },
            metaData: {
              "someMetaAttribute" => "some meta value"
            }
          }
        end

        def self.text
          data.to_json
        end

        def self.list(count=nil)
          count ||= 1

          list = []

          count.times do |i|
            i += 1
            entry = data(i)
            list << entry
          end

          list
        end

        module Raw
          def self.data
            ::JSON.parse(text)
          end

          def self.text
            File.read(filepath)
          end

          def self.list(count=nil)
            count ||= 1

            list = []

            count.times do |i|
              i += 1
              entry = data
              list << entry
            end

            list
          end

          def self.filepath
            pathname = Pathname.new __FILE__
            pathname = Pathname.new pathname.dirname
            pathname += 'data/entry.json'
            pathname.to_s
          end
        end
      end
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

    def self.json_text(time=nil)
      time ||= Time.now.iso8601(5)
      data_text = '"eventId":"10000000-0000-0000-0000-000000000000","eventType":"SomeEvent","data":{"someAttribute":"some value"}'
      "{#{data_text},#{Metadata.json_text}}"
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
