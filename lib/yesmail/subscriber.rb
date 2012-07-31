require 'json'
module Yesmail
  class Subscriber
    attr_accessor :email, :name, :user_id

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
      {
        email: email,
        firstName: first_name,
        lastName: last_name
      }
    end

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

    def api_create_and_send(master, side_table)
      data = { subscriber: make_hash }
      data[:subscriberMessage] =  master.subscriber_message_data
      data[:subscriber][:allowResubscribe] = true
      data[:sideTable] = side_table.payload_hash

      path = '/composite/subscribeAndSend'
      handler.post(data, path)
    end
  end
end