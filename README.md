Bunny Mock
==========

[![Build Status](https://travis-ci.org/arempe93/bunny-mock.svg?branch=master)](https://travis-ci.org/arempe93/bunny-mock)
[![Gem Version](https://badge.fury.io/rb/bunny-mock.svg)](https://rubygems.org/gems/bunny-mock)
[![Coverage Status](https://coveralls.io/repos/arempe93/bunny-mock/badge.svg?branch=master&service=github)](https://coveralls.io/github/arempe93/bunny-mock?branch=master)
[![Documentation](http://inch-ci.org/github/arempe93/bunny-mock.svg?branch=master)](http://www.rubydoc.info/github/arempe93/bunny-mock)

A mock client for RabbitMQ, modeled after the popular [Bunny client](https://github.com/ruby-amqp/bunny). It currently supports basic usage of Bunny for managing exchanges and queues, with the goal of being able to handle and test all Bunny use cases.

## Usage

BunnyMock can be injected into your RabbitMQ application in place of Bunny for testing. Consider the following example of an RabibtMQ helper module, in Rails

```ruby
require 'bunny'

module AMQP
    module Factory

		## Connection, can be mocked for tests
		mattr_accessor :connection

        ####################################################
        #   Connection Management
        ####################################################

        def self.connect

            # create bunny rmq client
            @connection = Bunny.new Global.amqp.to_hash

            # make connection
            @connection.start

            # return connection
            @connection
        end

		def self.get_channel

            # make connection if not connected
            connect unless defined?(@connection) and @connection.open?

            # get channel
            @connection.channel
        end

		...
	end
end
```

In this case, to set up your tests, you can simply set `AMQP::Factory.connection = BunnyMock.new.start` to inject the mock library. Then you can use the mock helpers in your tests.

## Examples

#### Declaration

```ruby
it 'should create queues and exchanges' do

    session = BunnyMock.new.start
    channel = session.channel

    queue = channel.queue 'queue.test'
    expect(session.queue_exists?('queue.test')).to be_truthy

    queue.delete
    expect(session.queue_exists?('queue.test')).to be_falsey

    xchg = channel.exchange 'xchg.test'
    expect(session.exchange_exists?('exchange.test')).to be_truthy

    xchg.delete
    expect(session.exchange_exists?('exchange.test')).to be_falsey
end
```

#### Publishing

```ruby
it 'should publish messages to queues' do

	channel = BunnyMock.new.start.channel
	queue = channel.queue 'queue.test'

	queue.publish 'Testing message', priority: 5

	expect(queue.message_count).to eq(1)

	payload = queue.pop
	expect(queue.message_count).to eq(0)

	expect(payload[:message]).to eq('Testing message')
	expect(payload[:options][:priority]).to eq(5)
end

it 'should route messages from exchanges' do

    channel = BunnyMock.new.start.channel

    xchg = channel.topic 'xchg.topic'
	queue = channel.queue 'queue.test'

    xchg.publish 'Routed message', routing_key: '*.test'

    expect(queue.message_count).to eq(1)
	expect(queue.pop[:message]).to eq('Routed message')
end
```

#### Binding

```ruby
it 'should bind queues to exchanges' do

	channel = BunnyMock.new.start.channel

	queue = channel.queue 'queue.test'
	xchg = channel.exchange 'xchg.test'

	queue.bind xchg
	expect(queue.bound_to?(xchg)).to be_truthy
	expect(xchg.has_binding?(queue)).to be_truthy

	queue.unbind xchg
	expect(queue.bound_to?(xchg)).to be_falsey
	expect(xchg.has_binding?(queue)).to be_falsey

	queue.bind 'xchg.test'
	expect(queue.bound_to?(xchg)).to be_truthy
	expect(xchg.has_binding?(queue)).to be_truthy
end

it 'should bind exchanges to exchanges' do

	channel = BunnyMock.new.start.channel

	source = channel.exchange 'xchg.source'
	receiver = channel.exchange 'xchg.receiver'

	receiver.bind source
	expect(receiver.bound_to?(source)).to be_truthy
	expect(source.has_binding?(receiver)).to be_truthy

	receiver.unbind source
	expect(receiver.bound_to?(source)).to be_falsey
	expect(xchg.has_binding?(receiver)).to be_falsey

	receiver.bind 'xchg.source'
	expect(receiver.bound_to?(source)).to be_truthy
	expect(source.has_binding?(receiver)).to be_truthy
end
```

## Installation

### With RubyGems

To install BunnyMock with RubyGems:

```
gem install bunny-mock
```

### With Bundler

To use BunnyMock with a Bundler managed project:

```
gem 'bunny-mock'
```

## Documentation

View the documentation on [RubyDoc](http://www.rubydoc.info/github/arempe93/bunny-mock)

## Dependencies

* Ruby version >= 2.0

* [AMQ Protocol](https://github.com/ruby-amqp/amq-protocol) - Also a dependency of Bunny

## License

Released under the MIT license
