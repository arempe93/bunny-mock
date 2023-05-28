# frozen_string_literal: true
module BunnyMock
  module Exchanges
    class Direct < BunnyMock::Exchange
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
        if @routes[key] && @routes[key].any?
          @routes[key].each { |route| route.publish payload, opts }
        elsif opts.fetch(:mandatory, false)
          handle_return({ exchange: name, routing_key: key }, opts, payload)
        end
      end
    end
  end
end
