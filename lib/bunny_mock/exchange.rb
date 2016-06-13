# frozen_string_literal: true
module BunnyMock
  class Exchange
    class << self
      ##
      # Create a new {BunnyMock::Exchange} instance
      #
      # @param [BunnyMock::Channel] channel Channel this exchange will use
      # @param [String] name Name of exchange
      # @param [Hash] opts Creation options
      #
      # @option opts [Boolean] :durable (false) Should this exchange be durable?
      # @option opts [Boolean] :auto_delete (false) Should this exchange be automatically deleted when it is no longer used?
      # @option opts [Boolean] :arguments ({}) Additional optional arguments (typically used by RabbitMQ extensions and plugins)
      #
      # @return [BunnyMock::Exchange] A new exchange
      # @see BunnyMock::Channel#exchange
      # @api public
      #
      def declare(channel, name = '', opts = {})
        # get requested type
        type = opts.fetch :type, :direct

        # get needed class type
        klazz = BunnyMock::Exchanges.const_get type.to_s.capitalize

        # create exchange of desired type
        klazz.new channel, name, type, opts
      end
    end

    #
    # API
    #

    # @return [BunnyMock::Channel] Channel used by exchange
    attr_reader :channel

    # @return [String] Exchange name
    attr_reader :name

    # @return [String] Exchange type
    attr_reader :type

    # @return [Hash] Creation options
    attr_reader :opts

    # @return [Boolean] If the exchange was declared as durable
    attr_reader :durable
    alias durable? durable

    # @return [Boolean] If the exchange was declared with auto deletion
    attr_reader :auto_delete
    alias auto_delete? auto_delete

    # @return [Boolean] If the exchange was declared as internal
    attr_reader :internal
    alias internal? internal

    # @return [Hash] Any additional declaration arguments
    attr_reader :arguments

    # @private
    # @return [Boolean] If exchange has been deleted
    attr_reader :deleted

    # @private
    def initialize(channel, name, type, opts)
      # store creation information
      @channel  = channel
      @name     = name
      @opts     = opts
      @type     = type

      # get options
      @durable      = @opts[:durable]
      @auto_delete  = @opts[:auto_delete]
      @internal     = @opts[:internal]
      @arguments    = @opts[:arguments]

      # create binding storage
      @routes = {}
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
    # @return [BunnyMock::Exchange] self
    # @see {BunnyMock::Exchanges::Direct#deliver}
    # @see {BunnyMock::Exchanges::Topic#deliver}
    # @see {BunnyMock::Exchanges::Fanout#deliver}
    # @see {BunnyMock::Exchanges::Headers#deliver}
    # @api public
    #
    def publish(payload, opts = {})
      # handle message sending, varies by type
      deliver(payload, opts.merge(exchange: name), opts.fetch(:routing_key, ''))

      self
    end

    ##
    # Delete this exchange
    #
    # @api public
    #
    def delete(*)
      @channel.deregister_exchange self

      @deleted = true
    end

    ##
    # Bind this exchange to another exchange
    #
    # @param [BunnyMock::Exchange,String] exchange Exchange to bind to
    # @param [Hash] opts Binding properties
    #
    # @option opts [String] :routing_key Custom routing key
    #
    # @return [BunnyMock::Exchange] self
    # @api public
    #
    def bind(exchange, opts = {})
      if exchange.respond_to?(:add_route)

        # we can do the binding ourselves
        exchange.add_route opts.fetch(:routing_key, @name), self
      else

        # we need the channel to look up the exchange
        @channel.xchg_bind self, opts.fetch(:routing_key, @name), exchange
      end

      self
    end

    ##
    # Unbind this exchange from another exchange
    #
    # @param [BunnyMock::Exchange,String] exchange Exchange to unbind from
    # @param [Hash] opts Binding properties
    #
    # @option opts [String] :routing_key Custom routing key
    #
    # @return [BunnyMock::Exchange] self
    # @api public
    #
    def unbind(exchange, opts = {})
      if exchange.respond_to?(:remove_route)
        # we can do the unbinding ourselves
        exchange.remove_route opts.fetch(:routing_key, @name), self
      else
        # we need the channel to look up the exchange
        @channel.xchg_unbind opts.fetch(:routing_key, @name), exchange, self
      end

      self
    end

    # @endgroup

    ##
    # Check if this exchange is bound to another exchange
    #
    # @param [BunnyMock::Exchange,String] exchange Exchange to check
    # @param [Hash] opts Binding properties
    #
    # @option opts [String] :routing_key Routing key from binding
    #
    # @return [Boolean] true if this exchange is bound to the given exchange, false otherwise
    # @api public
    #
    def bound_to?(exchange, opts = {})
      if exchange.respond_to?(:routes_to?)
        # we can find out on the exchange object
        exchange.routes_to? self, opts
      else

        # we need the channel to look up the exchange
        @channel.xchg_bound_to? self, opts.fetch(:routing_key, @name), exchange
      end
    end

    ##
    # Check if a queue is bound to this exchange
    #
    # @param [BunnyMock::Queue,String] exchange_or_queue Exchange or queue to check
    # @param [Hash] opts Binding properties
    #
    # @option opts [String] :routing_key Custom routing key
    #
    # @return [Boolean] true if the given queue or exchange matching options is bound to this exchange, false otherwise
    # @api public
    #
    def routes_to?(exchange_or_queue, opts = {})
      route = exchange_or_queue.respond_to?(:name) ? exchange_or_queue.name : exchange_or_queue
      rk = opts.fetch(:routing_key, route)
      @routes.key?(rk) && @routes[rk].any? { |r| r == exchange_or_queue }
    end

    def has_binding?(exchange_or_queue, opts = {}) # rubocop:disable Style/PredicateName
      warn '[DEPRECATED] `has_binding?` is deprecated. Please use `routes_to?` instead.'
      routes_to?(exchange_or_queue, opts)
    end

    ##
    # Deliver a message to routes
    #
    # @see BunnyMock::Exchanges::Direct#deliver
    # @see BunnyMock::Exchanges::Topic#deliver
    # @see BunnyMock::Exchanges::Fanout#deliver
    # @see BunnyMock::Exchanges::Headers#deliver
    # @api public
    #
    def deliver(payload, opts, key)
      # noOp
    end

    #
    # Implementation
    #

    # @private
    def add_route(key, xchg_or_queue)
      @routes[key] ||= []
      @routes[key] << xchg_or_queue
    end

    # @private
    def remove_route(key, xchg_or_queue)
      instance = xchg_or_queue.respond_to?(:name) ? xchg_or_queue.name : xchg_or_queue
      @routes[key].delete_if do |r|
        route = r.respond_to?(:name) ? r.name : r
        route == instance
      end if @routes.key? key
    end
  end
end
