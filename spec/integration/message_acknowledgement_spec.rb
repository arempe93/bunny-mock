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
end
