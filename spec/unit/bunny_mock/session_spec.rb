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

  context '#open? (connected?)' do

    it 'should return true if status is open' do
      @session.start
      expect(@session.open?).to be_truthy
    end

    it 'should return false otherwise' do
      expect(@session.status).to eq(:not_connected)
      expect(@session.open?).to be_falsey

      @session.start
      @session.stop

      expect(@session.status).to eq(:closed)
      expect(@session.open?).to be_falsey
    end
  end

  describe '#closed?' do
    context 'with `not_connected` status' do
      it do
        expect(@session.closed?).to be_falsey
      end
    end

    context 'with `connected` status' do
      it do
        @session.start
        expect(@session.closed?).to be_falsey
      end
    end

    context 'with `closing` status' do
      it do
        # Mock `closing` status
        @session.instance_variable_set('@status', :closing)
        expect(@session.closed?).to be_falsey
      end
    end

    context 'with `closed` status' do
      it do
        @session.start
        @session.close
        expect(@session.closed?).to be_truthy
      end
    end
  end

  describe '#closing?' do
    context 'with `not_connected` status' do
      it do
        expect(@session.closing?).to be_falsey
      end
    end

    context 'with `connected` status' do
      it do
        @session.start
        expect(@session.closing?).to be_falsey
      end
    end

    context 'with `closing` status' do
      it do
        # Mock `closing` status
        @session.instance_variable_set('@status', :closing)
        expect(@session.closing?).to be_truthy
      end
    end

    context 'with `closed` status' do
      it do
        @session.start
        @session.close
        expect(@session.closing?).to be_falsey
      end
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

      expect(first).to eq(second)
    end

    it 'should return an ArgumentError for reserved channel' do
      expect { @session.create_channel(0) }.to raise_error(ArgumentError)
    end
  end

  context '#with_channel' do

    it 'should close the channel after the block ends' do
      channel = nil
      @session.with_channel { |c| channel = c }

      expect(channel.closed?).to be_truthy
    end

    it 'should close the channel if an exception is raised' do
      channel = nil

      expect do
        @session.with_channel do |c|
          channel = c
          raise 'Whoops!'
        end
      end.to raise_error('Whoops!')

      expect(channel.closed?).to be_truthy
    end
  end
end
