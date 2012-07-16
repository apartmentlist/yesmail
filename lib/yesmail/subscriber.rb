require 'json'
module Yesmail
  class Subscriber
    attr_accessor :email, :name

    def make_hash
      data_hash = {
          subscriptionState: "SUBSCRIBED",
          division: { value: "Retail" },
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

    def config
      @config ||= Configuration.new
    end

    def api_create
      handler = Poster.new(config.username, config.password)
      path = '/subscribers'
      handler.post(make_hash, path)
    end
  end
end