describe BunnyMock::Exchanges::Direct do

	context '#deliver' do

		before do
			@source = @channel.direct 'xchg.source'

			@first = @channel.queue 'queue.first'
			@second = @channel.queue 'queue.second'
			@third = @channel.queue 'queue.third'

			@first.bind @source
			@second.bind @source
			@third.bind @source
		end

		it 'should only deliver to direct route match' do
			@source.publish 'Testing message', routing_key: 'queue.second'

			expect(@first.message_count).to eq(0)
			expect(@third.message_count).to eq(0)

			expect(@second.message_count).to eq(1)
			expect(@second.pop[2]).to eq('Testing message')
		end
	end
end
