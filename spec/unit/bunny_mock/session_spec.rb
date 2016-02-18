describe BunnyMock::Session do

  before do
    @session = BunnyMock::Session.new
  end

	context '::new' do

		it 'should start as not connected' do

			expect(@session.status).to eq(:not_connected)
		end
	end

	context '#start' do

		it 'should set status to connected' do

			expect(@session.start.status).to eq(:connected)
		end
	end

	context '#stop (close)' do

		it 'should set status to closed' do

			@session.start

			expect(@session.stop.status).to eq(:closed)
		end
	end

	context '#open?' do

		it 'should return true if status is open' do

			@session.start

			expect(@session.open?).to be_truthy
		end

		it 'should return false otherwise' do

			# not_connected
			expect(@session.open?).to be_falsey

			@session.stop

			# closed
			expect(@session.open?).to be_falsey
		end
	end

	context '#create_channel (channel)' do

		it 'should create a new channel with no arguments' do

			first = @session.create_channel
			second = @session.create_channel

			expect(first.class).to eq(BunnyMock::Channel)
			expect(second.class).to eq(BunnyMock::Channel)

			expect(first).to_not eq(second)
		end

		it 'should return cached channel with same identifier' do

			first = @session.create_channel 1
			second = @session.create_channel 1

			expect(first.class).to eq(BunnyMock::Channel)
			expect(second.class).to eq(BunnyMock::Channel)

			expect(first).to eq(second)
		end

		it 'should return an ArgumentError for reserved channel' do

			expect { @session.create_channel(0) }.to raise_error(ArgumentError)
		end
	end

  context '#with_channel' do

    it 'should close the channel after the block ends' do
      channel = nil
      @session.with_channel do |c|
        channel = c
        expect(channel.open?).to be_truthy
      end

      expect(channel.closed?).to be_truthy
    end
  end
end
