describe BunnyMock::Queue do

  before do
    @queue = @channel.queue 'testing.q'
  end

  context '#publish' do

    it 'should add message' do
      @queue.publish 'This is a test message'

      expect(@queue.message_count).to eq(1)
      expect(@queue.pop[2]).to eq('This is a test message')
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
      @receiver = @channel.queue 'queue.receiver'

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
      expect { @receiver.bound_to?('this.xchg.does.not.exist') }.to raise_exception(Bunny::NotFound)
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
    context 'when using old api' do
      before { BunnyMock::use_bunny_queue_pop_api = false }
      after  { BunnyMock::use_bunny_queue_pop_api = true }

      it 'should return a Hash' do
        @queue.publish 'First', priority: 1
        response = @queue.pop

        expect(response[:message]).to eql 'First'
        expect(response[:options][:priority]).to eql 1
      end

      it 'should output a deprecation warning' do
        expect { @queue.pop }.to output(/DEPRECATED/).to_stderr
      end
    end

    context 'when using Bunny api' do
      before { BunnyMock::use_bunny_queue_pop_api = true }
      after  { BunnyMock::use_bunny_queue_pop_api = false }

      context 'when queue if empty' do
        it 'should return a nil triplet' do
          expect(@queue.pop).to eql [nil, nil, nil]
        end
      end

      context 'when queue has messages' do
        before { @queue.publish('First') }

        it 'should return triplet of GetResponse, MessageProperties, and payload' do
          response = @queue.pop
          expect(response.map(&:class)).to eql [BunnyMock::GetResponse, BunnyMock::MessageProperties, String]
        end
      end

      context 'when using block' do
        it 'should yield' do
          expect { |b| @queue.pop(&b) }.to yield_control
        end
      end
    end
  end

  context '#subscribe' do

    it 'should consume messages delivered' do
      @queue.subscribe do |_delivery, _headers, body|
        expect(body).to eq('test')
      end
      @queue.publish 'test'
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
