module BunnyMock
	class Channel

		#
		# API
		#

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
			Exchange.new self, opts.fetch(:type, :direct), name, opts
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



		# @endgroup
	end
end
