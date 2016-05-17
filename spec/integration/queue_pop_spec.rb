describe BunnyMock::Queue, '#pop' do
  let(:queue) { @channel.queue('test.q') }
  let(:exchange) { @channel.topic('test.exchange') }
  let(:options) { { priority: 1, persistent: true, routing_key: 'test.q' } }

  before { queue.bind(exchange, routing_key: '*.q') }

  context 'when published through an exchange' do
    before do
      exchange.publish('Message', options)
      @di, @mp, @pl = queue.pop
    end

    it 'should have exchange name set in delivery info' do
      expect(@di.exchange).to eql exchange.name
    end

    it 'should have message properties persisted' do
      expect(@mp.to_hash).to eql options
    end

    it 'should have routing key set in delivery info' do
      expect(@di.routing_key).to eql options[:routing_key]
    end
  end

  context 'when published through many exchanges' do
    let(:options) { { priority: 1, persistent: true, routing_key: 'test.q' } }

    before do
      exchange2 = @channel.topic 'test.exchange2'
      exchange.bind(exchange2, routing_key: 'test.*')

      exchange2.publish('Message', options)
      @di, @mp, @pl = queue.pop
    end

    it 'should have last exchange name set in delivery info' do
      expect(@di.exchange).to eql exchange.name
    end

    it 'should have message properties persisted' do
      expect(@mp.to_hash).to eql options
    end

    it 'should have routing key set in delivery info' do
      expect(@di.routing_key).to eql options[:routing_key]
    end
  end

  context 'when published directly' do
    let(:options) { { priority: 1, persistent: true, routing_key: 'something.random' } }

    before do
      queue.publish('Message', options)
      @di, @mp, @pl = queue.pop
    end

    it 'should not have exchange name set in delivery info' do
      expect(@di.exchange).to eql ''
    end

    it 'should have message properties persisted' do
      expect(@mp.to_hash).to eql options
    end

    it 'should have routing key set in delivery info' do
      expect(@di.routing_key).to eql options[:routing_key]
    end
  end
end
