describe BunnyMock::Queue, '#subscribe' do
  before do
    @ch1 = @session.channel
    @ch2 = @session.channel
  end

  context 'when delevered to an exchange' do
    it 'should be delevered in all queues bound to the routing key' do
      t = @ch1.topic 'amq.topic'
      q1 = @ch1.queue 'q1'
      q2 = @ch1.queue 'q2'
      q3 = @ch2.queue 'q3'
      q4 = @ch2.queue 'q4'
      q1.bind(t, routing_key: 'rk1')
      q2.bind(t, routing_key: 'rk1')
      q3.bind(t, routing_key: 'rk1')
      q4.bind(t, routing_key: 'rk1')

      delivered = 0
      q1.subscribe do |_, _, body|
        expect(body).to eq 'test'
        delivered += 1
      end

      q2.subscribe do |_, _, body|
        expect(body).to eq 'test'
        delivered += 1
      end

      q3.subscribe do |_, _, body|
        expect(body).to eq 'test'
        delivered += 1
      end

      q4.subscribe do |_, _, body|
        expect(body).to eq 'test'
        delivered += 1
      end

      t.publish('test', { routing_key: 'rk1' })
      expect(delivered).to eq 4
    end
  end
end
