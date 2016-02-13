require 'bunny_mock/version'
require 'amq/protocol/client'

require 'bunny_mock/exceptions'

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

  #
  # API
  #

  ##
  # Instantiate a new mock Bunny session
  #
  # @return [BunnyMock::Session] Session instance
  # @api public
  def self.new(*args)

    # return new mock session
    BunnyMock::Session.new
  end

  # @return [String] Bunny mock version
  def self.version
    VERSION
  end

  # @return [String] AMQP protocol version
  def self.protocol_version
    AMQ::Protocol::PROTOCOL_VERSION
  end
end
