describe BunnyMock::Exchanges::Topic do
  context '#deliver' do
    before do
      @source = @channel.topic 'xchg.source'

      @first = @channel.queue 'queue.#'
      @second = @channel.queue 'queue.*.sub'
      @third = @channel.queue 'queue.*.sub.#'

      @first.bind @source
      @second.bind @source
      @third.bind @source
    end

    it 'should deliver to multiple wildcard' do
      @source.publish 'Test', routing_key: 'queue.anything.after.here'

      expect(@first.message_count).to eql 1
      expect(@second.message_count).to eql 0
      expect(@third.message_count).to eql 0
    end

    it 'should deliver to single wildcards' do
      @source.publish 'Test', routing_key: 'queue.category.sub'

      expect(@first.message_count).to eql 1
      expect(@second.message_count).to eql 1
      expect(@third.message_count).to eql 0
    end

    it 'should deliver for mixed wildcards' do
      @source.publish 'Test', routing_key: 'queue.category.sub.third'

      expect(@first.message_count).to eql 1
      expect(@second.message_count).to eql 1
      expect(@third.message_count).to eql 1
    end
  end
end
