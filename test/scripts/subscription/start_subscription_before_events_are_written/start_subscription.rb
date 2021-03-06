ENV['LOG_LEVEL'] ||= 'debug'

require_relative '../../scripts_init'

stream_name = EventStore::Client::HTTP::Controls::StreamName.get "testSubscriptionFirst"
__logger.info "Stream name: #{stream_name}"

stream_name_file = 'tmp/stream_name'
File.write stream_name_file, stream_name

at_exit do
  File.unlink stream_name_file
end

event_reader = EventStore::Client::HTTP::Subscription.build stream_name

event_reader.each do |event|
  __logger.info event.inspect
end
