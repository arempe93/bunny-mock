require 'rspec'

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'bundler'
Bundler.setup :default, :test
Bundler.require

require 'coveralls'
Coveralls.wear!

require 'bunny-mock'

RSpec.configure do |config|

	config.before :each do
		@session = BunnyMock::Session.new
		@channel = @session.channel
	end
end
