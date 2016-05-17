describe BunnyMock::Channel do

	context '::new' do

		before do
			@channel = BunnyMock::Channel.new @session, 1
		end

		it 'should store connection' do
			expect(@channel.connection).to eq(@session)
		end

		it 'should store channel identifier' do
			expect(@channel.id).to eq(1)
		end

		it 'should set status to opening' do
			expect(@channel.status).to eq(:opening)
		end
	end

	context '#open' do

		it 'should set status to open' do
			expect(@channel.open.status).to eq(:open)
		end
	end

	context '#close' do

		it 'should set status to open' do
			@channel.open
			expect(@channel.close.status).to eq(:closed)
		end
	end

	context '#open?' do

		it 'should return true if status is open' do
			expect(@channel.open?).to be_truthy
		end

		it 'should return false otherwise' do
			expect(BunnyMock::Channel.new.open?).to be_falsey
			expect(@channel.close.open?).to be_falsey
		end
	end

	context '#closed?' do

		it 'should return true if status is closed' do
			expect(@channel.close.closed?).to be_truthy
		end

		it 'should return false otherwise' do
			expect(BunnyMock::Channel.new.closed?).to be_falsey
			expect(@channel.closed?).to be_falsey
		end
	end

	context '#exchange' do

		it 'should declare a new exchange' do
			xchg = @channel.exchange 'testing.xchg', type: :fanout
			expect(xchg.class).to eq(BunnyMock::Exchanges::Fanout)
		end

		it 'should return a cached exchange with the same name' do
			xchg = @channel.exchange 'testing.xchg', type: :fanout
			expect(@channel.exchange('testing.xchg', type: :fanout)).to eq(xchg)
		end

		it 'should register the exchange in cache' do
			xchg = @channel.exchange 'testing.xchg', type: :fanout
			expect(@session.exchange_exists?('testing.xchg')).to be_truthy
		end
	end

	context '#direct' do

		it 'should declare a new direct exchange' do
			expect(@channel.direct('testing.xchg').class).to eq(BunnyMock::Exchanges::Direct)
		end
	end

	context '#topic' do

		it 'should declare a new topic exchange' do
			expect(@channel.topic('testing.xchg').class).to eq(BunnyMock::Exchanges::Topic)
		end
	end

	context '#fanout' do

		it 'should declare a new fanout exchange' do
			expect(@channel.fanout('testing.xchg').class).to eq(BunnyMock::Exchanges::Fanout)
		end
	end

	context '#header' do

		it 'should declare a new headers exchange' do
			expect(@channel.header('testing.xchg').class).to eq(BunnyMock::Exchanges::Header)
		end
	end

	context '#default_exchange' do

		it 'should return a nameless direct exchange' do
			xchg = @channel.default_exchange

			expect(xchg.class).to eq(BunnyMock::Exchanges::Direct)
			expect(xchg.name).to eq('')
		end
	end

	context '#basic_publish' do
		let(:xchg_name) { 'testing.xchg' }
		let(:key) { 'routing.key' }
		let(:data) { { some: 'data' } }

		let(:xchg) { @channel.direct xchg_name }
		let(:queue) { @channel.queue 'testing.queue' }

		before do
			queue.bind(xchg, routing_key: key)
		end

		it 'returns BunnyMock::Channel#self' do
			result = @channel.basic_publish(data, xchg_name, key)

			expect(result).to eq @channel
		end

		it 'should publish to the exchange' do
			@channel.basic_publish(data, xchg_name, key)

			expect(queue.pop[2]).to eq data
		end

		it 'accepts exchange object for exchange param' do
			@channel.basic_publish(data, xchg, key)

			expect(queue.pop[2]).to eq data
		end

		it 'passes opts down to exchange' do
			@channel.basic_publish(data, xchg, key, extra: 'opts')

			expect(queue.pop[1].to_hash).to include(extra: 'opts')
		end

		it 'creates exchange if it does not exist' do
			@channel.basic_publish(data, 'some.other.xchg', key)

			expect(@channel.exchange('some.other.xchg')).to be_kind_of BunnyMock::Exchange
		end
	end

	context '#queue' do

		it 'should declare a new queue' do
			q = @channel.queue 'testing.q'
			expect(q.class).to eq(BunnyMock::Queue)
		end

		it 'should return a cached queue with the same name' do
			q = @channel.queue 'testing.q'
			expect(@channel.queue('testing.q')).to eq(q)
		end

		it 'should register the queue in cache' do
			q = @channel.queue 'testing.q'
			expect(@session.queue_exists?('testing.q')).to be_truthy
		end
	end

	context '#temporary_queue' do

		it 'should declare a nameless queue' do
			expect(@channel.temporary_queue.class).to eq(BunnyMock::Queue)
		end
	end
end
