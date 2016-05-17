# frozen_string_literal: true
require 'bunny_mock/version'

require 'bunny/exceptions'
require 'amq/protocol/client'

require 'bunny_mock/get_response'
require 'bunny_mock/message_properties'

require 'bunny_mock/session'
require 'bunny_mock/channel'
require 'bunny_mock/exchange'
require 'bunny_mock/queue'

require 'bunny_mock/exchanges/direct'
require 'bunny_mock/exchanges/topic'
require 'bunny_mock/exchanges/fanout'
require 'bunny_mock/exchanges/headers'

##
# A mock RabbitMQ client based on Bunny
#
# @see https://github.com/ruby-amq/bunny
#
module BunnyMock
  # AMQP protocol version
  PROTOCOL_VERSION = AMQ::Protocol::PROTOCOL_VERSION

  class << self
    attr_writer :use_bunny_queue_pop_api

    #
    # API
    #

    ##
    # Instantiate a new mock Bunny session
    #
    # @return [BunnyMock::Session] Session instance
    # @api public
    def new(*)
      # return new mock session
      BunnyMock::Session.new
    end

    # @return [Boolean] Use Bunny API for Queue#pop (default: false)
    def use_bunny_queue_pop_api
      @use_bunny_queue_pop_api.nil? ? false : @use_bunny_queue_pop_api
    end

    # @return [String] Bunny mock version
    def version
      VERSION
    end

    # @return [String] AMQP protocol version
    def protocol_version
      AMQ::Protocol::PROTOCOL_VERSION
    end
  end
end
