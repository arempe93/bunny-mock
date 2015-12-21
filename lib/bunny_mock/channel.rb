module BunnyMock
	class Channel

		#
		# API
		#

		# @return [Integer] Channel identifier
		attr_reader :id

		# @return [BunnyMock::Session] Session this channel belongs to
		attr_reader :connection

		# @return [Symbol] Current channel state
		attr_reader :status

		# @return [Hash<String, BunnyMock::Exchange>] Exchanges created by this channel
		attr_reader :exchanges

		# @return [Hash<String, BunnyMock::Queue>] Queues created by this channel
		attr_reader :queues

		# Create a new {BunnyMock::Channel} instance
		#
		# @param [BunnyMock::Session] connection Mocked session instance
		# @param [Integer] id Channel identifier
		#
		# @api public
		def initialize(connection = nil, id = nil)

			# store channel id
			@id = id

			# store connection information
			@connection = connection

			# initialize exchange and queue storage
			@exchanges = Hash.new
			@queues = Hash.new

			# set status to opening
			@status = :opening
		end

		# Sets status to open
		#
		# @return [BunnyMock::Channel] self
		# @api public
		def open

			@status = :open

			self
		end

		# Sets status to closed
		#
		# @return [BunnyMock::Channel] self
		# @api public
		def close

			@status = :closed

			self
		end

		# @return [Boolean] true if status is open, false otherwise
		# @api public
		def open?
			@status == :open
		end

		# @return [Boolean] true if status is closed, false otherwise
		# @api public
		def closed?
			@status == :closed
		end

		# @return [String] object representation
		def to_s
			"#<#{self.class.name}:#{self.object_id} @id=#{@id} @open=#{open?}>"
		end
		alias inspect to_s

		# @group Exchange API

		# Mocks an exchange
		#
		# @param [String] name Exchange name
		# @param [Hash] opts Exchange parameters
		#
		# @option opts [Symbol,String] :type Type of exchange
		# @option opts [Boolean] :durable
		# @option opts [Boolean] :auto_delete
		# @option opts [Hash] :arguments
		#
		# @return [BunnyMock::Exchange] Mocked exchange instance
		# @api public
		def exchange(name, opts = {})

			xchg = find_exchange(name) || Exchange.new(self, opts.fetch(:type, :direct), name, opts)

			register_exchange xchg
		end

		# Mocks a fanout exchange
		#
		# @param [String] name Exchange name
		# @param [Hash] opts Exchange parameters
		#
		# @option opts [Boolean] :durable
		# @option opts [Boolean] :auto_delete
		# @option opts [Hash] :arguments
		#
		# @return [BunnyMock::Exchange] Mocked exchange instance
		# @api public
		def fanout(name, opts = {})
			self.exchange name, opts.merge(type: :fanout)
		end

		# Mocks a direct exchange
		#
		# @param [String] name Exchange name
		# @param [Hash] opts Exchange parameters
		#
		# @option opts [Boolean] :durable
		# @option opts [Boolean] :auto_delete
		# @option opts [Hash] :arguments
		#
		# @return [BunnyMock::Exchange] Mocked exchange instance
		# @api public
		def direct(name, opts = {})
			self.exchange name, opts.merge(type: :direct)
		end

		# Mocks a topic exchange
		#
		# @param [String] name Exchange name
		# @param [Hash] opts Exchange parameters
		#
		# @option opts [Boolean] :durable
		# @option opts [Boolean] :auto_delete
		# @option opts [Hash] :arguments
		#
		# @return [BunnyMock::Exchange] Mocked exchange instance
		# @api public
		def topic(name, opts = {})
			self.exchange name, opts.merge(type: :topic)
		end

		# Mocks a headers exchange
		#
		# @param [String] name Exchange name
		# @param [Hash] opts Exchange parameters
		#
		# @option opts [Boolean] :durable
		# @option opts [Boolean] :auto_delete
		# @option opts [Hash] :arguments
		#
		# @return [BunnyMock::Exchange] Mocked exchange instance
		# @api public
		def header(name, opts = {})
			self.exchange name, opts.merge(type: :header)
		end

		# Mocks RabbitMQ default exchange
		#
		# @return [BunnyMock::Exchange] Mocked default exchange instance
		# @api public
		def default_exchange
			self.direct AMQ::PROTOCOL::EMPTY_STRING, no_declare: true
		end

		# @endgroup

		# @group Queue API

		# Create a new {BunnyMock::Queue} instance, or find in channel cache
		#
		# @param [String] name Name of queue
		# @param [Hash] opts Queue creation options
		#
		# @return [BunnyMock::Queue] Queue that was mocked or looked up
		# @api public
		def queue(name = AMQP::Protocol::EMPTY_STRING, opts = {})

			queue = find_queue(name) || BunnyMock::Queue.new(self, name, opts)

			register_queue queue
		end

		# Create a new {BunnyMock::Queue} instance with no name
		#
		# @param [Hash] opts Queue creation options
		#
		# @return [BunnyMock::Queue] Queue that was mocked or looked up
		# @see #queue
		# @api public
		def temporary_queue(opts = {})

			queue '', opts.merge(exclusive: true)
		end

		# @endgroup

		#
		# Implementation
		#

		# @private
		def find_queue(name)
			@queues[name]
		end

		# @private
		def register_queue(queue)
			@queues[queue.name] = queue
		end

		# @private
		def deregister_queue(queue)
			@queues.delete queue.name
		end

		def find_exchange(name)
			@exchanges[name]
		end

		# @private
		def register_exchange(xchg)
			@exchanges[xchg.name] = xchg
		end

		# @private
		def deregister_exchange(xchg)
			@exchanges.delete xchg.name
		end
	end
end
