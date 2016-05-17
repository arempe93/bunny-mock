# frozen_string_literal: true
module BunnyMock
  class GetResponse
    #
    # Behavior
    #

    include Enumerable

    #
    # API
    #

    # @return [BunnyMock::Channel] Channel the response is from
    attr_reader :channel

    # @private
    def initialize(channel, queue, opts = {})
      @channel = channel
      @hash = {
        delivery_tag: '',
        redelivered:  false,
        exchange:     opts.fetch(:exchange, ''),
        routing_key:  opts.fetch(:routing_key, queue.name)
      }
    end

    # Iterates over the delivery properties
    # @see Enumerable#each
    def each(*args, &block)
      @hash.each(*args, &block)
    end

    # Accesses delivery properties by key
    # @see Hash#[]
    def [](k)
      @hash[k]
    end

    # @return [Hash] Hash representation of this delivery info
    def to_hash
      @hash
    end

    # @private
    def to_s
      to_hash.to_s
    end

    # @private
    def inspect
      to_hash.inspect
    end

    # @return [String] Delivery identifier that is used to acknowledge, reject and nack deliveries
    def delivery_tag
      @hash[:delivery_tag]
    end

    # @return [Boolean] true if this delivery is a redelivery (the message was requeued at least once)
    def redelivered
      @hash[:redelivered]
    end
    alias redelivered? redelivered

    # @return [String] Name of the exchange this message was published to
    def exchange
      @hash[:exchange]
    end

    # @return [String] Routing key this message was published with
    def routing_key
      @hash[:routing_key]
    end
  end
end
