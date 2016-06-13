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
        @routes[key].each { |route| route.publish payload, opts } if @routes[key]
      end
    end
  end
end
