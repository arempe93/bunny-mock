module BunnyMock
	# Mocks Bunny::Session
	class Session

		#
		# API
		#

		# Creates a new {BunnyMock::Session} instance
		#
		# @api public
		def initialize(*args)

			# not connected until {BunnyMock::Session#start} is called
			@status = :not_connected
		end

		# Sets status to connected
		#
		# @return [BunnyMock::Session] self
		# @api public
		def start

			@status = :connected

			self
		end

		# Sets status to closed
		#
		# @return [BunnyMock::Session] self
		# @api public
		def stop

			@status = :closed

			self
		end
		alias close stop

		# Tests if connection is available
		#
		# @return [Boolean] true if status is connected, false otherwise
		# @api public
		def open?

			@status == :connected
		end

		# Creates a new {BunnyMock::Channel} instance
		#
		# @param [Integer] n Channel identifier
		# @param [Integer] pool_size Work pool size (insignificant)
		#
		# @return [BunnyMock::Channel] Channel instance
		# @api public
		def create_channel(n = nil, pool_size = 1)

			# raise same error as {Bunny::Session#create_channel}
			raise ArgumentError, "channel number 0 is reserved in the protocol and cannot be used" if n == 0

			# create and open channel
			channel = Channel.new self, n
			channel.open

			# return channel
			channel
		end
		alias channel create_channel
	end
end
