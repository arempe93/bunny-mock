describe BunnyMock::Exchange do

  context '::declare' do

    it 'should create a direct exchange' do
      expect(BunnyMock::Exchange.declare(@channel, 'testing.xchg', type: :direct).class).to eq(BunnyMock::Exchanges::Direct)
    end

    it 'should create a topic exchange' do
      expect(BunnyMock::Exchange.declare(@channel, 'testing.xchg', type: :topic).class).to eq(BunnyMock::Exchanges::Topic)
    end

    it 'should create a fanout exchange' do
      expect(BunnyMock::Exchange.declare(@channel, 'testing.xchg', type: :fanout).class).to eq(BunnyMock::Exchanges::Fanout)
    end

    it 'should create a header exchange' do
      expect(BunnyMock::Exchange.declare(@channel, 'testing.xchg', type: :header).class).to eq(BunnyMock::Exchanges::Header)
    end

    it 'should default to a direct exchange' do
      expect(BunnyMock::Exchange.declare(@channel, 'testing.xchg').class).to eq(BunnyMock::Exchanges::Direct)
    end
  end

  context '#bind' do

    before do
      @source = @channel.exchange 'xchg.source'
      @receiver = @channel.exchange 'xchg.receiver'
    end

    it 'should bind by exchange instance' do
      @receiver.bind @source

      expect(@receiver.bound_to?(@source)).to be_truthy
      expect(@source.routes_to?(@receiver)).to be_truthy
    end

    it 'should bind by exchange name' do
      @receiver.bind @source.name

      expect(@receiver.bound_to?(@source)).to be_truthy
      expect(@source.routes_to?(@receiver)).to be_truthy
    end

    it 'should raise error when exchange does not exists' do
      expect { @receiver.bind('this.xchg.does.not.exist') }.to raise_exception(Bunny::NotFound)
    end
  end

  context '#unbind' do

    before do
      @source = @channel.exchange 'xchg.source'
      @receiver = @channel.exchange 'xchg.receiver'

      @receiver.bind @source
    end

    it 'should unbind by exchange instance' do
      @receiver.unbind @source

      expect(@receiver.bound_to?(@source)).to be_falsey
      expect(@source.routes_to?(@receiver)).to be_falsey
    end

    it 'should unbind by exchange name' do
      @receiver.unbind @source.name

      expect(@receiver.bound_to?(@source)).to be_falsey
      expect(@source.routes_to?(@receiver)).to be_falsey
    end

    it 'should raise error when exchange does not exists' do
      expect { @receiver.unbind('this.xchg.does.not.exist') }.to raise_exception(Bunny::NotFound)
    end
  end

  context '#bound_to?' do

    before do
      @source = @channel.exchange 'xchg.source'
      @receiver = @channel.exchange 'xchg.receiver'
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
        @receiver.bind @source, routing_key: 'xchg.route'

        expect(@receiver.bound_to?(@source)).to be_falsey
        expect(@receiver.bound_to?(@source, routing_key: 'xchg.route')).to be_truthy
      end
    end

    it 'return false otherwise' do
      expect(@receiver.bound_to?(@source)).to be_falsey
    end

    it 'should raise error when exchange does not exists' do
      expect { @receiver.bound_to?('this.xchg.does.not.exist') }.to raise_exception(Bunny::NotFound)
    end
  end

  context '#routes_to?' do

    before do
      @source = @channel.exchange 'xchg.source'
      @receiver = @channel.exchange 'xchg.receiver'

      @receiver.bind @source
    end

    it 'should return true if bound' do
      expect(@receiver.bound_to?(@source)).to be_truthy
      expect(@source.routes_to?(@receiver)).to be_truthy
    end

    it 'should return false if unbound' do
      @receiver.unbind @source

      expect(@receiver.bound_to?(@source)).to be_falsey
      expect(@source.routes_to?(@receiver)).to be_falsey
    end

    context 'when using #has_binding?' do
      it 'should output a deprecation warning' do
        expect { @source.has_binding?(@receiver) }.to output(/DEPRECATED/).to_stderr
      end
    end
  end

  context '#delete' do

    before do
      @exchange = @channel.direct 'xchg.direct'
      @exchange.delete
    end

    it 'should remove exchange from session' do
      expect(@session.exchange_exists?(@exchange.name)).to be_falsey
    end
  end
end
