Bunny Mock
==========

[![Build Status](https://travis-ci.org/arempe93/bunny-mock.svg?branch=master)](https://travis-ci.org/arempe93/bunny-mock)
[![Gem Version](https://badge.fury.io/rb/bunny-mock.svg)](https://rubygems.org/gems/bunny-mock)
[![Coverage Status](https://coveralls.io/repos/arempe93/bunny-mock/badge.svg?branch=master&service=github)](https://coveralls.io/github/arempe93/bunny-mock?branch=master)
[![Documentation](http://inch-ci.org/github/arempe93/bunny-mock.svg?branch=master)](http://www.rubydoc.info/github/arempe93/bunny-mock)

A mock client for RabbitMQ, modeled after the popular [Bunny client](https://github.com/ruby-amqp/bunny). It currently supports basic usage of Bunny for managing exchanges and queues, with the goal of being able to handle and test all Bunny use cases.

## Usage

BunnyMock can be injected into your RabbitMQ application in place of Bunny for testing. Consider the following [example of an RabibtMQ helper module](https://github.com/arempe93/amqp-example/blob/master/lib/amqp/factory.rb) that uses Bunny

```ruby
require 'bunny'

module RabbitFactory

	## Connection, can be mocked for tests
	attr_accessor :connection

    ####################################################
    #   Connection Management
    ####################################################

    def self.connect

        # create bunny rmq client
        @@connection = Bunny.new

        # make connection
        @@connection.start

        # return connection
        @@connection
    end

	def self.get_channel

        # make connection if not connected
        connect unless defined?(@@connection) and @@connection.open?

        # get channel
        @@connection.channel
    end

	...

	# methods that use get_channel to obtain a Bunny channel
end
```

In this case, the following code placed in `spec_helper` or `test_helper` or what have you is all you need to start using BunnyMock to test your RabbitMQ application

```ruby
require 'bunny-mock'
RabbitFactory.connection = BunnyMock.new.start
```

## Examples

Here are some examples showcasing what BunnyMock can do

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

#### With RubyGems

To install BunnyMock with RubyGems:

```
gem install bunny-mock
```

#### With Bundler

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
