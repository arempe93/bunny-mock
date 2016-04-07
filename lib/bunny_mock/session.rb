# frozen_string_literal: true
module BunnyMock
  # Mocks Bunny::Session
  class Session
    #
    # API
    #

    # @return [Symbol] Current session status
    attr_reader :status

    # @return [Hash<String, BunnyMock::Exchange>] Exchanges created by this channel
    attr_reader :exchanges

    # @return [Hash<String, BunnyMock::Queue>] Queues created by this channel
    attr_reader :queues

    ##
    # Creates a new {BunnyMock::Session} instance
    #
    # @api public
    def initialize(*)
      # not connected until {BunnyMock::Session#start} is called
      @status = :not_connected

      # create channel hash
      @channels = {}

      # create storage for queues and exchanges
      @queues    = {}
      @exchanges = {}
    end

    ##
    # Sets status to connected
    #
    # @return [BunnyMock::Session] self
    # @api public
    def start
      @status = :connected
      self
    end

    ##
    # Sets status to closed
    #
    # @return [BunnyMock::Session] self
    # @api public
    def stop
      @status = :closed
      self
    end
    alias close stop

    ##
    # Tests if connection is available
    #
    # @return [Boolean] true if status is connected, false otherwise
    # @api public
    def open?
      @status == :connected
    end
    alias connected? open?

    ##
    # Tests if connection is closed
    #
    # @return [Boolean] true if status is closed, false otherwise
    # @api public
    def closed?
      @status == :closed
    end

    ##
    # Tests if connection is closing
    #
    # @return [Boolean] true if status is closing, false otherwise
    # @api public
    def closing?
      @status == :closing
    end

    ##
    # Creates a new {BunnyMock::Channel} instance
    #
    # @param [Integer] n Channel identifier
    # @param [Integer] pool_size Work pool size (insignificant)
    #
    # @return [BunnyMock::Channel] Channel instance
    # @api public
    def create_channel(n = nil, _pool_size = 1)
      # raise same error as {Bunny::Session#create_channel}
      raise ArgumentError, 'channel number 0 is reserved in the protocol and cannot be used' if n == 0

      # return cached channel if exists
      return @channels[n] if n && @channels.key?(n)

      # create and open channel
      channel = Channel.new self, n
      channel.open

      # return channel
      @channels[n] = channel
    end
    alias channel create_channel

    ##
    # Creates a temporary {BunnyMock::Channel} instance, yields it to
    # the block given, then closes it
    #
    # @param [Integer] n Channel identifier
    #
    # @return [BunnyMock::Session] self
    # @api public
    def with_channel(n = nil)
      ch = create_channel(n)
      begin
        yield ch
      ensure
        ch.close if ch.open?
      end

      self
    end

    ##
    # Test if queue exists in channel cache
    #
    # @param [String] name Name of queue
    #
    # @return [Boolean] true if queue exists, false otherwise
    # @api public
    #
    def queue_exists?(name)
      !find_queue(name).nil?
    end

    ##
    # Test if exchange exists in channel cache
    #
    # @param [String] name Name of exchange
    #
    # @return [Boolean] true if exchange exists, false otherwise
    # @api public
    #
    def exchange_exists?(name)
      !find_exchange(name).nil?
    end

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
      @queues.delete queue
    end

    # @private
    def find_exchange(name)
      @exchanges[name]
    end

    # @private
    def register_exchange(xchg)
      @exchanges[xchg.name] = xchg
    end

    # @private
    def deregister_exchange(xchg)
      @exchanges.delete xchg
    end
  end
end
