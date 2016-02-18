module BunnyMock

  ##
  # Base class for all exceptions
  #
  # @api public
  #
  Exception = Class.new(StandardError)

  ##
  # Raised when a queue or exchange is not found
  #
  # @api public
  #
  NotFound = Class.new(Exception)
end
