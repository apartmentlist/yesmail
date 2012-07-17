require 'json'
module Yesmail
  class Subscriber
    attr_accessor :email, :name

    def make_hash
      data_hash = {
          subscriptionState: "SUBSCRIBED",
          division: { value: "Apartments" },
          attributes: { attributes: [] }
      }

      data.each do |key, value|
        data_hash[:attributes][:attributes] << { name: key, value: value }
      end

      JSON(data_hash)
    end

    def data
      {
        email: email,
        name: name
      }
    end

    def api_create
      handler = Poster.new(Yesmail.configuration.username, Yesmail.configuration.password)
      path = '/subscribers'
      handler.post(make_hash, path)
    end
  end
end