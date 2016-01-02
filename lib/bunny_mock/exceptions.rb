module BunnyMock

	##
	# Base class for all exceptions
	#
	# @api public
	#
	class Exception < ::StandardError;	end

	##
	# Raised when a queue or exchange is not found
	#
	# @api public
	#
	class NotFound < Exception;	end
end
