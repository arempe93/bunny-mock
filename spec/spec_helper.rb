$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require 'bundler'
Bundler.setup :default, :test

require 'bunny_mock'

mock = BunnyMock.new
mock.start

channel = mock.channel

xchg = channel.direct 'testing.xchg'

q = channel.queue 'testing.queue'

q.bind xchg

puts "Queue bound to xchg => #{q.bound_to?(xchg)}"
puts "Exchange bound to queue => #{xchg.has_binding?(q)}"
