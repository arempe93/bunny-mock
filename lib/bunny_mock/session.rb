module BunnyMock
	# Mocks Bunny::Session
	class Session

		#
		# API
		#

		# Creates a new [BunnyMock::Session] instance
		#
		# @api public
		def initialize(*args)

			# not connected until {BunnyMock::Session#start} is called
			@status = :not_connected
		end

		# Sets status to connected
		#
		# @api public
		def start

			# set status to connected
			@status = :connected
		end

		# Sets status to closed
		#
		# @api public
		def stop

			# set status to closed
			@status = :closed
		end
		alias close stop

		# Tests if connection is available
		#
		# @return [Boolean]
		# @api public
		def open?

			@status == :connected
		end

		# Creates a new [BunnyMock::Channel] instance
		#
		# @return [BunnyMock::Channel]
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
