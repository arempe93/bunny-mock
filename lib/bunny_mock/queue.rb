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

		##
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
			@channel	= channel
			@name		= name
			@opts		= opts
		end

		##
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

			if exchange.respond_to?(:add_route)

				# we can do the binding ourselves
				exchange.add_route opts.fetch(:routing_key, @name), self

			else

				# we need the channel to lookup the exchange
				@channel.queue_bind self, opts.fetch(:routing_key, @name), exchange
			end
		end

		##
		# Unbind this queue from an exchange
		#
		# @param [BunnyMock::Exchange,String] exchange Exchange to unbind from
		# @param [Hash] opt Binding properties
		#
		# @option opts [String] :routing_key Custom routing key
		#
		# @api public
		#
		def unbind(exchange, opts = {})

			if exchange.respond_to?(:remove_route)

				# we can do the unbinding ourselves
				exchange.remove_route opts.fetch(:routing_key, @name)

			else

				# we need the channel to lookup the exchange
				@channel.queue_unbind opts.fetch(:routing_key, @name), exchange
			end
		end

		##
		# Check if this queue is bound to the exchange
		#
		# @param [BunnyMock::Exchange,String] exchange Exchange to test
		# @param [Hash] opts Binding properties
		#
		# @option opts [String] :routing_key Custom routing key
		#
		# @return [Boolean] true if this queue is bound to the given exchange, false otherwise
		# @api public
		#
		def bound_to?(exchange)

			if exchange.respond_to?(:has_binding?)

				# we can do the check ourselves
				exchange.has_binding? opts.fetch(:routing_key, @name)

			else

				# we need the channel to lookup the exchange
				@channel.xchg_has_binding? opts.fetch(:routing_key, @name), exchange
			end
		end

		# @group Messages API

		##
		# Count of messages in queue
		#
		# @return [Integer] Number of messages in queue
		# @api public
		#
		def count
			@messages.count
		end

		##
		# Get oldest message in queue
		#
		# @return [Hash] Message data
		# @api public
		#
		def pop
			@messages.pop
		end

		##
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
		def publish(payload, props = {})
			@messages << { message: payload, properties: props }
		end
	end
end
