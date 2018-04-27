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

    it 'should deliver for mixed wildcards, matching * to a single word only' do
      @source.publish 'Test', routing_key: 'queue.category.sub.third'

      expect(@first.message_count).to eql 1
      expect(@second.message_count).to eql 0
      expect(@third.message_count).to eql 1
    end
    
    it 'should allow wildcards to match blank values' do
      @source.publish 'Test', routing_key: 'queue..sub'
      
      expect(@first.message_count).to eql 1
      expect(@second.message_count).to eql 1
      expect(@third.message_count).to eql 0
    end
    
    it 'should deliver to the correct queue' do
      company_queue = @channel.queue
      company_queue.bind(@source, routing_key: '*.company.*.*')
      @source.publish('Test', routing_key: '123.company.444.245')
      expect(company_queue.message_count).to eql 1
    end
    
    it 'should not deliver to the wrong queue' do
      company_queue = @channel.queue
      company_queue.bind(@source, routing_key: '*.company.*.*')
      @source.publish('Test', routing_key: '.user.create.188')
      expect(company_queue.message_count).to eql 0
    end
    
    it 'should not deliver to the wrong queue when there is another subscription' do
      company_queue = @channel.queue
      company_queue.bind(@source, routing_key: '*.company.*.*')
      
      user_queue = @channel.queue
      user_queue.bind(@source, routing_key: '*.user.*.*')
      
      @source.publish('Test', routing_key: '.user.create.188')
      expect(company_queue.message_count).to eql 0
    end
  end
end
