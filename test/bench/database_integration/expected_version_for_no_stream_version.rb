require_relative '../bench_init'

context "The :no_stream Expected Version Number" do
  context "Events have not yet been written to the stream" do
    stream_name = EventStore::Client::HTTP::Controls::StreamName.get 'testNoStreamVersionNoEvents'

    writer = EventStore::Client::HTTP::EventWriter.build

    event_data = EventStore::Client::HTTP::Controls::EventData::Write.example

    test "Succeeds" do
      writer.write event_data, stream_name, expected_version: -1
    end
  end

  context "Events have already been written to the stream" do
    stream_name = EventStore::Client::HTTP::Controls::StreamName.get 'testNoStreamVersionWithEvents'

    writer = EventStore::Client::HTTP::EventWriter.build

    event_data_1 = EventStore::Client::HTTP::Controls::EventData::Write.example i: 1, type: 'FirstEvent'
    writer.write event_data_1, stream_name

    event_data_2 = EventStore::Client::HTTP::Controls::EventData::Write.example i: 2, type: 'SecondEvent'

    test "Is an error" do
      begin
        writer.write event_data_2, stream_name, expected_version: -1
      rescue EventStore::Client::HTTP::Request::Post::ExpectedVersionError => error
      end

      assert error
    end
  end
end
