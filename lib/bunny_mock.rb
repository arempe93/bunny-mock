# A mock RabbitMQ client based on Bunny
# @see https://github.com/ruby-amq/bunny
module BunnyMock

	# Instantiate a new mock Bunny session
	#
	# @return [BunnyMock::Session] Session instance
	# @api public
	def self.new(*args)

		# return new mock session
		BunnyMock::Session.new
	end

	# @return [String] AMQP protocol version
	def self.protocol_version
		AMQ::Protocol::PROTOCOL_VERSION
	end
end
