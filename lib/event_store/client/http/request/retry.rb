module EventStore
  module Client
    module HTTP
      module Request
        module Retry
          def self.call(connection, max_retries=nil, &blk)
            max_retries ||= self.max_retries

            blk.()

          rescue Errno::EPIPE, Errno::ECONNRESET => error

            retries ||= 0
            retries += 1

            if retries == max_retries
              logger.error "Connection failure (Error: #{error.class.name}, Retries: #{retries}/#{max_retries})"
              raise error
            end

            logger.warn "Connection failure; retrying (Error: #{error.class.name}, Retries: #{retries}/#{max_retries})"
            connection.close
            retry
          end

          def self.logger
            @logger ||= Telemetry::Logger.get self
          end

          def self.max_retries
            3
          end
        end
      end
    end
  end
end
