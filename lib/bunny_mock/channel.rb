# frozen_string_literal: true
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
      "#<#{self.class.name}:#{object_id} @id=#{@id} @open=#{open?}>"
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
      @connection.register_exchange xchg_find_or_create(name, opts)
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
      exchange name, opts.merge(type: :fanout)
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
      exchange name, opts.merge(type: :direct)
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
      exchange name, opts.merge(type: :topic)
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
      exchange name, opts.merge(type: :header)
    end

    ##
    # Mocks RabbitMQ default exchange
    #
    # @return [BunnyMock::Exchange] Mocked default exchange instance
    # @api public
    #
    def default_exchange
      direct '', no_declare: true
    end

    ##
    # Mocks Bunny::Channel#basic_publish
    #
    # @param [String] payload Message payload. It will never be modified by Bunny or RabbitMQ in any way.
    # @param [String] exchange Exchange to publish to
    # @param [String] routing_key Routing key
    # @param [Hash] opts Publishing options

    # @return [BunnyMock::Channel] Self
    def basic_publish(payload, xchg, routing_key, opts = {})
      xchg = xchg_find_or_create(xchg) unless xchg.respond_to? :name

      xchg.publish payload, opts.merge(routing_key: routing_key)

      self
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

    ##
    # Does nothing atm.
    #
    # @return nil
    # @api public
    #
    def confirm_select(callback = nil)
      # noop
    end

    ##
    # Does nothing atm.
    #
    # @return nil
    # @api public
    #
    def prefetch(*)
      # noop
    end

    ##
    # Does not actually wait, but always return true.
    #
    # @return true
    # @api public
    #
    def wait_for_confirms(*)
      true
    end

    ##
    # Does nothing atm.
    #
    # @return nil
    # @api public
    #
    def acknowledge(*)
      # noop
    end

    ##
    # Does nothing atm.
    #
    # @return nil
    # @api public
    #
    def reject(*)
      # noop
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
      raise Bunny::NotFound.new("Exchange '#{xchg}' was not found", self, false) unless exchange

      exchange.add_route key, queue
    end

    # @private
    def queue_unbind(queue, key, xchg)
      exchange = @connection.find_exchange xchg
      raise Bunny::NotFound.new("Exchange '#{xchg}' was not found", self, false) unless exchange

      exchange.remove_route key, queue
    end

    # @private
    def xchg_bound_to?(receiver, key, name)
      source = @connection.find_exchange name
      raise Bunny::NotFound.new("Exchange '#{name}' was not found", self, false) unless source

      source.routes_to? receiver, routing_key: key
    end

    # @private
    def xchg_routes_to?(queue, key, xchg)
      exchange = @connection.find_exchange xchg
      raise Bunny::NotFound.new("Exchange '#{xchg}' was not found", self, false) unless exchange

      exchange.routes_to? queue, routing_key: key
    end

    # @private
    def xchg_bind(receiver, routing_key, name)
      source = @connection.find_exchange name
      raise Bunny::NotFound.new("Exchange '#{name}' was not found", self, false) unless source

      source.add_route routing_key, receiver
    end

    # @private
    def xchg_unbind(routing_key, name, exchange)
      source = @connection.find_exchange name
      raise Bunny::NotFound.new("Exchange '#{name}' was not found", self, false) unless source

      source.remove_route routing_key, exchange
    end

    private

    # @private
    def xchg_find_or_create(name, opts = {})
      @connection.find_exchange(name) || Exchange.declare(self, name, opts)
    end
  end
end
