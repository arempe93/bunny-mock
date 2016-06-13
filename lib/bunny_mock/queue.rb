# frozen_string_literal: true
module BunnyMock
  class Queue
    #
    # API
    #

    # @return {BunnyMock::Channel} Channel used by queue
    attr_reader :channel

    # @return [String] Queue name
    attr_reader :name

    # @return [Hash] Creation options
    attr_reader :opts

    ##
    # Create a new [BunnyMock::Queue] instance
    #
    # @param [BunnyMock::Channel] channel Channel this queue will use
    # @param [String] name Name of queue
    # @param [Hash] opts Creation options
    #
    # @see BunnyMock::Channel#queue
    #
    def initialize(channel, name = '', opts = {})
      # Store creation information
      @channel = channel
      @name    = name
      @opts    = opts

      # Store messages
      @messages = []
    end

    # @group Bunny API

    ##
    # Publish a message
    #
    # @param [Object] payload Message payload
    # @param [Hash] opts Message properties
    #
    # @option opts [String] :routing_key Routing key
    # @option opts [Boolean] :persistent Should the message be persisted to disk?
    # @option opts [Boolean] :mandatory Should the message be returned if it cannot be routed to any queue?
    # @option opts [Integer] :timestamp A timestamp associated with this message
    # @option opts [Integer] :expiration Expiration time after which the message will be deleted
    # @option opts [String] :type Message type, e.g. what type of event or command this message represents. Can be any string
    # @option opts [String] :reply_to Queue name other apps should send the response to
    # @option opts [String] :content_type Message content type (e.g. application/json)
    # @option opts [String] :content_encoding Message content encoding (e.g. gzip)
    # @option opts [String] :correlation_id Message correlated to this one, e.g. what request this message is a reply for
    # @option opts [Integer] :priority Message priority, 0 to 9. Not used by RabbitMQ, only applications
    # @option opts [String] :message_id Any message identifier
    # @option opts [String] :user_id Optional user ID. Verified by RabbitMQ against the actual connection username
    # @option opts [String] :app_id Optional application ID
    #
    # @return [BunnyMock::Queue] self
    # @see {BunnyMock::Exchange#publish}
    # @api public
    #
    def publish(payload, opts = {})
      check_queue_deleted!

      # add to messages
      @messages << { message: payload, options: opts }
      yield_consumers
      self
    end

    ##
    # Adds a consumer to the queue (subscribes for message deliveries).
    #
    # All params are ignored atm. Takes a block which is called when a message is delivered
    # to the queue
    #
    # @api public
    #
    def subscribe(*_args, &block)
      @consumers ||= []
      @consumers << block
      yield_consumers

      self
    end

    ##
    # Bind this queue to an exchange
    #
    # @param [BunnyMock::Exchange,String] exchange Exchange to bind to
    # @param [Hash] opts Binding properties
    #
    # @option opts [String] :routing_key Custom routing key
    #
    # @api public
    #
    def bind(exchange, opts = {})
      check_queue_deleted!

      if exchange.respond_to?(:add_route)

        # we can do the binding ourselves
        exchange.add_route opts.fetch(:routing_key, @name), self
      else

        # we need the channel to lookup the exchange
        @channel.queue_bind self, opts.fetch(:routing_key, @name), exchange
      end
    end

    ##
    # Unbind this queue from an exchange
    #
    # @param [BunnyMock::Exchange,String] exchange Exchange to unbind from
    # @param [Hash] opts Binding properties
    #
    # @option opts [String] :routing_key Custom routing key
    #
    # @api public
    #
    def unbind(exchange, opts = {})
      check_queue_deleted!

      if exchange.respond_to?(:remove_route)

        # we can do the unbinding ourselves
        exchange.remove_route opts.fetch(:routing_key, @name), self
      else

        # we need the channel to lookup the exchange
        @channel.queue_unbind self, opts.fetch(:routing_key, @name), exchange
      end
    end

    # @endgroup

    ##
    # Check if this queue is bound to the exchange
    #
    # @param [BunnyMock::Exchange,String] exchange Exchange to test
    # @param [Hash] opts Binding properties
    #
    # @option opts [String] :routing_key Routing key from binding
    #
    # @return [Boolean] true if this queue is bound to the given exchange, false otherwise
    # @api public
    #
    def bound_to?(exchange, opts = {})
      check_queue_deleted!

      if exchange.respond_to?(:routes_to?)
        # we can do the check ourselves
        exchange.routes_to? self, opts
      else
        # we need the channel to lookup the exchange
        @channel.xchg_routes_to? self, opts.fetch(:routing_key, @name), exchange
      end
    end

    ##
    # Count of messages in queue
    #
    # @return [Integer] Number of messages in queue
    # @api public
    #
    def message_count
      @messages.count
    end

    ##
    # Get oldest message in queue
    #
    # @return [Hash] Message data
    # @api public
    #
    def pop(opts = { manual_ack: false }, &block)
      if BunnyMock.use_bunny_queue_pop_api
        bunny_pop(opts, &block)
      else
        warn '[DEPRECATED] This behavior is deprecated - please set `BunnyMock::use_bunny_queue_pop_api` to true to use Bunny Queue#pop behavior'
        @messages.shift
      end
    end
    alias get pop

    ##
    # Clear all messages in queue
    #
    # @api public
    #
    def purge
      @messages = []

      self
    end

    ##
    # Get all messages in queue
    #
    # @return [Array] All messages
    # @api public
    #
    def all
      @messages
    end

    ##
    # Deletes this queue
    #
    # @api public
    #
    def delete
      @channel.deregister_queue self
      @deleted = true
    end

    private

    # @private
    def check_queue_deleted!
      raise 'Queue has been deleted' if @deleted
    end

    # @private
    def bunny_pop(*)
      response = pop_response(@messages.shift)
      block_given? ? yield(*response) : response
    end

    # @private
    def pop_response(message)
      return [nil, nil, nil] unless message

      di = GetResponse.new(@channel, self, message[:options])
      mp = MessageProperties.new(message[:options])

      [di, mp, message[:message]]
    end

    # @private
    def yield_consumers
      return if @consumers.nil?
      @consumers.each do |c|
        # rubocop:disable AssignmentInCondition
        while message = all.pop
          response = pop_response(message)
          c.call(response)
        end
      end
    end
  end
end
