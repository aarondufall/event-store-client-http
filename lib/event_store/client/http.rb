require 'json'
require 'uri'

require 'casing'
require 'clock'
require 'dependency' ; Dependency.activate
require 'event_store/client'
require 'http/commands'
require 'identifier/uuid'
require 'schema'
require 'serialize'
require 'settings' ; Settings.activate
require 'telemetry/logger'

require 'event_store/client/http/settings'

require 'event_store/client/http/slice/entry'
require 'event_store/client/http/slice/links'
require 'event_store/client/http/slice'

require 'event_store/client/http/event_data'
require 'event_store/client/http/event_data/read'
require 'event_store/client/http/event_data/write'
require 'event_store/client/http/event_data/batch'

require 'event_store/client/http/session'
require 'event_store/client/http/request'
require 'event_store/client/http/request/post'
require 'event_store/client/http/request/get'
require 'event_store/client/http/request/retry'

require 'event_store/client/http/stream_reader'
require 'event_store/client/http/stream_reader/continuous'
require 'event_store/client/http/stream_reader/terminal'

require 'event_store/client/http/event_reader'

require 'event_store/client/http/reader'
require 'event_store/client/http/subscription'

require 'event_store/client/http/event_writer'

require 'event_store/client/http/stream_metadata/uri/get'
require 'event_store/client/http/stream_metadata/read'
require 'event_store/client/http/stream_metadata/update'
