describe BunnyMock::Channel, 'acknowledgement' do
  let(:queue) { @channel.queue('test.q') }
  let(:delivery_tags) { {} }

  context 'when `manual_ack` = true' do
    before do
      queue.subscribe(manual_ack: true) do |delivery, _headers, body|
        delivery_tags[body] = delivery[:delivery_tag]
      end
      queue.publish 'Another message on the queue'
    end

    it 'should allow messages which have been acked to be identified' do
      queue.publish 'Message to acknowledge'
      delivery_tag = delivery_tags['Message to acknowledge']
      @channel.ack delivery_tag

      expect(@channel.acknowledged_state[:pending]).not_to include(delivery_tag)
      expect(@channel.acknowledged_state[:acked]).to include(delivery_tag)
    end

    it 'should allow messages which have not been acked to be identified' do
      queue.publish 'Message without acknowledgement'
      delivery_tag = delivery_tags['Message without acknowledgement']

      expect(@channel.acknowledged_state[:pending]).to include(delivery_tag)
      expect(@channel.acknowledged_state[:acked]).not_to include(delivery_tag)
    end

    context 'when using nack to negatively acknowledge' do
      it 'should allow messages which have been nacked to be identified' do
        queue.publish 'Message to nack'
        delivery_tag = delivery_tags['Message to nack']
        @channel.nack delivery_tag

        expect(@channel.acknowledged_state[:pending]).not_to include(delivery_tag)
        expect(@channel.acknowledged_state[:acked]).not_to include(delivery_tag)
        expect(@channel.acknowledged_state[:nacked]).to include(delivery_tag)
      end

      it 'should requeue messages with have been nacked with `requeue` = true' do
        queue.publish 'Message to nack'
        delivery_tag = delivery_tags['Message to nack']
        @channel.nack delivery_tag, false, true
        new_delivery_tag = delivery_tags['Message to nack']

        expect(@channel.acknowledged_state[:pending]).not_to include(delivery_tag)
        expect(@channel.acknowledged_state[:acked]).not_to include(delivery_tag)
        expect(@channel.acknowledged_state[:nacked]).to include(delivery_tag)

        expect(@channel.acknowledged_state[:pending]).to include(new_delivery_tag)
      end

      it 'should allow multiple messages to be acked when `multiple` = true' do
        queue.publish 'Message to be automatically acked'
        delivery_tag_1 = delivery_tags['Message to be automatically acked']
        queue.publish 'Message to acked'
        delivery_tag_2 = delivery_tags['Message to acked']
        queue.publish 'Message to be left as pending'
        delivery_tag_3 = delivery_tags['Message to be left as pending']

        @channel.ack delivery_tag_2, true

        expect(@channel.acknowledged_state[:pending]).not_to include(delivery_tag_1)
        expect(@channel.acknowledged_state[:pending]).not_to include(delivery_tag_2)
        expect(@channel.acknowledged_state[:pending]).to include(delivery_tag_3)
        expect(@channel.acknowledged_state[:acked]).to include(delivery_tag_1)
        expect(@channel.acknowledged_state[:acked]).to include(delivery_tag_2)
      end

      it 'should allow multiple messages to be nacked when `multiple` = true' do
        queue.publish 'Message to be automatically nacked'
        delivery_tag_1 = delivery_tags['Message to be automatically nacked']
        queue.publish 'Message to nacked'
        delivery_tag_2 = delivery_tags['Message to nacked']
        queue.publish 'Message to be left as pending'
        delivery_tag_3 = delivery_tags['Message to be left as pending']

        @channel.nack delivery_tag_2, true

        expect(@channel.acknowledged_state[:pending]).not_to include(delivery_tag_1)
        expect(@channel.acknowledged_state[:pending]).not_to include(delivery_tag_2)
        expect(@channel.acknowledged_state[:pending]).to include(delivery_tag_3)
        expect(@channel.acknowledged_state[:nacked]).to include(delivery_tag_1)
        expect(@channel.acknowledged_state[:nacked]).to include(delivery_tag_2)
      end
    end

    context 'when using reject to negatively acknowledge' do
      it 'should allow messages which have been nacked to be identified' do
        queue.publish 'Message to reject'
        delivery_tag = delivery_tags['Message to reject']
        @channel.reject delivery_tag

        expect(@channel.acknowledged_state[:pending]).not_to include(delivery_tag)
        expect(@channel.acknowledged_state[:acked]).not_to include(delivery_tag)
        expect(@channel.acknowledged_state[:rejected]).to include(delivery_tag)
      end

      it 'should requeue messages with have been rejected with `requeue` = true' do
        queue.publish 'Message to reject'
        delivery_tag = delivery_tags['Message to reject']
        @channel.reject delivery_tag, true
        new_delivery_tag = delivery_tags['Message to reject']

        expect(@channel.acknowledged_state[:pending]).not_to include(delivery_tag)
        expect(@channel.acknowledged_state[:acked]).not_to include(delivery_tag)
        expect(@channel.acknowledged_state[:rejected]).to include(delivery_tag)

        expect(@channel.acknowledged_state[:pending]).to include(new_delivery_tag)
      end
    end

    context 'when having a dead letter exchange defined' do
      let(:dlx) { @channel.fanout('test.dlx') }
      let(:dlq) { @channel.temporary_queue.bind(dlx) }
      before do
        dlq
        queue.opts.merge!(arguments: { 'x-dead-letter-exchange' => dlx.name })
      end

      it 'should send nacked message to dead letter exchange if specified' do
        queue.publish 'Message to nack'
        @channel.nack delivery_tags['Message to nack']

        expect(dlq.message_count).to be 1
        expect(dlq.pop.last).to eq 'Message to nack'
      end

      it 'should not send nacked message to dead letter exchange if it is requeued' do
        queue.publish 'Message to nack'
        @channel.nack delivery_tags['Message to nack'], false, true

        expect(dlq.message_count).to be 0
      end

      it 'should send rejected message to dead letter exchange if specified' do
        queue.publish 'Message to reject'
        @channel.reject delivery_tags['Message to reject']

        expect(dlq.message_count).to be 1
        _, properties, message = dlq.pop
        expect(message).to eq 'Message to reject'
        xdeath_headers = properties[:headers]['x-death'].first
        expect(xdeath_headers['count']).to eq 1
        expect(xdeath_headers['queue']).to eq queue.name
        expect(xdeath_headers['reason']).to eq 'rejected'
        expect(xdeath_headers['routing_keys']).to eq [queue.name]
      end

      it 'should not send rejected message to dead letter exchange if it is requeued' do
        queue.publish 'Message to reject'
        @channel.nack delivery_tags['Message to reject'], false, true

        expect(dlq.message_count).to be 0
      end

      it 'should be possible to overwrite the dead letter routing key' do
        queue.opts.merge!(arguments: { 'x-dead-letter-exchange' => dlx.name, 'x-dead-letter-routing-key' => 'dl_key' })
        queue.publish 'Message to reject'
        @channel.reject delivery_tags['Message to reject']

        expect(dlq.message_count).to be 1
        delivery_info, headers, payload = dlq.pop
        expect(payload).to eq 'Message to reject'
        expect(headers[:routing_key]).to eq 'dl_key'
        expect(delivery_info[:routing_key]).to eq 'dl_key'
      end

    end
  end
end
