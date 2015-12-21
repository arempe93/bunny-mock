module BunnyMock
	class Queue

		#
		# API
		#

		# @return {BunnyMock::Channel} Channel used by queue
		attr_reader :channel

		# @return [String] Queue name
		attr_reader :name

		# @return [Hash] Creation options
		attr_reader :opts

		# Create a new [BunnyMock::Queue] instance
		#
		# @param [BunnyMock::Channel] channel Channel this queue will use
		# @param [String] name Name of queue
		# @param [Hash] opts Creation options
		#
		# @see BunnyMock::Channel#queue
		#
		def initialize(channel, name = AMQP::Protocol::EMPTY_STRING, opts = {})

			# Store creation information
			@channel = channel
			@name = name
			@opts = opts
		end


		# Bind this queue to an exchange
		#
		# @param [BunnyMock::Exchange,String] exchange Exchange to bind to
		# @param [Hash] opt Binding properties
		#
		# @option opts [String] :routing_key Custom routing key
		#
		# @api public
		#
		def bind(exchange, opts = {})

			xchg = exchange.respond_to?(:name) ? xchg.name : xchg

			@channel.queue_bind @name, xchg, opts
		end

		# Unbind this queue from an exchange
		#
		# @param [BunnyMock::Exchange,String] exchange Exchange to unbind from
		# @param [Hash] opt Binding properties (insignificant)
		#
		# @api public
		#
		def unbind(exchange, opts = {})

			xchg = exchange.respond_to?(:name) ? xchg.name : xchg

			@channel.queue_unbind @name, xchg
		end

		# Check if this queue is bound to the exchange
		#
		# @param [BunnyMock::Exchange,String] exchange Exchange to test
		#
		# @return [Boolean] true if this queue is bound to the given exchange, false otherwise
		# @api public
		#
		def bound_to?(exchange)

			xchg = exchange.respond_to?(:name) ? xchg.name : xchg

			@channel.queue_bound_to? @name, xchg
		end

		# @group Messages API

		# Count of messages in queue
		#
		# @return [Integer] Number of messages in queue
		# @api public
		#
		def count
			@messages.count
		end

		# Get oldest message in queue
		#
		# @return [Hash] Message data
		# @api public
		#
		def pop
			@messages.pop
		end

		# Get all messages in queue
		#
		# @return [Array] All messages
		# @api public
		#
		def all
			@messages
		end

		# @endgroup

		#
		# Implementation
		#

		# @private
		def send(payload, props = {})
			@messages << { message: payload, properties: props }
		end
	end
end
