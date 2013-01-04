require 'yesmail'

describe 'Yesmail::Subscriber' do
  describe '#make_hash' do
    it 'should return a hash of the appropriate form' do
      class String
        def blank?; to_s == ''; end   # implement a bit of Rails
      end
      s = Yesmail::Subscriber.new
      s.email = "joeuser@aol.com"
      s.name = "Joe User"
      s.attribute_data = { key1: 'val1', key2: 'val2', key3: 'val3' }
      result = s.make_hash

      # Expected format:
      #
      # result = {
      #   subscriptionState: "SUBSCRIBED",
      #   division: {
      #     value: "Apartments"
      #   },
      #   attributes: {
      #     attributes: [
      #       { name: :key1, value: 'val1' },
      #       { name: :key2, value: 'val2' },
      #       { name: :key3, value: 'val3' }
      #     ]
      #   }
      # }

      [ :subscriptionState, :division, :attributes ].each do |key|
        result.should have_key(key)
      end
      result[:attributes].should have_key(:attributes)
      result[:attributes][:attributes].should be_a_kind_of Array
      result[:attributes][:attributes].each do |item|
        item.should be_a_kind_of Hash
        item.should have_key(:name)
        item.should have_key(:value)
      end

      # Each attribute should be present
      { key1: 'val1', key2: 'val2', key3: 'val3' }.each do |k,v|
        matches = result[:attributes][:attributes].select { |h| h[:name] == k }
        matches.first[:value].should == v
      end

    end
  end
end
