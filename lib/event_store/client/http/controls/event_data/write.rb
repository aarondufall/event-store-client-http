module EventStore
  module Client
    module HTTP
      module Controls
        module EventData
          module Write
            def self.data(id=nil, metadata: nil)
              id ||= ::Controls::ID.get sample: false
              metadata = true if metadata.nil?

              data = {
                :event_id => id,
                :event_type => 'SomeType',
                :data => { :some_attribute => 'some value' },
              }

              if metadata
                data[:metadata] = EventData::Metadata.data
              end

              data
            end

            module JSON
              def self.data(id=nil)
                data = Write.data id

                Casing::Camel.(data, symbol_to_string: true)
              end

              def self.text
                data.to_json
              end
            end

            def self.example(id=nil, i: nil, metadata: nil, type: nil)
              id ||= ::Controls::ID.get i, sample: false
              metadata = true if metadata.nil?
              type ||= 'SomeType'

              event_data = EventStore::Client::HTTP::EventData::Write.build

              event_data.id = id

              event_data.type = type

              event_data.data = {
                :some_attribute => 'some value'
              }

              if metadata
                event_data.metadata = EventData::Metadata.data
              end

              event_data
            end
          end
        end
      end
    end
  end
end
