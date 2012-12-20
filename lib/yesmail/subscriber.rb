# This class represents 1 person that will receive an email from Yesmail
# It currently supports the Send and Subscribe Composite API, and the
# Subscriber API

require 'json'
module Yesmail
  class Subscriber
    # @attribute email [String] The email that will recieve a Yesmail email
    # @attribute name [String] The name of the user
    # @attribute attribute_data [Hash] used for any extra data in the user
    #     attributes
    attr_accessor :email, :name, :user_id, :attribute_data

    def path
      '/subscribers'
    end

    def make_hash
      data_hash = {
        subscriptionState: Yesmail.configuration.subscription_state,
        division: { value: Yesmail.configuration.division },
        attributes: { attributes: [] }
      }

      data.each do |key, value|
        data_hash[:attributes][:attributes] << { name: key, value: value }
      end

      data_hash
    end

    def data
      @attribute_data ||= {}
      name_data = name.blank? ? {} : {
        firstName: first_name,
        lastName: last_name
      }
      
      {
        email: email
      }.merge(name_data).merge(attribute_data)
    end

    # These name methods aren't really safe. They might just blow up if the
    # name isn't formatted correctly
    def first_name
      name.split(' ').first
    end

    def last_name
      name.split(' ')[1..-1].join(' ')
    end

    def handler
      @poster ||= Poster.new(Yesmail.configuration.username, Yesmail.configuration.password)
    end

    def api_create
      handler.post(make_hash, path)
    end

    def api_update
      user_id = self.user_id || get_user_id_from_email
      data_hash = make_hash
      #allowResubscribe must be true when resubscribing a subscriber
      data_hash[:allowResubscribe] = true
      handler.update(make_hash, path, user_id)
    end

    def get_user_id_from_email
      if user_id.nil?
        response = api_get
        match_data = response.match(/https:\/\/services\.yesmail\.com\/enterprise\/subscribers\/(.*)/)
        !match_data.nil? ? match_data[1].to_i : 0
      end
    end

    def api_get
      handler.get({email: email}, path)
    end

    def api_remove
      data_hash = make_hash
      user_id = get_user_id_from_email
      delete_hash = { division: data_hash[:division][:value] }
      handler.remove(delete_hash, path, user_id)
    end

    # This will create all of the json from the data placed in this subscriber
    # and send it in the form of JSON to Yesmail's subscribe and send
    # composite API
    def api_create_and_send(master, side_table = nil)
      data = { subscriber: make_hash }
      data[:subscriberMessage] =  master.subscriber_message_data
      data[:subscriber][:allowResubscribe] = true
      data[:sideTable] = side_table.payload_hash unless side_table.nil?

      path = '/composite/subscribeAndSend'
      handler.post(data, path)
    end
  end
end
