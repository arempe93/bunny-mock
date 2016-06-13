# frozen_string_literal: true
module BunnyMock
  module Exchanges
    class Header < BunnyMock::Exchange
      # @private
      # @return [Regexp] Any match
      ANY = /^any$/i

      # @private
      # @return [Regexp] All match
      ALL = /^all$/i

      #
      # API
      #

      ##
      # Deliver a message to routes with header matches
      #
      # @param [Object] payload Message content
      # @param [Hash] opts Message properties
      # @param [String] key Routing key
      #
      # @api public
      #
      def deliver(payload, opts, key)
        # ~: proper headers exchange implementation
        @routes[key].each { |route| route.publish payload, opts } if @routes[key]
      end
    end
  end
end
