module BunnyMock
	module Exchanges
		class Fanout < BunnyMock::Exchange

			#
			# API
			#

			##
			# Deliver a message to all routes
			#
			# @param [Object] payload Message content
			# @param [Hash] opts Message properties
			# @param [String] key Routing key
			#
			# @api public
			#
			def deliver(payload, opts, key)

				@routes.each do |route, destination|

					# send to all routes
					destination.deliver payload, opts
				end
			end
		end
	end
end
