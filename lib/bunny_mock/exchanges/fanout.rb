# frozen_string_literal: true
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
      def deliver(payload, opts, key)
        if @routes.values.flatten.any?
          @routes.values.flatten.each { |destination| destination.publish(payload, opts) }
        elsif opts.fetch(:mandatory, false)
          handle_return({ exchange: name, routing_key: key }, opts, payload)
        end
      end
    end
  end
end
