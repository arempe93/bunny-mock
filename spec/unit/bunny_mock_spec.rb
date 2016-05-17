describe BunnyMock do
	context '::new' do
		it 'should return a new session' do
			expect(BunnyMock.new.class).to eq(BunnyMock::Session)
		end
	end

	context '::version' do
		it 'should return the current version' do
			expect(BunnyMock::VERSION).to_not be_nil
			expect(BunnyMock.version).to_not be_nil
		end
	end

	context '::protocol_version' do
		it 'should return the current amq protocol version' do
			expect(BunnyMock::PROTOCOL_VERSION).to eq('0.9.1')
			expect(BunnyMock.protocol_version).to eq('0.9.1')
		end
	end
end
