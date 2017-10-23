module BunnyMock
  module Exchanges
    class Default < BunnyMock::Exchange

      #
      # API
      #

      ##
      # Deliver a message to route with direct key match
      #
      # @param [Object] payload Message content
      # @param [Hash] opts Message properties
      # @param [String] key Routing key
      #
      # @api public
      #
      def deliver(payload, opts, key)
        @routes[key].each { |route| route.publish payload, opts } if @routes[key]
      end

      def publish(payload, opts = {})
        if routing_key = opts[:routing_key]
          if queue = @channel.connection.queues[routing_key]
            queue.bind(self)
          end
        end
        super
      end

    end
  end
end
