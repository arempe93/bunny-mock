describe BunnyMock::Queue do

	before do
		@queue = @channel.queue 'testing.q'
	end

	context '#publish' do

		it 'should add message' do

			@queue.publish 'This is a test message'

			expect(@queue.message_count).to eq(1)
			expect(@queue.pop[:message]).to eq('This is a test message')
			expect(@queue.message_count).to eq(0)
		end
	end

	context '#bind' do

		before do
			@source = @channel.exchange 'xchg.source'
			@receiver = @channel.queue 'queue.receiver'
		end

		it 'should bind by exchange instance' do

			@receiver.bind @source

			expect(@receiver.bound_to?(@source)).to be_truthy
			expect(@source.has_binding?(@receiver)).to be_truthy
		end

		it 'should bind by exchange name' do

			@receiver.bind @source.name

			expect(@receiver.bound_to?(@source)).to be_truthy
			expect(@source.has_binding?(@receiver)).to be_truthy
		end

		it 'should raise error when exchange does not exists' do

			expect { @receiver.bind('this.xchg.does.not.exist') }.to raise_exception(BunnyMock::NotFound)
		end
	end

	context '#unbind' do

		before do
			@source = @channel.exchange 'xchg.source'
			@receiver = @channel.queue 'queue.receiver'

			@receiver.bind @source
		end

		it 'should unbind by exchange instance' do

			@receiver.unbind @source

			expect(@receiver.bound_to?(@source)).to be_falsey
			expect(@source.has_binding?(@receiver)).to be_falsey
		end

		it 'should unbind by exchange name' do

			@receiver.unbind @source.name

			expect(@receiver.bound_to?(@source)).to be_falsey
			expect(@source.has_binding?(@receiver)).to be_falsey
		end

		it 'should raise error when exchange does not exists' do

			expect { @receiver.unbind('this.xchg.does.not.exist') }.to raise_exception(BunnyMock::NotFound)
		end
	end

	context '#bound_to?' do

		before do
			@source = @channel.exchange 'xchg.source'
			@receiver = @channel.queue 'queue.receiver'
		end

		context 'should return true if bound' do

			it 'by instance' do

				@receiver.bind @source

				expect(@receiver.bound_to?(@source)).to be_truthy
			end

			it 'by name' do

				@receiver.bind @source

				expect(@receiver.bound_to?(@source.name)).to be_truthy
			end

			it 'by routing key' do

				@receiver.bind @source, routing_key: 'queue.route'

				expect(@receiver.bound_to?(@source)).to be_falsey
				expect(@receiver.bound_to?(@source, routing_key: 'queue.route')).to be_truthy
			end
		end

		it 'return false otherwise' do

			expect(@receiver.bound_to?(@source)).to be_falsey
		end

		it 'should raise error when exchange does not exists' do

			expect { @receiver.bound_to?('this.xchg.does.not.exist') }.to raise_exception(BunnyMock::NotFound)
		end
	end

	context '#message_count' do

		it 'should return number of messages in queue' do

			@queue.publish 'First'
			@queue.publish 'Second'

			expect(@queue.message_count).to eq(2)

			@queue.pop

			expect(@queue.message_count).to eq(1)
		end
	end

	context '#pop' do

		it 'should return oldest message in queue' do

			@queue.publish 'First'
			@queue.publish 'Second'

			expect(@queue.pop[:message]).to eq('First')
		end
	end

	context '#purge' do

		it 'should clear all messages' do

			@queue.publish 'First'
			@queue.publish 'Second'

			@queue.purge

			expect(@queue.message_count).to eq(0)
		end
	end

	context '#delete' do

		before do
			@queue.delete
		end

		it 'should remove queue from session' do

			expect(@session.queue_exists?(@queue.name)).to be_falsey
		end
	end
end
