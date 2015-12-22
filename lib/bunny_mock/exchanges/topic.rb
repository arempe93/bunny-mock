module BunnyMock
	module Exchanges
		class Topic < BunnyMock::Exchange

			# @private
			# @return [String] Multiple subdomain wildcard
			MULTI_WILDCARD = '#'

			# @private
			# @return [String] Single subdomain wildcard
			SINGLE_WILDCARD = '*'

			#
			# API
			#

			##
			# Deliver a message to route with keys matching wildcards
			#
			# @param [Object] payload Message content
			# @param [Hash] opts Message properties
			# @param [String] key Routing key
			#
			# @api public
			#
			def deliver(payload, opts, key)

				# escape periods with backslash for regex
				key.gsub! '.', '\.'

				# replace single wildcards with regex for a single domain
				key.gsub! SINGLE_WILDCARD, '(\w+)'

				# replace multi wildcards with regex for many domains separated by '.'
				key.gsub! MULTI_WILDCARD, '\w+\.?'

				# get all route keys for this exchange
				delivery_keys = @routes.keys.dup

				delivery_keys.each do |route|

					# deliver to all matches
					@routes[route].publish payload, opts if route =~ key
				end
			end
		end
	end
end
