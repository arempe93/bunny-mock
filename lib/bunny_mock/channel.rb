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

    ##
    # Create a new {BunnyMock::Channel} instance
    #
    # @param [BunnyMock::Session] connection Mocked session instance
    # @param [Integer] id Channel identifier
    #
    # @api public
    #
    def initialize(connection = nil, id = nil)

      # store channel id
      @id = id

      # store connection information
      @connection = connection

      # initialize exchange and queue storage
      @exchanges = {}
      @queues    = {}

      # set status to opening
      @status = :opening
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

    ##
    # Sets status to open
    #
    # @return [BunnyMock::Channel] self
    # @api public
    #
    def open

      @status = :open

      self
    end

    ##
    # Sets status to closed
    #
    # @return [BunnyMock::Channel] self
    # @api public
    #
    def close

      @status = :closed

      self
    end

    # @return [String] Object representation
    def to_s
      "#<#{self.class.name}:#{self.object_id} @id=#{@id} @open=#{open?}>"
    end
    alias inspect to_s

    # @group Exchange API

    ##
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
    #
    def exchange(name, opts = {})

      xchg = @connection.find_exchange(name) || Exchange.declare(self, name, opts)

      @connection.register_exchange xchg
    end

    ##
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
    #
    def fanout(name, opts = {})
      self.exchange name, opts.merge(type: :fanout)
    end

    ##
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
    #
    def direct(name, opts = {})
      self.exchange name, opts.merge(type: :direct)
    end

    ##
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
    #
    def topic(name, opts = {})
      self.exchange name, opts.merge(type: :topic)
    end

    ##
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
    #
    def header(name, opts = {})
      self.exchange name, opts.merge(type: :header)
    end

    ##
    # Mocks RabbitMQ default exchange
    #
    # @return [BunnyMock::Exchange] Mocked default exchange instance
    # @api public
    #
    def default_exchange
      self.direct '', no_declare: true
    end

    # @endgroup

    # @group Queue API

    ##
    # Create a new {BunnyMock::Queue} instance, or find in channel cache
    #
    # @param [String] name Name of queue
    # @param [Hash] opts Queue creation options
    #
    # @return [BunnyMock::Queue] Queue that was mocked or looked up
    # @api public
    #
    def queue(name = '', opts = {})

      queue = @connection.find_queue(name) || Queue.new(self, name, opts)

      @connection.register_queue queue
    end

    ##
    # Create a new {BunnyMock::Queue} instance with no name
    #
    # @param [Hash] opts Queue creation options
    #
    # @return [BunnyMock::Queue] Queue that was mocked or looked up
    # @see #queue
    # @api public
    #
    def temporary_queue(opts = {})

      queue '', opts.merge(exclusive: true)
    end

    # @endgroup

    #
    # Implementation
    #

    # @private
    def deregister_queue(queue)
      @connection.deregister_queue queue.name
    end

    # @private
    def deregister_exchange(xchg)
      @connection.deregister_exchange xchg.name
    end

    # @private
    def queue_bind(queue, key, xchg)

      exchange = @connection.find_exchange xchg

      raise NotFound.new "Exchange '#{xchg}' was not found" unless exchange

      exchange.add_route key, queue
    end

    # @private
    def queue_unbind(key, xchg)

      exchange = @connection.find_exchange xchg

      raise NotFound.new "Exchange '#{xchg}' was not found" unless exchange

      exchange.remove_route key
    end

    # @private
    def xchg_bound_to?(receiver, key, name)

      source = @connection.find_exchange name

      raise NotFound.new "Exchange '#{name}' was not found" unless source

      source.routes_to? receiver, routing_key: key
    end

    # @private
    def xchg_routes_to?(key, xchg)

      exchange = @connection.find_exchange xchg

      raise NotFound.new "Exchange '#{xchg}' was not found" unless exchange

      exchange.routes_to? key
    end

    # @private
    def xchg_bind(receiver, routing_key, name)

      source = @connection.find_exchange name

      raise NotFound.new "Exchange '#{name}' was not found" unless source

      source.add_route routing_key, receiver
    end

    # @private
    def xchg_unbind(routing_key, name)

      source = @connection.find_exchange name

      raise NotFound.new "Exchange '#{name}' was not found" unless source

      source.remove_route routing_key
    end
  end
end
