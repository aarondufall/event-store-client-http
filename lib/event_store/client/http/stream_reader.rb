 module EventStore
  module Client
    module HTTP
      class StreamReader
        attr_reader :start_path
        attr_accessor :next_uri

        dependency :request, EventStore::Client::HTTP::Request::Get
        dependency :logger, Telemetry::Logger

        def initialize(start_path)
          @start_path = start_path
        end

        def self.build(stream_name, starting_position: nil, slice_size: nil, direction: nil, session: nil)
          slice_size ||= Defaults.starting_position
          direction ||= Defaults.direction
          starting_position ||= Defaults.starting_position(direction)

          logger.trace "Building slice reader (Stream Name: #{stream_name}, Starting Position: #{starting_position}, Slice Size: #{slice_size})"

          start_path = slice_path(stream_name, starting_position, slice_size, direction)
          logger.debug "Starting URI: #{start_path}"

          new(start_path).tap do |instance|
            EventStore::Client::HTTP::Request::Get.configure instance, session: session

            Telemetry::Logger.configure instance
            logger.debug "Built slice reader (Stream Name: #{stream_name}, Position: #{starting_position}, Slice Size: #{slice_size})"
          end
        end

        def self.configure(receiver, stream_name, starting_position: nil, slice_size: nil, direction: nil, session: nil)
          instance = build stream_name, starting_position: starting_position, slice_size: slice_size, direction: direction, session: session
          receiver.stream_reader = instance
          instance
        end

        virtual :each

        ## TODO remove, defined later in class
        def advance_uri(next_uri)
          self.next_uri = (next_uri || self.next_uri)
        end

        def to_enum
          Enumerator.new do |y|
            self.next_uri = start_path
            logger.trace "Enumerating"

            loop do
              slice = next_slice(next_uri)

              raise StopIteration if slice.nil?

              next_uri = slice.links.next_uri
              y << [slice, next_uri]
            end

            logger.debug "Enumerated"
          end
        end
        alias :enum_for :to_enum
        alias :enumerator :to_enum

        def advance_uri(uri)
          self.next_uri = uri
          logger.debug "Next URI: #{next_uri}"
        end

        def get_slice(uri)
          logger.trace "Getting (URI: #{uri})"
          body, _ = request.(uri)

          logger.data "(#{body.class}) #{body}"

          parse(body).tap do
            logger.trace "Got (URI: #{uri})"
          end
        end
        alias :next_slice :get_slice

        def parse(body)
          slice = nil
          unless blank? body
            slice = Slice.parse(body)
          end
          slice
        end

        def blank?(body)
          body.nil? || body.empty?
        end

        def self.slice_path(stream_name, starting_position, slice_size, direction)
          "/streams/#{stream_name}/#{starting_position}/#{direction}/#{slice_size}"
        end

        def self.logger
          Telemetry::Logger.get self
        end

        module Defaults
          def self.starting_position(direction=nil)
            direction ||= self.direction

            if direction == :forward
              return 0
            else
              return 'head'
            end
          end

          def self.slice_size
            20
          end

          def self.direction
            :forward
          end
        end
      end
    end
  end
end
