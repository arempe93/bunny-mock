Bunny Mock
==========

[![Build Status](https://travis-ci.org/arempe93/bunny-mock.svg?branch=master)](https://travis-ci.org/arempe93/bunny-mock)
[![Gem Version](https://badge.fury.io/rb/bunny-mock.svg)](https://rubygems.org/gems/bunny-mock)
[![Coverage Status](https://coveralls.io/repos/arempe93/bunny-mock/badge.svg?branch=master&service=github)](https://coveralls.io/github/arempe93/bunny-mock?branch=master)
[![Documentation](http://inch-ci.org/github/arempe93/bunny-mock.svg?branch=master)](http://www.rubydoc.info/github/arempe93/bunny-mock)

A mock client for RabbitMQ, modeled after the popular [Bunny client](https://github.com/ruby-amqp/bunny). It currently supports basic usage of Bunny for managing exchanges and queues, with the goal of being able to handle and test all Bunny use cases.

##### Upgrading

This project does its best to follow [semantic versioning practices](http://semver.org/). Check the [CHANGELOG](CHANGELOG.md) to see detailed versioning notes, and [UPGRADING](UPGRADING.md) for notes about major changes or deprecations.

## Usage

BunnyMock can be injected into your RabbitMQ application in place of Bunny for testing. For example, if you have a helper module named `AMQFactory`, some code similar to the following placed in `spec_helper` or `test_helper` or what have you is all you need to start using BunnyMock to test your RabbitMQ application

```ruby
require 'bunny-mock'

RSpec.configure do |config|
  config.before(:each) do
    AMQFactory.connection = BunnyMock.new.start
  end
end
```

For an example, easy to mock setup, check out [this helper](https://gist.github.com/arempe93/8143edb17c57666e738f)

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
  expect(session.exchange_exists?('xchg.test')).to be_truthy

  xchg.delete
  expect(session.exchange_exists?('xchg.test')).to be_falsey
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

  queue.bind xchg, routing_key: '*.test'
  xchg.publish 'Routed message', routing_key: 'foo.test'

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
  expect(xchg.routes_to?(queue)).to be_truthy

  queue.unbind xchg
  expect(queue.bound_to?(xchg)).to be_falsey
  expect(xchg.routes_to?(queue)).to be_falsey

  queue.bind 'xchg.test'
  expect(queue.bound_to?(xchg)).to be_truthy
  expect(xchg.routes_to?(queue)).to be_truthy
end

it 'should bind exchanges to exchanges' do

  channel = BunnyMock.new.start.channel

  source = channel.exchange 'xchg.source'
  receiver = channel.exchange 'xchg.receiver'

  receiver.bind source
  expect(receiver.bound_to?(source)).to be_truthy
  expect(source.routes_to?(receiver)).to be_truthy

  receiver.unbind source
  expect(receiver.bound_to?(source)).to be_falsey
  expect(source.routes_to?(receiver)).to be_falsey

  receiver.bind 'xchg.source'
  expect(receiver.bound_to?(source)).to be_truthy
  expect(source.routes_to?(receiver)).to be_truthy
end
```

## Other features

This gem was made based on my own use of Bunny in a project. If there are other uses for Bunny that this library does not cover (eg. missing methods, functionality), feel free to open an issue or pull request!


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

* [Bunny](https://github.com/ruby-amqp/bunny) - To use original exception classes

* ~~Ruby version >= 2.0 (A requirement of Bunny)~~ Now works with other Ruby versions (even JRuby!) thanks to **[@TimothyMDean](https://github.com/TimothyMDean)**

## License

Released under the MIT license
