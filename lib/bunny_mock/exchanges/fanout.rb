module BunnyMock
  module Exchanges
    class Fanout < BunnyMock::Exchange

      #
      # API
      #

      ##
      # Deliver a message to all routes
      #
      # @param [Object] payload Message content
      # @param [Hash] opts Message properties
      # @param [String] key Routing key
      #
      # @api public
      #
      def deliver(payload, opts, _key)

        @routes.each_value do |destination|

          # send to all routes
          destination.publish payload, opts
        end
      end
    end
  end
end
