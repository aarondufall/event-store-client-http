# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'event_store-client-http'
  s.version = '0.1.7'
  s.summary = 'HTTP Client for EventStore'
  s.description = ' '

  s.authors = ['Obsidian Software, Inc']
  s.email = 'opensource@obsidianexchange.com'
  s.homepage = 'https://github.com/obsidian-btc/error_data'
  s.licenses = ['MIT']

  s.require_paths = ['lib']
  s.files = Dir.glob('{lib}/**/*')
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.2.3'

  s.add_runtime_dependency 'casing', '~> 0'
  s.add_runtime_dependency 'clock', '~> 0'
  s.add_runtime_dependency 'connection', '~> 0'
  s.add_runtime_dependency 'controls', '~> 0'
  s.add_runtime_dependency 'dependency', '~> 0'
  s.add_runtime_dependency 'event_store-client', '~> 0'
  s.add_runtime_dependency 'http-protocol', '~> 0'
  s.add_runtime_dependency 'identifier-uuid', '~> 0'
  s.add_runtime_dependency 'settings', '~> 0'
  s.add_runtime_dependency 'schema', '~> 0'
  s.add_runtime_dependency 'telemetry-logger', '~> 0'

  s.add_development_dependency 'minitest', '~> 1'
  s.add_development_dependency 'minitest-spec-context', '~> 0'
  s.add_development_dependency 'pry', '~> 0'
  s.add_development_dependency 'runner', '~> 0'
end
