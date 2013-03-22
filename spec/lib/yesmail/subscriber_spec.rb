require 'spec_helper'

class String
  def blank?; to_s == '' end
end

class NilClass
  def blank?; true end
end

module Yesmail
  describe Subscriber do

    describe '#make_hash' do
      it 'should return a hash of the appropriate form' do
        s = Subscriber.new
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

    describe '#api_update' do
      let(:subscriber) { Subscriber.new }
      it 'sets allowResubscribe to true' do
        stub(subscriber).subscriber_id

        mock(subscriber.handler).update(
          post_data = hash_including(allowResubscribe: true),
          path      = anything,
          object_id = anything
        )

        subscriber.api_update
      end
    end

  end
end
