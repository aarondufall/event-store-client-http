module EventStore
  module Client
    module HTTP
      module Controls
        module EventData
          module Batch
            def self.example(id=nil, metadata: nil)
              id ||= ::Controls::ID.get

              batch = EventStore::Client::HTTP::EventData::Batch.build
              batch.add EventData::Write.example(id, metadata: metadata)
              batch
            end

            module JSON
              def self.text
                batch = Batch.example
                Serialize::Write.(batch, :json)
              end
            end
          end
        end
      end
    end
  end
end
