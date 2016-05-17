require 'rspec'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'bundler'
Bundler.setup :default, :test
Bundler.require

require 'coveralls'
Coveralls.wear!

require 'bunny-mock'
BunnyMock.use_bunny_queue_pop_api = true

RSpec.configure do |config|

	config.before :each do
		@session = BunnyMock.new.start
		@channel = @session.channel
	end
end
