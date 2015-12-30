describe BunnyMock::Exchanges::Topic do

	context '#deliver' do

		before do
			@source = @channel.topic 'xchg.source'

			@first = @channel.queue 'queue.category.sub.first'
			@second = @channel.queue 'queue.category.second'
			@third = @channel.queue 'queue.topic.sub.third'

			@first.bind @source
			@second.bind @source
			@third.bind @source
		end

		it 'should deliver with no wildcards' do

			@source.publish 'Testing message', routing_key: 'queue.category.second'

			expect(@first.message_count).to eq(0)
			expect(@third.message_count).to eq(0)

			expect(@second.message_count).to eq(1)
			expect(@second.pop[:message]).to eq('Testing message')
		end

		context 'should deliver with wildcards' do

			it 'for single wildcards' do

				@source.publish 'Testing message', routing_key: 'queue.*.sub.*'

				expect(@second.message_count).to eq(0)

				expect(@first.message_count).to eq(1)
				expect(@first.pop[:message]).to eq('Testing message')

				expect(@third.message_count).to eq(1)
				expect(@third.pop[:message]).to eq('Testing message')
			end

			it 'for multiple wildcards' do

				@source.publish 'Testing message', routing_key: 'queue.category.#'

				expect(@third.message_count).to eq(0)

				expect(@first.message_count).to eq(1)
				expect(@first.pop[:message]).to eq('Testing message')

				expect(@second.message_count).to eq(1)
				expect(@second.pop[:message]).to eq('Testing message')
			end

			it 'for a mixed wildcards' do

				@source.publish 'Testing message', routing_key: '#.sub.*'

				expect(@second.message_count).to eq(0)

				expect(@first.message_count).to eq(1)
				expect(@first.pop[:message]).to eq('Testing message')

				expect(@third.message_count).to eq(1)
				expect(@third.pop[:message]).to eq('Testing message')
			end
		end
	end
end
